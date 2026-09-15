package synth.core.QuerySketchSyn;

import com.microsoft.z3.*;
import synth.ast.pred.expr.Property;
import synth.core.QuerySketchSyn.SketchCompletionHelper.GroupByReturn;
import synth.core.data.dataStructures.Demonstration;
import synth.core.data.dataStructures.Expression;

import java.util.*;

import static synth.core.QuerySketchSyn.SketchCompletionHelper.*;

public class SketchCompletion {

    public ArrayList<Demonstration> demonstrations;
    public HashMap<String, ArrayList<String>> varName2Labels;
    public ArrayList<String> variableName;
    public ArrayList<ArrayList<String>> values;
    public Boolean analyzeAblation;

    // Property -> variable ID of which label corresponds with the property
    public HashMap<String, ArrayList<Integer>> initialOptions;
    public HashMap<ArrayList<String>, ArrayList<Integer>> pathPropertyValues;

    public HashMap<String, Expression> expressions = new HashMap<>(); // valID -> Expression
    public HashMap<String, Property> nonExpressions = new HashMap<>(); // valID -> Property
    public HashSet<ArrayList<Integer>> aggregationColIDs = new HashSet<>(); // if there is aggregations in expressions
    public HashMap<Integer, Expression> exampleExpMap = new HashMap<>(); // idx of expression related hole -> example expression
    public HashMap<Integer, Property> exampleNonExpMap = new HashMap<>(); // idx of property related hole -> example property
    public  HashMap<Integer, HashMap<Integer, HashMap<HashMap<String, Integer>, Integer>>> expHole2Datas = new HashMap<>(); // colID -> [dataGroup] for expressions
    public  HashMap<Integer, HashMap<HashMap<String, Integer>, Integer>> nonExpHole2Datas = new HashMap<>(); // colID -> [dataGroup] for non-expressions
    public HashMap<Integer, HashMap<HashMap<HashMap<String, Integer>, Integer>, Integer>> rowDataGroups; // rowID -> dataGroups in row

    public ArrayList<Expression> synthesizedExpressions = new ArrayList<>();
    public ArrayList<Property> synthesizedProperties = new ArrayList<>();

    // map from atom expression to idx of the atom expression: agg -> prop -> {inputIDs of one value} -> valID -> idx in expression
    public HashMap<String, HashMap<String, HashMap<HashMap<String, Integer>, HashMap<String, ArrayList<Integer>>>>> locExpMap = new HashMap<>();
    // map from atom non-expression to idx of the non expression property: agg -> prop -> NEId -> valID
    public HashMap<String, HashMap<HashMap<String, Integer>, ArrayList<String>>> locNonExpMap = new HashMap<>();
    // map from dataGroups to expLoc or nonExpLoc
    public HashMap<HashMap<HashMap<String, Integer>, Integer>, ArrayList<ArrayList<Integer>>> dataGroups2Col = new HashMap<>();
    // map from atom expression to idx of the atom expression: agg -> prop -> values -> demonstrationID -> expressionID -> idx in expression
    // map from expressionID to possible covering synthesized expression with ids in exprVars, together with data group idx
    // expID -> atomExpID ->(covering solution) [variableID]
    public HashMap<Integer, HashMap<Integer, HashSet<Integer>>> coverExprMap = new HashMap<>();
    // map from nonExprId to covering synthesized non expression object with ids in nonExprVars
    // nonExpID -> [(covering solution) variable]
    public HashMap<Integer, HashSet<Integer>> coverNonExprMap = new HashMap<>();

    // all nodes or edges from output (with aggregation or property info): aggregationOpr -> property -> NEIds
    public HashMap<String, HashMap<String, HashSet<String>>> singleData;
    // all nodes or edges from output (without aggregation or property info)
    public HashSet<String> NEs;
    // group target atom expressions: aggregation -> property -> expColID -> ArrayList<atomIdx>
    public HashMap<String, HashMap<String, HashMap<Integer, ArrayList<Integer>>>> groupedExpressions;
    // group target non-expressions: aggregationOpr -> property -> nonExpColID
    public HashMap<String, HashMap<String, ArrayList<Integer>>> groupedNonExpressions;
    // grouped data without aggregation operators or properties
    public HashSet<HashMap<String, Integer>> groupedDatas;

    //    expressionID -> atom object idx in expression
    public IntExpr[][] exprVars;
    //   property object ID
    public IntExpr[] nonExprVars;
    //    pathID
    public BoolExpr[] pathVars;

    public Context ctx = new Context();
    public Optimize optimizer = ctx.mkOptimize();
    public Model solution;

    //    To repairs (list of lambda locations)
    public HashMap<Integer, HashSet<Integer>> toRepairExprs = new HashMap<>();
    public HashSet<Integer> toRepairNonExprs = new HashSet<>();
    //    solutions
    public ArrayList<Integer> inclusions;
    public ArrayList<Integer> exclusions;
    public Integer[] nonRepairedNonExpressions; // nonExpID -> variableID
    public Integer[][] nonRepairedExpressions; // expID -> atomExpID -> variableID
    public Integer[] repairedNonExpressions; // nonExpID -> variableID
    public Integer[][] repairedExpressions; // expID -> atomExpID -> variableID    public Boolean nonExpressionRepairedSuccessfully = true;

    public Boolean synthesisCorrect;
    public HashMap<String, HashMap<String, HashMap<HashMap<String, Integer>, String>>> resultMap;
    public Integer resultUID;
    public HashMap<Integer, ArrayList<ArrayList<String>>> expressionEncoded;

    public HashMap<Integer, ArrayList<String>> selectedRowsData = new HashMap<>();

    public boolean hasNext() {
        if(optimizer.Check()== Status.SATISFIABLE){
            solution = optimizer.getModel();
            return true;
        }
        return false;
    }

    public void cleanUp(){
        synthesizedExpressions = new ArrayList<>();
        synthesizedProperties = new ArrayList<>();
        coverExprMap = new HashMap<>();
        coverNonExprMap = new HashMap<>();
        toRepairExprs = new HashMap<>();
        toRepairNonExprs = new HashSet<>();
        inclusions = new ArrayList<>();
        exclusions = new ArrayList<>();
        repairedNonExpressions = null; // nonExpID -> variableID
        nonRepairedNonExpressions = null; // nonExpID -> variableID
        repairedExpressions = null; // expID -> atomExpID -> variableID
        nonRepairedExpressions = null; // expID -> atomExpID -> variableID
        selectedRowsData = new HashMap<>();
        synthesisCorrect = true;
    }

    public void updateSelectedRows(){
        for(int i: inclusions){
            selectedRowsData.put(i, values.get(i));
        }
    }

    public void initiate(ArrayList<Demonstration> demonstrations, HashMap<String, ArrayList<String>> varName2Labels,
                         ArrayList<String> variableName, ArrayList<ArrayList<String>> values, Boolean analyzeAblation,
                         HashMap<String, Expression> expressions, HashMap<String, Property> nonExpressions){
        this.demonstrations = demonstrations;
        this.varName2Labels = varName2Labels;
        this.variableName = variableName;
        this.values = values;
        this.analyzeAblation = analyzeAblation;
        this.expressions = expressions; // valID -> Expression
        this.nonExpressions = nonExpressions; // valID -> Property

        PreprocessHelper preprocessor = new PreprocessHelper(demonstrations, variableName, values, varName2Labels,
                expressions, nonExpressions);
        preprocessor.preprocessMap12();
        preprocessor.preprocessMap3();
        preprocessor.preprocessCor();
        preprocessor.getInitialOptions();
        preprocessor.getPathPropertyValues();

        this.initialOptions = preprocessor.initialOptions;
        this.pathPropertyValues = preprocessor.pathPropertyValues;

        this.expressions = preprocessor.expressions;
        this.nonExpressions = preprocessor.nonExpressions;
        this.exampleNonExpMap = preprocessor.exampleNonExpMap;
        this.exampleExpMap = preprocessor.exampleExpMap;
        this.dataGroups2Col = preprocessor.dataGroups2Col;
        this.nonExpHole2Datas = preprocessor.nonExpHole2Datas;
        this.expHole2Datas = preprocessor.expHole2Datas;
        this.resultMap = preprocessor.resultMap;
        this.resultUID = preprocessor.resultUID;
        this.expressionEncoded = preprocessor.expressionEncoded;
        this.rowDataGroups = preprocessor.rowDataGroups;
        this.locExpMap = preprocessor.locExpMap;
        this.locNonExpMap = preprocessor.locNonExpMap;
        this.singleData = preprocessor.singleData;
        this.NEs = preprocessor.NEs;
        this.groupedExpressions = preprocessor.groupedExpressions;
        this.groupedNonExpressions = preprocessor.groupedNonExpressions;
        this.groupedDatas = preprocessor.groupedDatas;
        this.synthesisCorrect = true;

        if(exampleExpMap!=null) {
            for (int eID = 0; eID < exampleExpMap.size(); eID++) {
                for (int aID = 0; aID < exampleExpMap.get(eID).atoms.size(); aID++) {
                    String aggregationOpr = exampleExpMap.get(eID).atoms.get(aID).operator;
                    if (!aggregationOpr.equals("empty")) {
                        ArrayList<Integer> loc = new ArrayList<>(Arrays.asList(eID, aID));
                        aggregationColIDs.add(loc);
                    }
                }
            }
        }
    }

    /*
        expHoleLocations: expressionID -> number of atomExpressions
        exampleExpMap: expressionID -> example Expression
        exampleNonExpMap: nonExID -> example Property
     */
    public void generateInitialConstraints(){
        // Get example Expression or Property for each column
        HashMap<Integer, Expression> exampleExpMap = new HashMap<>(); // idx of expression related hole -> example expression
        HashMap<Integer, Property> exampleNonExpMap = new HashMap<>(); // idx of property related hole -> example property

        Demonstration exampleDemo = demonstrations.get(0);
        ArrayList<String> exampleRow = exampleDemo.correspondence.get(0);
        Integer expID = 0;
        Integer nonExpID = 0;
        for(String valueID: exampleRow){
            if(valueID.contains("exp")){
                // this valID maps to an Expression
                Expression exampleExpression = expressions.get(valueID);
                exampleExpMap.put(expID, exampleExpression);
                expID += 1;
            } else {
                // this valID maps to a Property
                Property exampleProperty = nonExpressions.get(valueID);
                exampleNonExpMap.put(nonExpID, exampleProperty);
                nonExpID += 1;
            }
        }

        exprVars = new IntExpr[exampleExpMap.size()][];
        nonExprVars = new IntExpr[exampleNonExpMap.size()];
        for (Integer expressionID: exampleExpMap.keySet()) {
            Expression expr = exampleExpMap.get(expressionID);
            exprVars[expressionID] = new IntExpr[expr.atoms.size()];
            for (Integer atomID = 0; atomID < expr.atoms.size(); atomID++) {
                Property atomObject = expr.atoms.get(atomID);

                exprVars[expressionID][atomID] = ctx.mkIntConst("e_" + expressionID + "_" + atomID);
                String propertyName = atomObject.propertyName;
                String dataID = atomObject.data.keySet().toArray(new String[0])[0];
                Integer dID = Integer.valueOf(dataID.split("_")[0].replace("d", ""));
                String labelName = "";
                if(dataID.split("_")[1].contains("n")){
                    labelName = demonstrations.get(dID).inputGraph.nodes.get(dataID.split("_")[1].replace("n", "")).label;
                } else {
                    labelName = demonstrations.get(dID).inputGraph.edges.get(dataID.split("_")[1].replace("e", "")).label;
                }
                BoolExpr[] tmp = new BoolExpr[initialOptions.get(labelName).size()];
                for (int optionID = 0; optionID < initialOptions.get(labelName).size(); optionID++) {
                    Integer variableOption = initialOptions.get(labelName).get(optionID);
                    tmp[optionID] = (ctx.mkEq(ctx.mkInt(variableOption), exprVars[expressionID][atomID]));
                }
                optimizer.Assert(ctx.mkOr(tmp));
            }
        }


        // Generate non-expression variables and initial constraints
        for(int propertyID=0; propertyID<exampleNonExpMap.size(); propertyID++){
            Property property = exampleNonExpMap.get(propertyID);

            nonExprVars[propertyID] = ctx.mkIntConst("ne_"+propertyID);
            String propertyName = property.propertyName;
            String dataID = property.data.keySet().toArray(new String[0])[0];
            Integer dID = Integer.valueOf(dataID.split("_")[0].replace("d", ""));
            String labelName = "";
            if(dataID.split("_")[1].contains("n")){
                labelName = demonstrations.get(dID).inputGraph.nodes.get(dataID.split("_")[1].replace("n", "")).label;
            } else {
                labelName = demonstrations.get(dID).inputGraph.edges.get(dataID.split("_")[1].replace("e", "")).label;
            }
            BoolExpr[] tmp = new BoolExpr[initialOptions.get(labelName).size()];
            for(int optionID=0; optionID<initialOptions.get(labelName).size(); optionID++){
                Integer variableOption = initialOptions.get(labelName).get(optionID);
                tmp[optionID] = ctx.mkEq(ctx.mkInt(variableOption), nonExprVars[propertyID]);
            }
            optimizer.Assert(ctx.mkOr(tmp));
        }



        pathVars = new BoolExpr[values.size()];
        for(int pathID=0; pathID<values.size(); pathID++){
            pathVars[pathID] = ctx.mkBoolConst("p_"+String.valueOf(pathID));
        }
        for(ArrayList<Integer> sameValuedPaths: pathPropertyValues.values()){
            if(sameValuedPaths.size()>1){
                BoolExpr[] allT = new BoolExpr[sameValuedPaths.size()];
                BoolExpr[] allF = new BoolExpr[sameValuedPaths.size()];
                for(int pathID=0; pathID<sameValuedPaths.size(); pathID++){
                    allT[pathID] = ctx.mkEq(ctx.mkBool(true), pathVars[sameValuedPaths.get(pathID)]);
                    allF[pathID] = ctx.mkEq(ctx.mkBool(false), pathVars[sameValuedPaths.get(pathID)]);
                }
                optimizer.Assert(ctx.mkOr(ctx.mkAnd(allT), ctx.mkAnd(allF)));
            }
        }

        // Add constraint that no all exclusion
        BoolExpr[] allF = new BoolExpr[values.size()];
        for(int pathID=0; pathID<values.size(); pathID++){
            allF[pathID] = ctx.mkEq(ctx.mkBool(false), pathVars[pathID]);
        }
        optimizer.Assert(ctx.mkNot(ctx.mkAnd(allF)));
    }

    public void Evaluate(Boolean needGroupBy){
        if(analyzeAblation){
            ArrayList<Boolean> correct = new ArrayList<>();
            HashMap<Integer, ArrayList<HashMap<String, Integer>>> groupedResult = new HashMap<>();
            if(needGroupBy){
                GroupByReturn groupByReturn = SketchCompletionHelper.groupBy(demonstrations, nonRepairedNonExpressions,
                        nonRepairedExpressions, exampleExpMap, exampleNonExpMap, selectedRowsData);
                groupedResult = groupByReturn.groupedByData;
            }
            for (int nonExpHoleID = 0; nonExpHoleID < nonExprVars.length; nonExpHoleID++) {
                if(!needGroupBy) {
                    correct.add(evalNonExpBeforeGroupBy(nonExpHoleID, nonRepairedNonExpressions[nonExpHoleID], needGroupBy));
                } else {
                    correct.add(evalNonExpAfterGroupBy(nonExpHoleID, nonRepairedNonExpressions[nonExpHoleID], groupedResult));
                }
            }
            for (int expHoleID = 0; expHoleID < exprVars.length; expHoleID++) {
                if(!needGroupBy) {
                    correct.add(evalExpBeforeGroupBy(expHoleID, nonRepairedExpressions[expHoleID], needGroupBy));
                } else {
                    correct.add(evalExpAfterGroupBy(expHoleID, nonRepairedExpressions[expHoleID], groupedResult));
                }
            }
            if(!correct.contains(false)){
                if(needGroupBy){
                    synthesisCorrect = evaluateRows(groupedResult);
                } else {
                    // If no need of grouping by, for each variableID, for each row, will be only HashMap<ID, 1>
                    groupedResult = noGroupBy(demonstrations, nonRepairedNonExpressions,
                            nonRepairedExpressions, exampleExpMap, exampleNonExpMap, selectedRowsData);
                    synthesisCorrect = evaluateRows(groupedResult);
                }
                if(synthesisCorrect){
                    // Write inside synthesized items
                    for (int nonExpHoleID = 0; nonExpHoleID < nonExprVars.length; nonExpHoleID++) {
                        Integer variableID = nonRepairedNonExpressions[nonExpHoleID];
                        String propertyName = exampleNonExpMap.get(nonExpHoleID).propertyName;
                        Property synthesizedProperty = new Property(propertyName, variableName.get(variableID));
                        synthesizedProperties.add(synthesizedProperty);
                    }
                    for(int expHoleID = 0; expHoleID < exprVars.length; expHoleID++){
                        Expression exampleExpression = exampleExpMap.get(expHoleID);
                        Property[] tmp = new Property[exampleExpression.atoms.size()];
                        for(Integer aID=0; aID<exampleExpression.atoms.size(); aID++){
                            Integer varId = nonRepairedExpressions[expHoleID][aID];
                            String propertyName = exampleExpression.atoms.get(aID).propertyName;
                            Property synthesizedProperty = new Property(propertyName, variableName.get(varId));
                            synthesizedProperty.operator = exampleExpression.atoms.get(aID).operator;
                            tmp[aID] = synthesizedProperty;
                        }
                        Expression synthesizedExpression = new Expression();
                        synthesizedExpression.symbols = exampleExpression.symbols;
                        synthesizedExpression.atoms = new ArrayList<>(Arrays.asList(tmp));
                        synthesizedExpressions.add(synthesizedExpression);
                    }
                }
            } else {
                synthesisCorrect = false;
            }
        } else {
            synthesisCorrect = EvaluateHelper(needGroupBy);
            if(synthesisCorrect){
                writeSolutionRepaired();
            }
        }
    }

    public Boolean EvaluateHelper(Boolean needGroupBy){
        HashMap<Integer, ArrayList<HashMap<String, Integer>>> groupedResult = new HashMap<>();
        synthesisCorrect = false; // Before evaluating via repairment, assume synthesis is not correct
        // Evaluate nonExpressions before&after group by
        // evalNonExpBeforeGroupBy
        for(int nonExpHoleID = 0; nonExpHoleID < nonExprVars.length; nonExpHoleID++){
            evalNonExpBeforeGroupBy(nonExpHoleID, nonRepairedNonExpressions[nonExpHoleID], needGroupBy);
        }
        // evalNonExpAfterGroupBy
        if(needGroupBy && nonExprVars.length>0){
            GroupByReturn groupByReturn =  SketchCompletionHelper.groupBy(demonstrations, nonRepairedNonExpressions,
                    nonRepairedExpressions, exampleExpMap, exampleNonExpMap, selectedRowsData);
            groupedResult = groupByReturn.groupedByData;
            for(int nonExpHoleID = 0; nonExpHoleID < nonExprVars.length; nonExpHoleID++) {
                // To find conflicts and update coverage map
                evalNonExpAfterGroupBy(nonExpHoleID, nonRepairedNonExpressions[nonExpHoleID], groupedResult);
            }
        }
        if(nonExprVars.length==0){
            // Only have expression holes
            EvaluateExpressionReuse(needGroupBy);
        }
        for(ArrayList<Integer> repairNonExpressions: repairNonExpression(nonExprVars.length, toRepairNonExprs,
                nonRepairedNonExpressions, coverNonExprMap)){
            // Update to synthesized nonExpressions
            Integer[] repaired = new Integer[repairNonExpressions.size()];
            for (int i = 0; i < repairNonExpressions.size(); i++) {
                repaired[i] = repairNonExpressions.get(i);
            }
            repairedNonExpressions = repaired;
            if(toRepairNonExprs.size()>0) {
                Boolean singleCorrect = true;
                for (int nonExpHoleID = 0; nonExpHoleID < nonExprVars.length; nonExpHoleID++) {
                    singleCorrect = evalNonExpBeforeGroupBy(nonExpHoleID, repairedNonExpressions[nonExpHoleID], needGroupBy);
                    if(!singleCorrect){
                        break;
                    }
                }
                // evalNonExpAfterGroupBy
                if (needGroupBy) {
                    GroupByReturn groupByReturn = SketchCompletionHelper.groupBy(demonstrations, repairedNonExpressions,
                            nonRepairedExpressions, exampleExpMap, exampleNonExpMap, selectedRowsData);
                    groupedResult = groupByReturn.groupedByData;
                    for (int nonExpHoleID = 0; nonExpHoleID < nonExprVars.length; nonExpHoleID++) {
                        // To find conflicts and update coverage map
                        singleCorrect = evalNonExpAfterGroupBy(nonExpHoleID, repairedNonExpressions[nonExpHoleID], groupedResult);
                        if(!singleCorrect){
                            break;
                        }
                    }
                }
                if(!singleCorrect){
                    continue;
                }
            }
            // Evaluate expression with and without grouping
            if(exprVars!=null && exprVars.length>0){
                EvaluateExpressionReuse(needGroupBy);
            } else {
                // Only have non expression holes
                // No need of grouping by here
                groupedResult = noGroupBy(demonstrations, repairedNonExpressions,
                        repairedExpressions, exampleExpMap, exampleNonExpMap, selectedRowsData);
                synthesisCorrect = evaluateRows(groupedResult);
            }
        }
        return synthesisCorrect;
    }


    public void EvaluateExpressionReuse(Boolean needGroupBy) {
        HashMap<Integer, ArrayList<HashMap<String, Integer>>> groupedResult = new HashMap<>();
        // Evaluate expression with and without grouping
        // evalExpBeforeGroupBy
        for (int expHoleID = 0; expHoleID < exprVars.length; expHoleID++) {
            // If no group by needed, update coverage map here
            evalExpBeforeGroupBy(expHoleID, nonRepairedExpressions[expHoleID], needGroupBy);
        }
        // evalExpAfterGroupBy
        if (needGroupBy) {
            GroupByReturn groupByReturn = SketchCompletionHelper.groupBy(demonstrations, repairedNonExpressions,
                    nonRepairedExpressions, exampleExpMap, exampleNonExpMap, selectedRowsData);
            groupedResult = groupByReturn.groupedByData;

            for (int expHoleID = 0; expHoleID < exprVars.length; expHoleID++) {
                evalExpAfterGroupBy(expHoleID, nonRepairedExpressions[expHoleID], groupedResult);
            }
        }

        for (Integer[][] repairExpression : repairExpressions(toRepairExprs, nonRepairedExpressions, coverExprMap)) {
            // Update repairedExpressions
            repairedExpressions = repairExpression;
            if(toRepairExprs.size()>0) {
                Boolean singleCorrect = true;
                for (int expHoleID = 0; expHoleID < exprVars.length; expHoleID++) {
                    // If no group by needed, update coverage map here
                    singleCorrect = evalExpBeforeGroupBy(expHoleID, repairedExpressions[expHoleID], needGroupBy);
                    if(!singleCorrect){
                        break;
                    }
                }
                // evalExpAfterGroupBy
                if (needGroupBy) {
                    GroupByReturn groupByReturn = SketchCompletionHelper.groupBy(demonstrations, repairedNonExpressions,
                            repairedExpressions, exampleExpMap, exampleNonExpMap, selectedRowsData);
                    groupedResult = groupByReturn.groupedByData;

                    for (int expHoleID = 0; expHoleID < exprVars.length; expHoleID++) {
                        singleCorrect = evalExpAfterGroupBy(expHoleID, repairedExpressions[expHoleID], groupedResult);
                        if(!singleCorrect){
                            break;
                        }
                    }
                }
                if(!singleCorrect){
                    continue;
                }
            }
            // EvaluateRows
            if (needGroupBy) {
                synthesisCorrect = evaluateRows(groupedResult);
            } else {
                // If no need of grouping by, for each variableID, for each row, will be only HashMap<ID, 1>
                groupedResult = noGroupBy(demonstrations, repairedNonExpressions,
                        repairedExpressions, exampleExpMap, exampleNonExpMap, selectedRowsData);
                synthesisCorrect = evaluateRows(groupedResult);
            }
            if(synthesisCorrect){
                break;
            }
        }
    }


    /*
        HashMap<dataGroupInRow, Integer> from grouped = HashMap<dataGroupInRow, Integer> from correspondence
    */
    public Boolean evaluateRows(HashMap<Integer, ArrayList<HashMap<String, Integer>>> groupedResult){
        // {value1: {{String: Integer}, Integer}, ..., value7: {{String: Integer}, Integer}}
        // If there is one dataGroupInRow from grouped is not in correspondence, add conflict of neg(including the subgraphs with all variables)
        // 1. Transform groupedResult table to HashMap<Integer, HashMap<HashMap<HashMap<String, Integer>, Integer>, Integer>>
        HashMap<Integer, HashMap<HashMap<HashMap<String, Integer>, Integer>, Integer>> synthesized = new HashMap<>();
        Integer rowsNum = ((ArrayList) groupedResult.values().toArray()[0]).size();
        for(Integer nonEVarID: repairedNonExpressions){
            for(int rowID=0; rowID<groupedResult.get(nonEVarID).size(); rowID++){
                HashMap<String, Integer> dataGroup = groupedResult.get(nonEVarID).get(rowID);
                for(String val: dataGroup.keySet()){
                    dataGroup.replace(val, 1);
                }
                HashMap<HashMap<String, Integer>, Integer> dataGroupsInVal = new HashMap<>();
                dataGroupsInVal.put(dataGroup, 1);
                // add dataGroupsInVal to row map
                if(!synthesized.containsKey(rowID)){
                    synthesized.put(rowID, new HashMap<>());
                }
                if(!synthesized.get(rowID).containsKey(dataGroupsInVal)){
                    synthesized.get(rowID).put(dataGroupsInVal, 0);
                }
                synthesized.get(rowID).put(dataGroupsInVal, synthesized.get(rowID).get(dataGroupsInVal)+1);
            }
        }
        for(int rowID=0; rowID<rowsNum; rowID++){
            for(int eID=0; eID<repairedExpressions.length; eID++){
                HashMap<HashMap<String, Integer>, Integer> dataGroupsInVal = new HashMap<>();
                for(int aID=0; aID<repairedExpressions[eID].length; aID++){
                    HashMap<String, Integer> dataGroup = groupedResult.get(repairedExpressions[eID][aID]).get(rowID);
                    String aggregationOpr = exampleExpMap.get(eID).atoms.get(aID).operator;
                    HashMap<String, Integer> tmp = new HashMap<>();
                    if(aggregationOpr.equals("max") || aggregationOpr.equals("min")){
                        for(String val: dataGroup.keySet()){
                            tmp.put(val, 1);
                        }
                    } else {
                        for(String val: dataGroup.keySet()){
                            tmp.put(val, dataGroup.get(val));
                        }
                    }
                    if(!dataGroupsInVal.containsKey(tmp)){
                        dataGroupsInVal.put(tmp, 0);
                    }
                    dataGroupsInVal.put(tmp, dataGroupsInVal.get(tmp)+1);
                }
                // add dataGroupsInVal to row map
                if(!synthesized.containsKey(rowID)){
                    synthesized.put(rowID, new HashMap<>());
                }
                if(!synthesized.get(rowID).containsKey(dataGroupsInVal)){
                    synthesized.get(rowID).put(dataGroupsInVal, 0);
                }
                synthesized.get(rowID).put(dataGroupsInVal, synthesized.get(rowID).get(dataGroupsInVal)+1);
            }
        }

        // 2. check whether each row of rowDataGroups is inside transformed groupedResult
        Boolean noExtraData = true;
        for(HashMap<HashMap<HashMap<String, Integer>, Integer>, Integer> row: synthesized.values()){
            if(!rowDataGroups.values().contains(row)){
                noExtraData = false;
            }
        }

        // 3. check whether each row of transformed groupedResult is inside rowDataGroups
        Boolean noMissingData = true;
        for(HashMap<HashMap<HashMap<String, Integer>, Integer>, Integer> row: rowDataGroups.values()){
            if(!synthesized.values().contains(row)){
                noMissingData = false;
                break;
            }
        }
        return noMissingData&&noExtraData;
    }

    public void writeSolutionRepaired(){
        // Write inside synthesized items
        for (int nonExpHoleID = 0; nonExpHoleID < nonExprVars.length; nonExpHoleID++) {
            Integer variableID = repairedNonExpressions[nonExpHoleID];
            String propertyName = exampleNonExpMap.get(nonExpHoleID).propertyName;
            Property synthesizedProperty = new Property(propertyName, variableName.get(variableID));
            synthesizedProperties.add(synthesizedProperty);
        }
        for(int expHoleID = 0; expHoleID < exprVars.length; expHoleID++){
            Expression exampleExpression = exampleExpMap.get(expHoleID);
            Property[] tmp = new Property[exampleExpression.atoms.size()];
            for(Integer aID=0; aID<exampleExpression.atoms.size(); aID++){
                Integer varId = repairedExpressions[expHoleID][aID];
                String propertyName = exampleExpression.atoms.get(aID).propertyName;
                Property synthesizedProperty = new Property(propertyName, variableName.get(varId));
                synthesizedProperty.operator = exampleExpression.atoms.get(aID).operator;
                tmp[aID] = synthesizedProperty;
            }
            Expression synthesizedExpression = new Expression();
            synthesizedExpression.symbols = exampleExpression.symbols;
            synthesizedExpression.atoms = new ArrayList<>(Arrays.asList(tmp));
            synthesizedExpressions.add(synthesizedExpression);
        }
    }

    /*
     Evaluate an atom expression located at expLoc, with current enumerated result currModel;
     Before group by, this evaluation is to check whether single node or edge is inside output;
     currModel include a list variableID each for one atom expression

     return true or false indicating whether before grouping, the enumeration on expression is correct or not;
     If not correct, add to repairment list.
  */
    public Boolean evalExpBeforeGroupBy(Integer eHoleID, Integer[] currModel, Boolean needGroupBy){
        Boolean expressionCorrect = true;
        for(Integer atomModelID=0; atomModelID<currModel.length; atomModelID++){
            ArrayList<Integer> loc = new ArrayList<>(Arrays.asList(eHoleID, atomModelID));
            Integer variableID = currModel[atomModelID];
            String propertyName = exampleExpMap.get(eHoleID).atoms.get(atomModelID).propertyName;
            String aggregationOpr = exampleExpMap.get(eHoleID).atoms.get(atomModelID).operator;
            HashMap<HashMap<String, Integer>, Integer> targetDataGroups = expHole2Datas.get(eHoleID).get(atomModelID);
            HashMap<String, Integer> flattened = flattenDataGroup(targetDataGroups);

            HashMap<String, Integer> colData = new HashMap<>();
            Boolean continueCheck1 = true;
            HashMap<HashMap<String, Integer>, Integer> groupedPVar = new HashMap<>();
            for(Integer pathID: selectedRowsData.keySet()){
                String NEId = selectedRowsData.get(pathID).get(variableID);
                if(!colData.containsKey(NEId)){
                    colData.put(NEId, 0);
                }
                colData.put(NEId, colData.get(NEId) + 1);

                // Prepare for updating coverage map
                HashMap<String, Integer> groupedVar = new HashMap<>();
                groupedVar.put(NEId, 1);
                if(!groupedPVar.containsKey(groupedVar)){
                    groupedPVar.put(groupedVar, 0);
                }
                groupedPVar.put(groupedVar, groupedPVar.get(groupedVar) + 1);

//                Check whether NEId in expected nodes or edges
                if(!this.NEs.contains(NEId)){
                    continueCheck1 = false;
                    if(!analyzeAblation){
                        add1Conflict(variableID, pathID);
                    }
                } else if(!this.singleData.get(aggregationOpr).get(propertyName).contains(NEId)){
                    // Check whether NEId with property and aggregation is part of expected objects
                    continueCheck1 = false;
                    HashMap<Integer, ArrayList<Integer>> inExprVars = groupedExpressions.get(aggregationOpr).get(propertyName);
                    ArrayList<Integer> inNonExprVars = new ArrayList<>();

                    if(!analyzeAblation) {
                        add2Conflict(variableID, pathID, inExprVars, inNonExprVars);
                    }
                }
            }
            if(!continueCheck1){
//                synthesisCorrect = false;
                expressionCorrect = false;
            }
            Boolean includeData = true;
            if(continueCheck1){
                // Check whether lack of data
                for(String NEId: flattened.keySet()){
                    if(!colData.containsKey(NEId)){
                        includeData = false;
                    } else if(colData.get(NEId) < flattened.get(NEId)){
                        includeData = false;
                    }
                }
            }
            if(continueCheck1 && !includeData){
//                synthesisCorrect = false;
                expressionCorrect = false;
                ArrayList<ArrayList<Integer>> locs = new ArrayList<>();
                locs.add(loc);
            }
            if(!continueCheck1 || !includeData){
                if(!toRepairExprs.containsKey(eHoleID)){
                    toRepairExprs.put(eHoleID, new HashSet<>());
                }
                toRepairExprs.get(eHoleID).add(atomModelID);
            }
            // If no group by needed, update coverage map here
            // eID -> atomModelID -> [NEid as dataCnt]
            if(continueCheck1 && !needGroupBy && dataGroups2Col.get(groupedPVar)!=null && !analyzeAblation){
                for(ArrayList<Integer> idxs: dataGroups2Col.get(groupedPVar)){
                    if(idxs.size()==2){
                        // cover a hole for expression
                        Integer eID = idxs.get(0);
                        Integer aID = idxs.get(1);
                        if (!coverExprMap.containsKey(eID)) {
                            coverExprMap.put(eID, new HashMap<>());
                        }
                        if (!coverExprMap.get(eID).containsKey(aID)) {
                            coverExprMap.get(eID).put(aID, new HashSet<>());
                        }
                        coverExprMap.get(eID).get(aID).add(variableID);
                    } else {
                        // covers a hole for non-expression
                        Integer nonEID = idxs.get(0);
                        if (!coverNonExprMap.containsKey(nonEID)) {
                            coverNonExprMap.put(nonEID, new HashSet<>());
                        }
                        coverNonExprMap.get(nonEID).add(variableID);
                    }
                }
            }
        }
        return expressionCorrect;
    }

    public Boolean evalNonExpBeforeGroupBy(Integer nonEHoleID, Integer variableID, Boolean needGroupBy){
        Property exampleProperty = exampleNonExpMap.get(nonEHoleID);
        String propertyName = exampleProperty.propertyName;
        String aggregationOpr = "empty";
        HashMap<HashMap<String, Integer>, Integer> dataGroups = nonExpHole2Datas.get(nonEHoleID);
        HashMap<String, Integer> flattenedData = flattenDataGroup(dataGroups);

        HashMap<String, Integer> coveredData = new HashMap<>();
        Boolean extraDataIncluded = false;
        HashMap<HashMap<String, Integer>, Integer> groupedPVar = new HashMap<>();
        for(Integer pathID: selectedRowsData.keySet()){
            String NEId = selectedRowsData.get(pathID).get(variableID);
            if(!coveredData.containsKey(NEId)){
                coveredData.put(NEId, 0);
            }
            coveredData.put(NEId, coveredData.get(NEId)+1);

            // Prepare for updating coverage map
            HashMap<String, Integer> groupedVar = new HashMap<>();
            groupedVar.put(NEId, 1);
            if(!groupedPVar.containsKey(groupedVar)){
                groupedPVar.put(groupedVar, 0);
            }
            groupedPVar.put(groupedVar, groupedPVar.get(groupedVar) + 1);

            Boolean continueCheck1 = true;
//            1. Check whether NEId without aggregation is inside demonstrations
            if(!NEs.contains(NEId)){
                continueCheck1 = false;
                extraDataIncluded = true;
                if(!analyzeAblation) {
                    add1Conflict(variableID, pathID);
                }
            }
//            2. Check whether NEId with aggregation is inside demonstrations
            if(continueCheck1){
                if(!singleData.get("empty").get(propertyName).contains(NEId)){
                    extraDataIncluded = true;
                    HashMap<Integer, ArrayList<Integer>> inExprVars = new HashMap<>();
                    ArrayList<Integer> inNonExprVars = groupedNonExpressions.get(aggregationOpr).get(propertyName);
                    if(!analyzeAblation) {
                        add2Conflict(variableID, pathID, inExprVars, inNonExprVars);
                    }
                }
            }
        }
        if(extraDataIncluded){
            toRepairNonExprs.add(nonEHoleID);
        }
        Boolean includeData = true;
        if(!extraDataIncluded){
            // If no group by needed, update coverage map here
            if(!needGroupBy && dataGroups2Col.get(groupedPVar)!=null && !analyzeAblation){
                for(ArrayList<Integer> idxs: dataGroups2Col.get(groupedPVar)){
                    if(idxs.size()==2){
                        // covers a hole for expression
                        Integer eID = idxs.get(0);
                        Integer aID = idxs.get(1);
                        if (!coverExprMap.containsKey(eID)) {
                            coverExprMap.put(eID, new HashMap<>());
                        }
                        if (!coverExprMap.get(eID).containsKey(aID)) {
                            coverExprMap.get(eID).put(aID, new HashSet<>());
                        }
                        coverExprMap.get(eID).get(aID).add(variableID);
                    } else {
                        // covers a hole for non-expression
                        Integer nonEID = idxs.get(0);
                        if (!coverNonExprMap.containsKey(nonEID)) {
                            coverNonExprMap.put(nonEID, new HashSet<>());
                        }
                        coverNonExprMap.get(nonEID).add(variableID);
                    }
                }
            }

//          3.  Check whether lack of data before grouping
            for(String NEId: flattenedData.keySet()){
                if(!coveredData.containsKey(NEId)){
                    includeData = false;
                } else if(coveredData.get(NEId) < flattenedData.get(NEId)){
                    includeData = false;
                }
            }
        }
        if(extraDataIncluded || !includeData){
            toRepairNonExprs.add(nonEHoleID);
            return false;
        }
        return true;
    }

    public Boolean evalExpAfterGroupBy(Integer eHoleID, Integer[] currModel,
                                       HashMap<Integer, ArrayList<HashMap<String, Integer>>> groupedByResult) {
        // check whether current solution is correct after grouping by
        Boolean evaluationCorrect = true;
        Boolean correctAfterGroupBy = true; // exit checking for all grouped data if found data group outside demonstration output
        ArrayList<Integer> loc1 = new ArrayList<>(Arrays.asList(eHoleID));
        // Encode evaluated result of each row
        HashMap<Integer, ArrayList<String>> resultsP = new HashMap<>();


        // Get rid of demonstrationID here
        for (Integer atomModelID = 0; atomModelID < currModel.length; atomModelID++) {
            Integer variableID = currModel[atomModelID];
            Integer groupID = 0;
            String propertyName = exampleExpMap.get(eHoleID).atoms.get(atomModelID).propertyName;
            String aggregationOpr = exampleExpMap.get(eHoleID).atoms.get(atomModelID).operator;
            for (HashMap<String, Integer> groupedData : groupedByResult.get(variableID)) {
                HashMap<String, Integer> tmp = new HashMap<>();
                if(aggregationOpr.equals("max") || aggregationOpr.equals("min")){
                    for(String val: groupedData.keySet()){
                        tmp.put(val, 1);
                    }
                } else {
                    for(String val: groupedData.keySet()){
                        tmp.put(val, groupedData.get(val));
                    }
                }
                if(!resultMap.containsKey(aggregationOpr)){
                    resultMap.put(aggregationOpr, new HashMap<>());
                }
                if(!resultMap.get(aggregationOpr).containsKey(propertyName)){
                    resultMap.get(aggregationOpr).put(propertyName, new HashMap<>());
                }
                if(!resultMap.get(aggregationOpr).get(propertyName).containsKey(tmp)){
                    resultMap.get(aggregationOpr).get(propertyName).put(tmp, String.valueOf(resultUID));
                    resultUID += 1;
                }
                if(!resultsP.containsKey(groupID)){
                    resultsP.put(groupID, new ArrayList<>());
                }
                resultsP.get(groupID).add(resultMap.get(aggregationOpr).get(propertyName).get(tmp));

                groupID++;
                Boolean dataGroupInDemonstration = false;
                for (HashMap<String, Integer> outputGroupedData : groupedDatas) {
                    if (outputGroupedData.equals(tmp)) {
                        dataGroupInDemonstration = true;
                        break;
                    }
                }
                if (!dataGroupInDemonstration) {
                    //  Add conflict when data group without operators not in output
                    correctAfterGroupBy = false;
                    evaluationCorrect = false;
                    if (!analyzeAblation) {
                        add4Conflict();
                    }
                    break;
                }
                if (dataGroupInDemonstration && !locExpMap.get(aggregationOpr).get(propertyName).containsKey(tmp)) {
                    //  Add conflict when data group with operators not in output
                    correctAfterGroupBy = false;
                    evaluationCorrect = false;
                    if (!analyzeAblation) {
                        add5Conflict(aggregationOpr, propertyName);
                    }
                    break;
                }
            }

            // Check whether after grouping, all data groups for the column is included (exp2HoleData)
            HashMap<HashMap<String, Integer>, Integer> groupedPVar = new HashMap<>();
            for(HashMap<String, Integer> dataGroup: groupedByResult.get(variableID)){
                HashMap<String, Integer> tmp = new HashMap<>();
                if(aggregationOpr.equals("max") || aggregationOpr.equals("min")){
                    for(String val: dataGroup.keySet()){
                        tmp.put(val, 1);
                    }
                } else {
                    for(String val: dataGroup.keySet()){
                        tmp.put(val, dataGroup.get(val));
                    }
                }
                if(!groupedPVar.containsKey(tmp)){
                    groupedPVar.put(tmp, 0);
                }
                groupedPVar.put(tmp, groupedPVar.get(tmp)+1);
            }
            if (!expHole2Datas.get(eHoleID).get(atomModelID).equals(groupedPVar)) {
                evaluationCorrect = false;
            }
            // Update to repair list
            if(!evaluationCorrect){
                if(!toRepairExprs.containsKey(eHoleID)){
                    toRepairExprs.put(eHoleID, new HashSet<>());
                }
                toRepairExprs.get(eHoleID).add(atomModelID);
            }

            if (correctAfterGroupBy && dataGroups2Col.get(groupedPVar)!=null && !analyzeAblation) {
                //  If does not include data group outside demonstration output, update coverage map
                for(ArrayList<Integer> idxs: dataGroups2Col.get(groupedPVar)){
                    if(idxs.size()==2){
                        // cover a hole for expression
                        Integer eID = idxs.get(0);
                        Integer aID = idxs.get(1);
                        if (!coverExprMap.containsKey(eID)) {
                            coverExprMap.put(eID, new HashMap<>());
                        }
                        if (!coverExprMap.get(eID).containsKey(aID)) {
                            coverExprMap.get(eID).put(aID, new HashSet<>());
                        }
                        coverExprMap.get(eID).get(aID).add(variableID);
                    } else {
                        // covers a hole for non-expression
                        Integer nonEID = idxs.get(0);
                        if (!coverNonExprMap.containsKey(nonEID)) {
                            coverNonExprMap.put(nonEID, new HashSet<>());
                        }
                        coverNonExprMap.get(nonEID).add(variableID);
                    }
                }
            }
        }

        if(evaluationCorrect){
            // compare each expression with target expressions when expression contains symbols +, -, *, /
            if(exampleExpMap.get(eHoleID).symbols!=null && exampleExpMap.get(eHoleID).symbols.size()>0){
                ArrayList<ArrayList<String>> targetExps = expressionEncoded.get(eHoleID);
                for(Integer i: resultsP.keySet()){
                    ArrayList<String> resultRow = new ArrayList<>();
                    for(int j=0; j<resultsP.get(i).size(); j++){
                        resultRow.add(resultsP.get(i).get(j));
                        if(j < exampleExpMap.get(eHoleID).symbols.size()){
                            resultRow.add(exampleExpMap.get(eHoleID).symbols.get(j));
                        }
                    }
                    // Find possible comparison with target expressions
                    Boolean sameExpressionFound = false;
                    for(ArrayList<String> targetCandidate: targetExps){
                        if(sameExpression(new Context(), targetCandidate, resultRow)){
                            sameExpressionFound = true;
                            break;
                        }
                    }
                    if(!sameExpressionFound){
                        evaluationCorrect = false;
                    }
                }
            }
        }
        return evaluationCorrect;
    }

    public Boolean evalNonExpAfterGroupBy(Integer nonEID, Integer variableID,
                                          HashMap<Integer, ArrayList<HashMap<String, Integer>>> groupedByResult){
        // check whether current solution is correct after grouping by
        Boolean evaluationCorrect = true;
        Boolean correctAfterGroupBy = true; // exit checking for all grouped data if found data group outside demonstration output


        String propertyName = exampleNonExpMap.get(nonEID).propertyName;
        String aggregationOpr = "empty";
        HashMap<HashMap<String, Integer>, Integer> groupedPVar = new HashMap<>();
        for (HashMap<String, Integer> groupedData: groupedByResult.get(variableID)) {
            for(String val: groupedData.keySet()){
                groupedData.replace(val, 1);
            }
            Boolean dataGroupInDemonstration = false;
            for (HashMap<String, Integer> outputGroupedData: groupedDatas) {
                if (outputGroupedData.equals(groupedData)) {
                    dataGroupInDemonstration = true;
                    break;
                }
            }
            if (!dataGroupInDemonstration) {
                //  Add conflict when data group without operators not in output
                correctAfterGroupBy = false;
                evaluationCorrect = false;
                if (!analyzeAblation) {
                    add4Conflict();
                }
                break;
            }
            if (dataGroupInDemonstration && !locNonExpMap.get(propertyName).containsKey(groupedData)) {
                //  Add conflict when data group with operators not in output
                correctAfterGroupBy = false;
                evaluationCorrect = false;
                if (!analyzeAblation) {
                    add5Conflict(aggregationOpr, propertyName);
                }
                break;
            }

            if(!groupedPVar.containsKey(groupedData)){
                groupedPVar.put(groupedData, 0);
            }
            groupedPVar.put(groupedData, groupedPVar.get(groupedData)+1);
        }
        // Check whether after grouping, all data groups for the column is included (exp2HoleData)
        if (!nonExpHole2Datas.get(nonEID).equals(groupedPVar)) {
            evaluationCorrect = false;
        }
        // Update to repair list
        if(!evaluationCorrect){
            toRepairNonExprs.add(nonEID);
        }

        if (correctAfterGroupBy && dataGroups2Col.get(groupedPVar)!=null && !analyzeAblation) {
            //  If does not include data group outside demonstration output, update coverage map
            for(ArrayList<Integer> idxs: dataGroups2Col.get(groupedPVar)){
                if(idxs.size()==2){
                    // cover a hole for expression
                    Integer eID = idxs.get(0);
                    Integer aID = idxs.get(1);
                    if (!coverExprMap.containsKey(eID)) {
                        coverExprMap.put(eID, new HashMap<>());
                    }
                    if (!coverExprMap.get(eID).containsKey(aID)) {
                        coverExprMap.get(eID).put(aID, new HashSet<>());
                    }
                    coverExprMap.get(eID).get(aID).add(variableID);
                } else {
                    // covers a hole for non-expression
                    Integer propID = idxs.get(0);
                    if (!coverNonExprMap.containsKey(propID)) {
                        coverNonExprMap.put(propID, new HashSet<>());
                    }
                    coverNonExprMap.get(propID).add(variableID);
                }
            }
        }
        return evaluationCorrect;
    }


    /*
        Add constraints for wrong option (1st)
     */
    public void add1Conflict(Integer variableID, Integer pathID){
        ArrayList<BoolExpr> tmp = new ArrayList<>();
        for (Integer expressionID = 0; expressionID < exprVars.length; expressionID++) {
            Expression exampleExpression = exampleExpMap.get(expressionID);
            for (Integer atomExprID = 0; atomExprID < exprVars[expressionID].length; atomExprID++) {
                // Get the property name from example expression
//                String propertyName = exampleExpression.atoms.get(atomExprID).propertyName;
                String dataID = exampleExpression.atoms.get(atomExprID).data.keySet().toArray(new String[0])[0];
                Integer dID = Integer.valueOf(dataID.split("_")[0].replace("d", ""));
                String labelName = "";
                if(dataID.split("_")[1].contains("n")){
                    labelName = demonstrations.get(dID).inputGraph.nodes.get(dataID.split("_")[1].replace("n", "")).label;
                } else {
                    labelName = demonstrations.get(dID).inputGraph.edges.get(dataID.split("_")[1].replace("e", "")).label;
                }
                if (initialOptions.get(labelName).contains(variableID)) {
                    tmp.add(ctx.mkNot(ctx.mkAnd(ctx.mkEq(exprVars[expressionID][atomExprID], ctx.mkInt(variableID)),
                            ctx.mkEq(pathVars[pathID], ctx.mkBool(true)))));
                }
            }
        }
        for(Integer nonExpressionID=0; nonExpressionID<nonExprVars.length; nonExpressionID++){
            String dataID = exampleNonExpMap.get(nonExpressionID).data.keySet().toArray(new String[0])[0];
            Integer dID = Integer.valueOf(dataID.split("_")[0].replace("d", ""));
            String labelName = "";
            if(dataID.split("_")[1].contains("n")){
                labelName = demonstrations.get(dID).inputGraph.nodes.get(dataID.split("_")[1].replace("n", "")).label;
            } else {
                labelName = demonstrations.get(dID).inputGraph.edges.get(dataID.split("_")[1].replace("e", "")).label;
            }
            if(initialOptions.get(labelName).contains(variableID)){
                tmp.add(ctx.mkNot(ctx.mkAnd(ctx.mkEq(nonExprVars[nonExpressionID], ctx.mkInt(variableID)),
                        ctx.mkEq(pathVars[pathID], ctx.mkBool(true)))));
            }
        }


        BoolExpr[] tmp1 = new BoolExpr[tmp.size()];
        for(int tmpID=0; tmpID<tmp.size(); tmpID++){
            tmp1[tmpID] = tmp.get(tmpID);
        }
        optimizer.Assert(ctx.mkAnd(tmp1));
    }

    /*
        Add constraints for wrong option (2nd)
     */
    public void add2Conflict(Integer variableID, Integer pathID, HashMap<Integer, ArrayList<Integer>> inExprVars,
                             ArrayList<Integer> inNonExprVars){
        ArrayList<BoolExpr> tmp = new ArrayList<>();
        for(Integer expressionID: inExprVars.keySet()){
            for(Integer atomIdx :inExprVars.get(expressionID)){
                tmp.add(ctx.mkNot(ctx.mkAnd(ctx.mkEq(ctx.mkBool(true), pathVars[pathID]),
                        ctx.mkEq(ctx.mkInt(variableID), exprVars[expressionID][atomIdx]))));
            }
        }

        for(Integer nonExprID: inNonExprVars){
            tmp.add(ctx.mkNot(ctx.mkAnd(ctx.mkEq(ctx.mkBool(true), pathVars[pathID]),
                    ctx.mkEq(ctx.mkInt(variableID), nonExprVars[nonExprID]))));
        }


        BoolExpr[] tmp1 = new BoolExpr[tmp.size()];
        for(int tmpID=0; tmpID<tmp.size(); tmpID++){
            tmp1[tmpID] = tmp.get(tmpID);
        }
        optimizer.Assert(ctx.mkAnd(tmp1));
    }


    /*
        Add constraints for wrong option (4th)
        All below conflicts are based on repaired non-expression lambdas
        For all blanks with aggregation, not to include this variable with grouping keys
    */
    public void add4Conflict(){
        ArrayList<BoolExpr> tmp = new ArrayList<>();
        for(int nonExpID=0; nonExpID<repairedNonExpressions.length; nonExpID++){
            tmp.add(ctx.mkEq(nonExprVars[nonExpID], ctx.mkInt(repairedNonExpressions[nonExpID])));
        }
        for(int inclusionID: inclusions){
            tmp.add(ctx.mkEq(ctx.mkBool(true), this.pathVars[inclusionID]));
        }
        for(int exclusionID: exclusions){
            tmp.add(ctx.mkEq(ctx.mkBool(false), this.pathVars[exclusionID]));
        }
        BoolExpr[] tmp1 = new BoolExpr[tmp.size()];
        for(int tmpID=0; tmpID<tmp.size(); tmpID++){
            tmp1[tmpID] = tmp.get(tmpID);
        }
        BoolExpr basicConstraint = ctx.mkAnd(tmp1);

        for(ArrayList<Integer> Idxs: aggregationColIDs){
            int eID = Idxs.get(0);
            int aID = Idxs.get(1);
            BoolExpr aggConstraint = ctx.mkEq(exprVars[eID][aID], ctx.mkInt(nonRepairedExpressions[eID][aID]));
            optimizer.Assert(ctx.mkNot(ctx.mkAnd(aggConstraint, basicConstraint)));
        }
    }

    /*
        Add constraints for wrong option (5th)
    */
    public void add5Conflict(String operator, String property){
        ArrayList<BoolExpr> tmp = new ArrayList<>();
        for(int nonExpID=0; nonExpID<repairedNonExpressions.length; nonExpID++){
            tmp.add(ctx.mkEq(nonExprVars[nonExpID], ctx.mkInt(repairedNonExpressions[nonExpID])));
        }

        for(int inclusionID: inclusions){
            tmp.add(ctx.mkEq(ctx.mkBool(true), this.pathVars[inclusionID]));
        }
        for(int exclusionID: exclusions){
            tmp.add(ctx.mkEq(ctx.mkBool(false), this.pathVars[exclusionID]));
        }
        BoolExpr[] tmp1 = new BoolExpr[tmp.size()];
        for(int tmpID=0; tmpID<tmp.size(); tmpID++){
            tmp1[tmpID] = tmp.get(tmpID);
        }
        BoolExpr basicConstraint = ctx.mkAnd(tmp1);

        if(operator.equals("empty")){
            optimizer.Assert(ctx.mkNot(basicConstraint));
        } else {
            for(int eColID: groupedExpressions.get(operator).get(property).keySet()){
                for(int aID: groupedExpressions.get(operator).get(property).get(eColID)){
                    BoolExpr aggConstraint = ctx.mkEq(exprVars[eColID][aID], ctx.mkInt(nonRepairedExpressions[eColID][aID]));
                    optimizer.Assert(ctx.mkNot(ctx.mkAnd(aggConstraint, basicConstraint)));
                }
            }
        }
    }


    public void removeCurrentModel(){
        ArrayList<BoolExpr> tmp = new ArrayList<>();

        for(int i=0; i<nonRepairedExpressions.length; i++){
            for(int j=0; j<nonRepairedExpressions[i].length; j++){
                tmp.add(ctx.mkEq(exprVars[i][j], ctx.mkInt(nonRepairedExpressions[i][j])));
            }
        }
        for(int i=0; i<nonRepairedNonExpressions.length; i++){
            tmp.add(ctx.mkEq(nonExprVars[i], ctx.mkInt(nonRepairedNonExpressions[i])));
        }
        for(int pathID: inclusions){
            tmp.add(ctx.mkEq(ctx.mkBool(true), pathVars[pathID]));
        }
        for(int pathID: exclusions){
            tmp.add(ctx.mkEq(ctx.mkBool(false), pathVars[pathID]));
        }

        BoolExpr[] tmp1 = new BoolExpr[tmp.size()];
        for(int tmpID=0; tmpID<tmp.size(); tmpID++){
            tmp1[tmpID] = tmp.get(tmpID);
        }

        optimizer.Assert(ctx.mkNot(ctx.mkAnd(tmp1)));
    }

    public void addSoftConstraint(){
        for(int pathID=0; pathID<pathVars.length; pathID++){
            optimizer.AssertSoft(ctx.mkEq(ctx.mkBool(true), pathVars[pathID]), 1, String.valueOf(pathID));
        }
    }

    public static class CompletionReturn{
        public String expressionStrings;
        public String nonExpressionStrings;
        public ArrayList<Integer> toInclude;
        public ArrayList<Integer> toExclude;

        public CompletionReturn(ArrayList<Integer> toExclude, ArrayList<Integer> toInclude,
                                String nonExpressionStrings, String expressionStrings) {
            this.toExclude = toExclude;
            this.toInclude = toInclude;
            this.nonExpressionStrings = nonExpressionStrings;
            this.expressionStrings = expressionStrings;
        }
    }

    public CompletionReturn transform(){
//        Transform each property to string
        String expressionStrings = expressionToString(synthesizedExpressions);
//        Transform each expression to string
        String nonExpressionStrings = nonExpressionsToString(synthesizedProperties);
        return new CompletionReturn(exclusions, inclusions, nonExpressionStrings, expressionStrings);
    }

    /*
        Check whether one expression satisfy syntax requirements given all grouping keys
     */
    public Boolean checkSyntax(Expression expression){
        Boolean hasAggregation = false;
        for(Property atom: expression.atoms){
            if(atom.operator != null && !atom.operator.equals("empty")){
                hasAggregation = true;
            }
        }
        if(hasAggregation){}
        return false;
    }
}