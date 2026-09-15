package synth;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import org.neo4j.driver.Driver;
import synth.core.Synthesizer1;
import synth.core.data.dataStructures.Demonstration;

import java.io.File;
import java.util.*;

import static synth.Main.createDriver;
import static synth.core.data.dataStructures.IntermediateData.getDemonstrations;

public class BenchmarkRunner {
    public static void main(String[] args) throws Exception {
        // Args: key benchmarkId outputFile [--newBenchmark]
        String key = args[0];
        int benchmarkId = Integer.parseInt(args[1]);
        String outputFile = args[2];
        boolean newBenchmark = args.length > 3 && args[3].equals("--newBenchmark");

        Driver neo4jDriver = createDriver("./experiments/experiments.config");

        try {
            Map<String, Object> result = runBenchmark(key, benchmarkId, neo4jDriver, newBenchmark);
            ObjectMapper mapper = new ObjectMapper();
            mapper.enable(SerializationFeature.INDENT_OUTPUT);
            mapper.writeValue(new File(outputFile), result);

        } catch (Exception e) {
            System.out.println("BenchmarkRunner error: " + e.getMessage());
            e.printStackTrace(System.out);
            System.out.flush();

            // Write error result so Main knows it failed
            Map<String, Object> result = new HashMap<>();
            result.put("benchmarkID", benchmarkId);
            result.put("Total Time", null);
            result.put("Synthesized", null);
            result.put("Time for pattern synthesis", null);
            result.put("Time for return statement synthesis", null);
            result.put("Time for predicate synthesis", null);
            new ObjectMapper().writeValue(new File(outputFile), result);
        } finally {
            neo4jDriver.close();
        }
    }

    public static Map<String, Object> runBenchmark(String key, int benchmarkId, Driver neo4jDriver) throws Exception {
        return runBenchmark(key, benchmarkId, neo4jDriver, false);
    }

    public static Map<String, Object> runBenchmark(
            String key,
            int benchmarkId,
            Driver neo4jDriver,
            boolean newBenchmark) throws Exception {
        System.out.println("BenchmarkRunner starting: benchmark=" + benchmarkId);
        System.out.flush();

        String benchmarkPath = newBenchmark
                ? "/DMINER_Artifact/experiments/reusability/new_benchmarks/benchmark" + benchmarkId + ".json"
                : "/DMINER_Artifact/experiments/data/benchmark" + benchmarkId + ".json";
        ArrayList<Demonstration> example = getDemonstrations(
                benchmarkPath, 0, false);

        ArrayList<String> databaseNames = new ArrayList<>();
        for (int i = 0; i < example.size(); i++) {
            databaseNames.add("experiment" + benchmarkId + "demonstration" + i);
        }

        ArrayList<Integer> demonIDs = new ArrayList<>();
        for (int i = 0; i < example.size(); i++) demonIDs.add(i);

        boolean dataDriven = key.equals("all") || key.equals("candidatePruning");
        boolean min = key.equals("all") || key.equals("candidatePruning");
        boolean analyze = key.equals("all") || key.equals("deductiveReasoning");

        Synthesizer1 synthesizer = new Synthesizer1();
        Synthesizer1.synthesizeResult query = synthesizer.runWithTimeOut(
                example, databaseNames, neo4jDriver,
                min, dataDriven, false, analyze, demonIDs);

        Map<String, Object> result = new HashMap<>();
        result.put("benchmarkID", benchmarkId);
        result.put("Total Time", query.allTime);
        result.put("Synthesized", query.query);
        result.put("Time for pattern synthesis", query.patternTime);
        result.put("Time for return statement synthesis", query.sketchTime);
        result.put("Time for predicate synthesis", query.predicateTime);

        System.out.println("BenchmarkRunner done: benchmark=" + benchmarkId);
        System.out.flush();
        return result;
    }
}
