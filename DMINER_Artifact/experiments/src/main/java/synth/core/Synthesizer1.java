package synth.core;

import com.microsoft.z3.Model;
import org.neo4j.driver.Driver;
import synth.ast.AstVisitor;
import synth.ast.IAstVisitor;
import synth.ast.clause.FilterClause;
import synth.ast.clause.Return;
import synth.ast.clause.SingleMatch;
import synth.ast.pattern.PathPattern;
import synth.ast.pred.Predicate;
import synth.ast.pred.expr.Property;
import synth.core.PattermEnumerator.Cleaner;
import synth.core.PattermEnumerator.Helper;
import synth.core.QuerySketchSyn.SketchCompletion;
import synth.core.QuerySketchSyn.SketchCompletionHelper;
import synth.core.QuerySketchSyn.SketchSynthesizer;
import synth.core.data.dataStructures.Demonstration;
import synth.core.data.dataStructures.Expression;
import synth.core.data.dataStructures.InputGraph;
import synth.core.PattermEnumerator.Pattern;
import synth.core.PattermEnumerator.PatternIterator;
import synth.core.filterSyn.PredicateSynthesize;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.*;
import java.util.concurrent.*;

import static synth.Main.createDriver;
import static synth.core.PattermEnumerator.PatternIterator.checkOutputCoverage;
import static synth.core.PatternEvaluator.*;
import static synth.core.QuerySketchSyn.SketchCompletionHelper.decode;
import static synth.core.data.dataStructures.InputGraph.findConnected;
import static synth.core.PattermEnumerator.Cleaner.clean;

public class Synthesizer1 {
    public static class synthesizeResult {
        public synthesizeResult(long patternTime, long sketchTime, long predicateTime, long allTime, String query) {
            this.patternTime = patternTime;
            this.sketchTime = sketchTime;
            this.predicateTime = predicateTime;
            this.allTime = allTime;
            this.query = query;
        }

        public long patternTime;
        public long sketchTime;
        public long predicateTime;
        public long allTime;
        public String query;
    }

    public synthesizeResult result;

    public synthesizeResult synthesize(ArrayList<Demonstration> demonstrations, ArrayList<String> databaseNames,
                                       Driver driver, Boolean minSynAblation, Boolean dataDrivenAblation,
                                       Boolean isomorphismAblation, Boolean analyzeConflictAblation,
                                       ArrayList<Integer> demonIDs) {
        PatternEvaluator patternEvaluator = new PatternEvaluator(driver);
        Helper dataPrep = new Helper(demonstrations, demonIDs);
        IAstVisitor visitor = new AstVisitor();

        long allStart = System.currentTimeMillis();
        long patternTime = 0;
        long sketchTime = 0;
        long predicateTime = 0;
        long patternStart = System.currentTimeMillis();
        int predicateCount = 0;

        dataPrep.getOutputNeeds();
        dataPrep.label2Property();
        dataPrep.getAllExpNonExp();
        dataPrep.prepSubgraphTargets(dataPrep.expressions, dataPrep.nonExpressions);

        Integer minDemonstrationID = 0;
        ArrayList<InputGraph> candidateGraphs = new ArrayList<>();
        ArrayList<Integer> demonstrationIDs = new ArrayList<>();
        Cleaner.cleanObject cleanObjects = clean(demonstrations);

        if (!minSynAblation) {
            Integer minSize = 100;
            InputGraph minGraph = null;
            if (!dataDrivenAblation) {
                for (Integer demonstrationID : cleanObjects.tmp.keySet()) {
                    for (InputGraph graph : cleanObjects.tmp.get(demonstrationID)) {
                        if (PatternIterator.checkComplete(graph, new HashSet<>(dataPrep.nodeLabel2Properties.keySet()),
                                new HashSet<>(dataPrep.edgeLabel2Properties.keySet()), dataPrep.outputNeed.get(demonstrationID))) {
                            if (minSize > graph.getSize()) {
                                minSize = graph.getSize();
                                minGraph = graph;
                                minDemonstrationID = demonstrationID;
                            }
                        }
                    }
                }
                candidateGraphs.add(minGraph);
                demonstrationIDs.add(minDemonstrationID);
            } else {
//                do  ablation, would then have a hashmap<size->demonstration ID->graph>
                HashMap<Integer, HashMap<Integer, ArrayList<InputGraph>>> tmp2 = new HashMap<>();
                for (Integer demonstrationID : cleanObjects.tmp.keySet()) {
                    for (InputGraph graph : cleanObjects.tmp.get(demonstrationID)) {
                        if (!tmp2.containsKey(graph.getSize())) {
                            tmp2.put(graph.getSize(), new HashMap<>());
                        }
                        if (!tmp2.get(graph.getSize()).containsKey(demonstrationID)) {
                            tmp2.get(graph.getSize()).put(demonstrationID, new ArrayList<>());
                        }
                        tmp2.get(graph.getSize()).get(demonstrationID).add(graph);
                    }
                }
                SortedSet<Integer> sortedSize = new TreeSet<>(tmp2.keySet());
                for (Integer graphSize : sortedSize) {
                    for (Integer demonstrationID : tmp2.get(graphSize).keySet()) {
                        for (InputGraph graph : tmp2.get(graphSize).get(demonstrationID)) {
                            candidateGraphs.add(graph);
                            demonstrationIDs.add(demonstrationID);
                        }
                    }
                }
            }
        } else {
            for (List<Object> demo : cleanObjects.inputGraphs) {
                InputGraph graph = (InputGraph) demo.get(0);
                Integer dID = (Integer) demo.get(1);
                for (InputGraph connectedGraph : findConnected(graph)) {
                    if (!dataDrivenAblation) {
                        if (checkOutputCoverage(graph, dataPrep.inputItemsMap, dataPrep.atomCnt, dID)) {
                            candidateGraphs.add(connectedGraph);
                            demonstrationIDs.add(dID);
                        }
                    } else {
                        candidateGraphs.add(connectedGraph);
                        demonstrationIDs.add(dID);
                    }
                }
            }
        }

        PatternIterator<Pattern> patternIterator = new PatternIterator<>(candidateGraphs, demonstrationIDs, new HashSet<>(dataPrep.nodeLabel2Properties.keySet()),
                new HashSet<>(dataPrep.edgeLabel2Properties.keySet()), dataPrep.outputNeed, minSynAblation,
                dataDrivenAblation, isomorphismAblation, dataPrep.inputItemsMap, dataPrep.atomCnt);

        patternTime += System.currentTimeMillis() - patternStart;
        patternStart = System.currentTimeMillis();

        for (Pattern pattern : patternIterator) {
            if (Thread.currentThread().isInterrupted()) return new synthesizeResult(0, 0, 0, 600000, null);
//                Evaluate pattern
            if (pattern == null) {
                continue;
            }

//          enumeration data for last pattern round
            ArrayList<ArrayList<String>> allVals = new ArrayList<>();
            ReturnQuery values = null;
            String returnAllQuery = pattern2Query(pattern);

            Boolean continueThisPattern = true;
            HashSet<String> dataIDs = new HashSet<>();
            for (int demonstrationID : demonIDs) {
                String databaseName = null;
                if (demonstrationID >= databaseNames.size()) {
                    databaseName = databaseNames.get(0);
                } else {
                    databaseName = databaseNames.get(demonstrationID);
                }
                ReturnQuery valsInOneDe = patternEvaluator.evaluate(returnAllQuery, databaseName, demonstrationID);
                if (valsInOneDe != null) {
                    allVals.addAll(valsInOneDe.vals);
                    for (ArrayList<String> rowData : valsInOneDe.vals) {
                        dataIDs.addAll(rowData);
                    }
                    if (demonstrationID == 0) {
                        values = new ReturnQuery(valsInOneDe.variableName, allVals);
                    }
                } else {
                    continueThisPattern = false;
                    break;
                }
//                dCnt++;
            }
            if (continueThisPattern) {
//                Check whether paths contains all data from output
                if (!dataIDs.containsAll(dataPrep.allNeedIDs)) {
                    continueThisPattern = false;
                }
            }
            patternTime += System.currentTimeMillis() - patternStart;
            if (!continueThisPattern) {
                patternStart = System.currentTimeMillis();
                continue;
            }
            values.vals = allVals;

            long sketchStart = System.currentTimeMillis();
            LinkedHashMap<String, ArrayList<String>> varName2Labels = PatternEvaluator.varName2Labels(values.variableName, allVals.get(0), demonstrations);
            LinkedHashMap<String, ArrayList<String>> varName2Properties = PatternEvaluator.varName2Properties(values.variableName, allVals.get(0), demonstrations);


//                EnumVars
            SketchCompletion sketchSynthesizer = new SketchCompletion();
//            Initiate environments with preprocess helper
            sketchSynthesizer.initiate(demonstrations, varName2Labels,
                    values.variableName, values.vals, analyzeConflictAblation, dataPrep.expressions, dataPrep.nonExpressions);
            sketchSynthesizer.generateInitialConstraints();
            sketchSynthesizer.addSoftConstraint();

            while (sketchSynthesizer.hasNext()) {
                if (Thread.currentThread().isInterrupted()) return new synthesizeResult(0, 0, 0, 600000, null);
//                Decode solution
                SketchCompletionHelper.Decoded decoded = decode(sketchSynthesizer.exprVars, sketchSynthesizer.nonExprVars, sketchSynthesizer.pathVars, sketchSynthesizer.solution);
                sketchSynthesizer.nonRepairedExpressions = decoded.nonRepairedExpressions;
                sketchSynthesizer.nonRepairedNonExpressions = decoded.nonRepairedNonExpressions;
                sketchSynthesizer.repairedExpressions = decoded.repairedExpressions;
                sketchSynthesizer.repairedNonExpressions = decoded.repairedNonExpressions;
                sketchSynthesizer.inclusions = decoded.inclusions;
                sketchSynthesizer.exclusions = decoded.exclusions;
                sketchSynthesizer.updateSelectedRows();

                // Evaluate synthesized items
                if (sketchSynthesizer.aggregationColIDs.isEmpty()) {
                    try {
                        sketchSynthesizer.Evaluate(false);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                } else {
                    try {
                        sketchSynthesizer.Evaluate(true);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
//                sketchSynthesizer.Evaluate(false);

                Boolean sketchCorrect = sketchSynthesizer.synthesisCorrect;
                // Transform solution to sketch
                SketchCompletion.CompletionReturn sketch = sketchSynthesizer.transform();

                sketchTime += System.currentTimeMillis() - sketchStart;

                if (sketchCorrect) {
                    long predStart = System.currentTimeMillis();
                    PredicateSynthesize predicateSynthesize = new PredicateSynthesize();
                    PredicateSynthesize.ReturnPredSyn returnPredSyn = predicateSynthesize.predicateSynthesizer(sketch.toInclude, sketch.toExclude,
                            demonstrations, values, varName2Properties, predicateCount);
                    Predicate predicate = null;
                    if (predicateSynthesize.needPredicate) {
                        predicate = returnPredSyn.predicateClause;
                        predicateCount += returnPredSyn.predicateCnt;
                    }
                    predicateTime += System.currentTimeMillis() - predStart;

                    if (predicate != null || !predicateSynthesize.needPredicate) {
                        if (predicate != null && predicateSynthesize.needPredicate) {
                            String query = translateToAst(pattern, predicate, sketch.expressionStrings, sketch.nonExpressionStrings);
                            long allEnd = System.currentTimeMillis();
                            long allTime = allEnd - allStart;

                            return new synthesizeResult(patternTime, sketchTime, predicateTime, allTime, query);
                        } else {
                            String query = translateToAst(pattern, null, sketch.expressionStrings, sketch.nonExpressionStrings);
                            long allEnd = System.currentTimeMillis();
                            long allTime = allEnd - allStart;

                            return new synthesizeResult(patternTime, sketchTime, predicateTime, allTime, query);
                        }
                    }
                }
                sketchStart = System.currentTimeMillis();
                sketchSynthesizer.removeCurrentModel();
                sketchSynthesizer.cleanUp();
            }
            patternStart = System.currentTimeMillis();
            if (Thread.currentThread().isInterrupted()) return new synthesizeResult(0, 0, 0, 600000, null);
        }

        long allEnd = System.currentTimeMillis();
        long allTime = allEnd - allStart;
        patternIterator.nextRound.clear();
        patternIterator.backUpGraphs.clear();
        return new synthesizeResult(0, 0, 0, allTime, null);
    }

    public static String removeDuplicateLabels(String input) {
        Set<String> seen = new HashSet<>();
        StringBuilder result = new StringBuilder();
        int i = 0;

        while (i < input.length()) {
            if (input.charAt(i) == '(') {
                int closeIdx = input.indexOf(')', i); // the first ')' after i
                if (closeIdx != -1) {
                    String content = input.substring(i + 1, closeIdx); // A:B
                    int colonIdx = content.indexOf(':');
                    if (colonIdx != -1) {
                        String beforeColon = content.substring(0, colonIdx); // A
                        if (seen.contains(beforeColon)) {
                            // Remove the part after colon
                            result.append('(').append(beforeColon).append(')');
                        } else {
                            seen.add(beforeColon);
                            result.append('(').append(content).append(')');
                        }
                        i = closeIdx + 1;
                        continue;
                    }
                }
            }
            result.append(input.charAt(i));
            i++;
        }
        return result.toString();
    }

    public static String translateToAst(Pattern pattern, Predicate predicate, String expressionString, String nonExpressionString) {
        PathPattern unifiedPattern = new PathPattern(pattern2QueryHelper(pattern).pattern);

        FilterClause filterClause = new FilterClause(new SingleMatch(unifiedPattern), predicate);
        Return returnClause = new Return(filterClause, null);

        IAstVisitor visitor = new AstVisitor();
        if (expressionString != null || nonExpressionString != null) {
            if (nonExpressionString.isEmpty()) {
                String query = returnClause.astAccept(visitor) + expressionString;
                return removeDuplicateLabels(query);
            } else if (expressionString.isEmpty()) {
                String query = returnClause.astAccept(visitor) + nonExpressionString;
                return removeDuplicateLabels(query);
            } else {
                String query = returnClause.astAccept(visitor) + nonExpressionString + ", " + expressionString;
                return removeDuplicateLabels(query);
            }
        }
        String query = returnClause.astAccept(visitor);
        return removeDuplicateLabels(query);
    }

    public synthesizeResult runWithTimeOut(ArrayList<Demonstration> demonstrations, ArrayList<String> databaseNames,
                                           Driver driver, Boolean minSynAblation, Boolean dataDrivenAblation,
                                           Boolean isomorphismAblation, Boolean analyzeConflictAblation,
                                           ArrayList<Integer> demonIDs) {
        result = synthesize(demonstrations, databaseNames,
                driver, minSynAblation, dataDrivenAblation,
                isomorphismAblation, analyzeConflictAblation, demonIDs);
        return result;
    }
}
