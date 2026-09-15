package synth;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import org.neo4j.driver.AuthTokens;
import org.neo4j.driver.Driver;
import org.neo4j.driver.GraphDatabase;

import java.io.*;
import java.util.*;
import java.util.concurrent.*;

public class Main {

    private static final Set<String> VALID_STUDIES = Set.of(
            "none", "candidatePruning", "deductiveReasoning", "all");

    private static final Set<Integer> SEQUENTIAL_ONLY_BENCHMARKS = Set.of(
            5, 7, 44, 65, 66, 68, 69, 70, 72, 75, 79);

    public static Driver createDriver(String configFile) {
        Properties prop = new Properties();
        try (FileInputStream fis = new FileInputStream(configFile)) {
            prop.load(fis);
        } catch (IOException ex) {
            System.out.println(ex);
            System.out.flush();
        }
        System.out.println("Connecting to Neo4j database...");
        System.out.println("URI: " + prop.getProperty("URI"));
        System.out.flush();
        String dbUri = prop.getProperty("URI");
        String dbUser = "neo4j";
        String dbPassword = prop.getProperty("PASSWORD");

        Driver driver = GraphDatabase.driver(dbUri, AuthTokens.basic(dbUser, dbPassword));
        try {
            driver.verifyConnectivity();
            System.out.println("Connection established.");
            System.out.flush();
        } catch (Exception e) {
            System.out.println("Failed to connect to the database: " + e.getMessage());
            System.out.flush();
            System.exit(1);
        }
        return driver;
    }

    private static String getOutputAddress(String key, boolean newBenchmark) {
        String resultsDirectory = newBenchmark
                ? "/DMINER_Artifact/experiments/results/new_benchmarks/"
                : "/DMINER_Artifact/experiments/results/";
        switch (key) {
            case "all":              return resultsDirectory + "resultsAllAblation.json";
            case "deductiveReasoning":
                return resultsDirectory + "resultsDeductiveReasoning.json";
            case "candidatePruning":
                return resultsDirectory + "resultsCandidatePruning.json";
            case "none":             return resultsDirectory + "mainResults.json";
            default:                 return resultsDirectory + "results_" + key + ".json";
        }
    }

    private static void appendResult(String address, Map<String, Object> result) throws IOException {
        ObjectMapper myObjectMapper = new ObjectMapper();
        myObjectMapper.enable(SerializationFeature.INDENT_OUTPUT);
        File outputFile = new File(address);
        List<Map<String, Object>> allResults = new ArrayList<>();
        if (outputFile.exists() && outputFile.length() > 0) {
            allResults.addAll(myObjectMapper.readValue(
                    outputFile,
                    new TypeReference<List<Map<String, Object>>>() {}
            ));
        }
        allResults.add(result);
        myObjectMapper.writeValue(outputFile, allResults);
    }

    public static void main(String[] args) throws Exception {

        if (args.length < 2 || args.length > 5) {
            throw new IllegalArgumentException(
                    "Usage: synth.Main <study> <timeoutMinutes> [startID endID] [--newBenchmark]");
        }

        System.out.println("=== Main started ===");
        System.out.flush();

        String key = args[0];
        if (!VALID_STUDIES.contains(key)) {
            throw new IllegalArgumentException(
                    "study must be one of: " + VALID_STUDIES);
        }
        int timeoutMinutes = Integer.parseInt(args[1]);
        boolean newBenchmark = false;
        ArrayList<String> positionalArgs = new ArrayList<>();
        for (int i = 2; i < args.length; i++) {
            if (args[i].equals("--newBenchmark")) {
                newBenchmark = true;
            } else {
                positionalArgs.add(args[i]);
            }
        }
        if (positionalArgs.size() != 0 && positionalArgs.size() != 2) {
            throw new IllegalArgumentException(
                    "Usage: synth.Main <study> <timeoutMinutes> [startID endID] [--newBenchmark]");
        }
        if (timeoutMinutes <= 0) {
            throw new IllegalArgumentException("timeoutMinutes must be greater than zero");
        }
        System.out.println(key);
        Integer startID = null;
        Integer endID = null;
        if (positionalArgs.size() == 2) {
            startID = Integer.valueOf(positionalArgs.get(0));
            endID = Integer.valueOf(positionalArgs.get(1));
        }

        System.out.println("Start on study: " + key);
        System.out.println("New benchmark mode: " + newBenchmark);
        System.out.flush();
        final boolean useNewBenchmark = newBenchmark;

        // Build benchmark list
        ArrayList<Integer> includeBenchmarks = new ArrayList<>();
        if (startID != null) {
            for (int i = startID; i < endID; i++) {
                includeBenchmarks.add(i);
            }
        } else {
            includeBenchmarks.add(2);
            for (int i = 2; i < 92; i++) {
                if (notParallelStudy(key) && SEQUENTIAL_ONLY_BENCHMARKS.contains(i)) {
                    continue;
                }
                includeBenchmarks.add(i);
            }
            if (notParallelStudy(key)) {
                System.out.println("Skipping sequential-only benchmarks: "
                        + SEQUENTIAL_ONLY_BENCHMARKS);
            }
        }
        if (includeBenchmarks.isEmpty()) {
            throw new IllegalArgumentException("The benchmark range must contain at least one ID");
        }

        // Ensure results directory exists
        String address = getOutputAddress(key, useNewBenchmark);
        File resultsDir = new File(address).getParentFile();
        if (resultsDir != null && !resultsDir.exists()) {
            resultsDir.mkdirs();
        }

        int workerCount = key.equals("none")
                ? 1
                : Math.min(
                        Runtime.getRuntime().availableProcessors(),
                        includeBenchmarks.size());
        List<List<Integer>> batches = partitionBenchmarks(includeBenchmarks, workerCount);

        System.out.println("Running " + includeBenchmarks.size() + " benchmarks in "
                + workerCount + (workerCount == 1 ? " sequential batch" : " parallel batches")
                + " (available CPUs: "
                + Runtime.getRuntime().availableProcessors() + ")");
        System.out.flush();

        Driver neo4jDriver = createDriver("/DMINER_Artifact/experiments/experiments.config");
        ExecutorService batchExecutor = Executors.newFixedThreadPool(workerCount);
        try {
            List<Future<List<Map<String, Object>>>> batchFutures = new ArrayList<>();
            for (int batchId = 0; batchId < batches.size(); batchId++) {
                final int currentBatchId = batchId;
                final List<Integer> batch = batches.get(batchId);
                batchFutures.add(batchExecutor.submit(
                        () -> runBatch(currentBatchId, batch, key, timeoutMinutes, neo4jDriver, useNewBenchmark)));
            }

            List<Map<String, Object>> results = new ArrayList<>();
            for (Future<List<Map<String, Object>>> batchFuture : batchFutures) {
                results.addAll(batchFuture.get());
            }
            results.sort(Comparator.comparingInt(result ->
                    ((Number) result.get("benchmarkID")).intValue()));
            for (Map<String, Object> result : results) {
                appendResult(address, result);
            }
        } finally {
            batchExecutor.shutdownNow();
            neo4jDriver.close();
        }

        System.out.println("Finished study " + key);
        System.out.println("Results saved to " + address);
        System.out.flush();
        System.exit(0);
    }

    private static boolean notParallelStudy(String key) {
        return key.equals("candidatePruning") || key.equals("all");
    }

    static List<List<Integer>> partitionBenchmarks(List<Integer> benchmarks, int workerCount) {
        if (workerCount <= 0) {
            throw new IllegalArgumentException("workerCount must be greater than zero");
        }
        List<List<Integer>> batches = new ArrayList<>();
        for (int i = 0; i < workerCount; i++) {
            batches.add(new ArrayList<>());
        }
        // Round-robin distribution keeps batches balanced when benchmark costs vary by ID.
        for (int i = 0; i < benchmarks.size(); i++) {
            batches.get(i % workerCount).add(benchmarks.get(i));
        }
        return batches;
    }

    private static List<Map<String, Object>> runBatch(
            int batchId,
            List<Integer> benchmarkIds,
            String key,
            int timeoutMinutes,
            Driver neo4jDriver,
            boolean newBenchmark) {
        List<Map<String, Object>> results = new ArrayList<>();
        System.out.println("Batch " + batchId + " starting: " + benchmarkIds);
        System.out.flush();

        for (int benchmarkId : benchmarkIds) {
            ExecutorService timeoutExecutor = Executors.newSingleThreadExecutor();
            Future<Map<String, Object>> future = timeoutExecutor.submit(
                    () -> BenchmarkRunner.runBenchmark(key, benchmarkId, neo4jDriver, newBenchmark));
            try {
                results.add(future.get(timeoutMinutes, TimeUnit.MINUTES));
            } catch (TimeoutException e) {
                System.out.println("TIMEOUT: benchmark " + benchmarkId + " exceeded "
                        + timeoutMinutes + " minutes.");
                future.cancel(true);
                results.add(timeoutResult(benchmarkId, timeoutMinutes));
            } catch (Exception e) {
                System.out.println("Benchmark " + benchmarkId + " failed: " + e.getMessage());
                e.printStackTrace(System.out);
                results.add(errorResult(benchmarkId, e));
            } finally {
                timeoutExecutor.shutdownNow();
                System.out.flush();
            }
        }
        System.out.println("Batch " + batchId + " finished.");
        System.out.flush();
        return results;
    }

    private static Map<String, Object> timeoutResult(int benchmarkId, int timeoutMinutes) {
        Map<String, Object> result = new HashMap<>();
        result.put("benchmarkID", benchmarkId);
        result.put("Total Time", (long) timeoutMinutes * 60 * 1000);
        result.put("Synthesized", null);
        result.put("Time for pattern synthesis", 0);
        result.put("Time for return statement synthesis", 0);
        result.put("Time for predicate synthesis", 0);
        result.put("Error", "timeout");
        return result;
    }

    private static Map<String, Object> errorResult(int benchmarkId, Exception e) {
        Map<String, Object> result = new HashMap<>();
        result.put("benchmarkID", benchmarkId);
        result.put("Total Time", -1);
        result.put("Synthesized", null);
        result.put("Time for pattern synthesis", null);
        result.put("Time for return statement synthesis", null);
        result.put("Time for predicate synthesis", null);
        result.put("Error", e.getMessage());
        return result;
    }
}
