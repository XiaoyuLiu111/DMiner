package synth.core.QuerySketchSyn;

import com.microsoft.z3.*;
import synth.ast.pred.expr.Property;
import synth.core.data.dataStructures.Demonstration;
import synth.core.data.dataStructures.Expression;

import java.lang.reflect.Array;
import java.util.*;

public class SketchCompletionHelper {
    public static class GroupByReturn{
        public HashMap<Integer, ArrayList<HashMap<String, Integer>>> groupedByData;
        public HashMap<Integer, HashSet<Integer>> groupedRow2SubgraphID;
        public ArrayList<ArrayList<Integer>> aggregationCols;

        public GroupByReturn(HashMap<Integer, ArrayList<HashMap<String, Integer>>> groupedByData,
                             ArrayList<ArrayList<Integer>> aggregationCols,
                             HashMap<Integer, HashSet<Integer>> groupedRow2SubgraphID) {
            this.groupedByData = groupedByData;
            this.aggregationCols = aggregationCols;
            this.groupedRow2SubgraphID = groupedRow2SubgraphID;
        }
    }

    public static HashMap<Integer, ArrayList<HashMap<String, Integer>>> noGroupBy(ArrayList<Demonstration> demonstrations,
                                                                                                Integer[] nonExpModel,
                                                                                                Integer[][] expModel,
                                                                                                HashMap<Integer, Expression> exampleExpMap,
                                                                                                HashMap<Integer, Property> exampleNonExpMap,
                                                                                                HashMap<Integer, ArrayList<String>> selectedRowsData){

        HashMap<Integer, ArrayList<HashMap<String, Integer>>> noGroupByResult = new HashMap<>();
        HashSet<Integer> varIDs = new HashSet<>();
        for(int eID=0; eID<expModel.length; eID++){
            for (int aID=0; aID<expModel[eID].length; aID++){
                varIDs.add(expModel[eID][aID]);
            }
        }
        for(int nonEID=0; nonEID<nonExpModel.length; nonEID++){
            varIDs.add(nonExpModel[nonEID]);
        }
        for (Integer variableID : varIDs){
            ArrayList<HashMap<String, Integer>> dataIDInCol = new ArrayList<>();
            for(Integer pathID: selectedRowsData.keySet()) {
                String dataID = selectedRowsData.get(pathID).get(variableID);
                Integer demonstrationID = Integer.valueOf(dataID.split("_")[0].replace("d", ""));
                HashMap<String, Integer> dataCnt = new HashMap<>();
                dataCnt.put(dataID, 1);
                dataIDInCol.add(dataCnt);
            }
            noGroupByResult.put(variableID, dataIDInCol);
        }

        return noGroupByResult;
    }

    public static GroupByReturn groupByNoKeys(HashMap<Integer, ArrayList<String>> selectedRowsData,
                                               ArrayList<Integer> aggregationCols){
        HashMap<Integer, ArrayList<HashMap<String, Integer>>> groupedBy = new HashMap();
        HashMap<Integer, HashSet<Integer>> groupedRow2SubgraphID = new HashMap<>();
        for (Integer variableID : aggregationCols){
            HashMap<Integer, HashMap<String, Integer>> dataCnt = new HashMap<>(); //demonstraionID -> dataID -> Count
            for(Integer pathID: selectedRowsData.keySet()) {
                String dataID = selectedRowsData.get(pathID).get(variableID);
                Integer demonstrationID = Integer.valueOf(dataID.split("_")[0].replace("d", ""));
                if(!groupedRow2SubgraphID.containsKey(demonstrationID)){
                    groupedRow2SubgraphID.put(demonstrationID, new HashSet<>());
                }
                groupedRow2SubgraphID.get(demonstrationID).add(pathID);

                if(!dataCnt.containsKey(demonstrationID)) {
                    dataCnt.put(demonstrationID, new HashMap<>());
                }
                if(!dataCnt.get(demonstrationID).containsKey(dataID)){
                    dataCnt.get(demonstrationID).put(dataID, 0);
                }
                dataCnt.get(demonstrationID).put(dataID, dataCnt.get(demonstrationID).get(dataID) + 1);
            }
            for(Integer dID: dataCnt.keySet()) {
                if (!groupedBy.containsKey(variableID)) {
                    groupedBy.put(variableID, new ArrayList<>());
                }
                groupedBy.get(variableID).add(dataCnt.get(dID));
            }
        }
        return new GroupByReturn(groupedBy, new ArrayList<>(), groupedRow2SubgraphID);
    }


    /*
        Group by function that runs group by on all expression solution on all grouping keys

        return a hashmap of grouped results where
        // variable -> demonstrationID -> data group
        public HashMap<Integer, HashMap<Integer, ArrayList<HashMap<String, Integer>>>> groupedResult
     */
    public static GroupByReturn groupBy(ArrayList<Demonstration> demonstrations,
                                        Integer[] nonExpModel,
                                        Integer[][] expModel,
                                        HashMap<Integer, Expression> exampleExpMap,
                                        HashMap<Integer, Property> exampleNonExpMap,
                                        HashMap<Integer, ArrayList<String>> selectedRowsData) {
        HashMap<Integer, ArrayList<HashMap<String, Integer>>> grouped = new HashMap<>();
        // variable -> demonstrationID -> data group

        HashMap<Integer, HashSet<String>> groupingKeys = new HashMap<>(); // variableID -> [Properties]
        // Get grouping keys from example non-expressions
        for(Integer nonEID: exampleNonExpMap.keySet()){
            Property exampleProperty = exampleNonExpMap.get(nonEID);
            String propertyName = exampleProperty.propertyName;
            Integer variableID = nonExpModel[nonEID];
            if(!groupingKeys.containsKey(variableID)){
                groupingKeys.put(variableID, new HashSet<>());
            }
            groupingKeys.get(variableID).add(propertyName);
        }

        HashSet<Integer> aggregationColVars = new HashSet<>(); // maintain variableID of aggregation cols
        HashSet<ArrayList<Integer>> aggregationColIDs = new HashSet<>(); // maintain location of aggregation related blanks
        if(exampleExpMap!=null) {
            for (int eID = 0; eID < exampleExpMap.size(); eID++) {
                for (int aID = 0; aID < exampleExpMap.get(eID).atoms.size(); aID++) {
                    String aggregationOpr = exampleExpMap.get(eID).atoms.get(aID).operator;
                    if (!aggregationOpr.equals("empty")) {
                        ArrayList<Integer> loc = new ArrayList<>(Arrays.asList(eID, aID));
                        aggregationColIDs.add(loc);
                        aggregationColVars.add(expModel[eID][aID]);
                    }
                }
            }
        }

        // Get all variableIDs to be grouped
        HashSet<Integer> allToBeGrouped = new HashSet<>();
        allToBeGrouped.addAll(groupingKeys.keySet());
        allToBeGrouped.addAll(aggregationColVars);

//        If no grouping keys, but have aggregationCols
        if(groupingKeys.isEmpty()){
            GroupByReturn groupByNoKeysResult = groupByNoKeys(selectedRowsData, new ArrayList<>(aggregationColVars));
            grouped = groupByNoKeysResult.groupedByData;
            return new GroupByReturn(grouped, new ArrayList<>(aggregationColIDs), groupByNoKeysResult.groupedRow2SubgraphID);
        }

        // values of grouping keys -> demonstrationID -> varID ->
        HashMap<ArrayList<String>, HashMap<Integer, HashMap<Integer, HashMap<Integer, String>>>> groupedData = new HashMap<>();
        for(int rowID:selectedRowsData.keySet()) {
            ArrayList<String> rowGroupingData = new ArrayList<>();
            for (Integer variableID : groupingKeys.keySet()) {
                String dataID = selectedRowsData.get(rowID).get(variableID);
                Integer demonstrationID = Integer.valueOf(dataID.split("_")[0].replace("d", ""));
                String concreteID = dataID.split("_")[1];
                for(String property : groupingKeys.get(variableID)){
                    if(property==null){
                        property = "full";
                    }
                    String value = "";
                    if(property.equals("full")){
                        value = concreteID;
                    } else {
                        if (concreteID.startsWith("n")) {
                            value = String.valueOf(demonstrations.get(demonstrationID).inputGraph.nodes.
                                    get(concreteID.replace("n", "")).getAttributes().get(property));
                        } else {
                            value = String.valueOf(demonstrations.get(demonstrationID).inputGraph.edges.
                                    get(concreteID.replace("e", "")).getAttributes().get(property));
                        }
                    }
                    rowGroupingData.add(value);
                }
            }

            ArrayList<String> keyDatas = new ArrayList<>();
            Boolean found = false;
            for(ArrayList<String> groupingDatas: groupedData.keySet()){
                if(groupingDatas.equals(rowGroupingData)) {
                    keyDatas = groupingDatas;
                    found = true;
                    break;
                }
            }
            if(!found) {
                keyDatas = rowGroupingData;
                groupedData.put(rowGroupingData, new HashMap<>());
            }
            // aggregate on all columns here, not writing as dataCnt yet
            for (Integer variableID : allToBeGrouped) {
                String dataID = selectedRowsData.get(rowID).get(variableID);
                Integer demonstrationID = Integer.valueOf(dataID.split("_")[0].replace("d", ""));

                if(!groupedData.get(keyDatas).containsKey(demonstrationID)) {
                    groupedData.get(keyDatas).put(demonstrationID, new HashMap<>());
                }
                if(!groupedData.get(keyDatas).get(demonstrationID).containsKey(variableID)) {
                    groupedData.get(keyDatas).get(demonstrationID).put(variableID, new HashMap<>());
                }
                groupedData.get(keyDatas).get(demonstrationID).get(variableID).put(rowID, dataID);
            }
        }

        Integer rowIDInGrouped = 0;
        HashMap<Integer, HashSet<Integer>> groupedRow2SubgraphID = new HashMap<>();
        //  Put data into groups
        for(HashMap<Integer, HashMap<Integer, HashMap<Integer, String>>> group: groupedData.values()){
            //  demonstrationID -> colID -> [dataID]
            for(Integer demonstrationID: group.keySet()){
                HashMap<Integer, HashMap<Integer, String>> group1 = group.get(demonstrationID);
                for(Integer variableID: group1.keySet()){
                    HashMap<Integer, String> dataIDs = group1.get(variableID);
                    HashMap<String, Integer> dataCnt = new HashMap<>();
                    HashSet<Integer> rowIDs = new HashSet<>();
                    for(Integer rowID: dataIDs.keySet()){
                        rowIDs.add(rowID);
                        String dataID = dataIDs.get(rowID);
                        if(!dataCnt.containsKey(dataID)) {
                            dataCnt.put(dataID, 0);
                        }
                        dataCnt.put(dataID, dataCnt.get(dataID) + 1);
                    }

                    if(!grouped.containsKey(variableID)){
                        grouped.put(variableID, new ArrayList<>());
                    }
                    grouped.get(variableID).add(dataCnt);
                    if(!groupedRow2SubgraphID.containsKey(rowIDInGrouped)){
                        groupedRow2SubgraphID.put(rowIDInGrouped, rowIDs);
                    }
                }
                rowIDInGrouped += 1;
            }
        }

        return new GroupByReturn(grouped, new ArrayList<>(aggregationColIDs), groupedRow2SubgraphID);
    }

    public static class Decoded{

        public Decoded(Integer[] nonRepairedNonExpressions, Integer[][] nonRepairedExpressions,
                       Integer[] repairedNonExpressions, Integer[][] repairedExpressions,
                       ArrayList<Integer> inclusions, ArrayList<Integer> exclusions) {
            this.nonRepairedNonExpressions = nonRepairedNonExpressions;
            this.nonRepairedExpressions = nonRepairedExpressions;
            this.repairedNonExpressions = repairedNonExpressions;
            this.repairedExpressions = repairedExpressions;
            this.inclusions = inclusions;
            this.exclusions = exclusions;
        }

        public Integer[] nonRepairedNonExpressions; // nonExpID -> variableID
        public Integer[][] nonRepairedExpressions; // expID -> atomExpID -> variableID
        public Integer[] repairedNonExpressions; // nonExpID -> variableID
        public Integer[][] repairedExpressions; // expID -> atomExpID -> variableID
        public ArrayList<Integer> inclusions;
        public ArrayList<Integer> exclusions;

    }
    /*
        Decode model to variableIDs;
     */
    public static Decoded decode(IntExpr[][] exprVars, IntExpr[] nonExprVars,
                       BoolExpr[] pathVars, Model solution){
        Integer[] nonRepairedNonExpressions = new Integer[nonExprVars.length];
        Integer[][] nonRepairedExpressions = new Integer[exprVars.length][];
        Integer[] repairedNonExpressions = new Integer[nonExprVars.length];
        Integer[][] repairedExpressions = new Integer[exprVars.length][];
        Boolean[] pathBooleans = new Boolean[pathVars.length];

        for(int i=0; i<exprVars.length; i++){
            nonRepairedExpressions[i] = new Integer[exprVars[i].length];
            repairedExpressions[i] = new Integer[exprVars[i].length];
            for(int j=0; j<exprVars[i].length; j++){
                try{
                    Integer val = Integer.valueOf(solution.getConstInterp(exprVars[i][j]).toString());
                    nonRepairedExpressions[i][j] = val;
                    repairedExpressions[i][j] = val;
                } catch(Exception e){
                    System.out.println("Wrong");
                    return null;
                }
            }
        }

        for(int i=0; i<nonExprVars.length; i++){
            try{
                Integer val = Integer.valueOf(solution.getConstInterp(nonExprVars[i]).toString());
                nonRepairedNonExpressions[i] = val;
                repairedNonExpressions[i] = val;
            } catch(Exception e){
                System.out.println("Wrong");
                return null;
            }
        }

        ArrayList<Integer> inclusions = new ArrayList<>();
        ArrayList<Integer> exclusions = new ArrayList<>();
        for(int i=0; i<pathVars.length; i++){
            try{
                String val = solution.getConstInterp(pathVars[i]).toString();
                if(val.equals("true")){
                    inclusions.add(i);
                } else {
                    exclusions.add(i);
                }
            } catch(Exception e){
                inclusions.add(i);
            }
        }

        return new Decoded(nonRepairedNonExpressions, nonRepairedExpressions,
                repairedNonExpressions, repairedExpressions, inclusions, exclusions);
    }

    public static String expressionToString(ArrayList<Expression> expressions){

        HashSet<String> expressionStrings = new HashSet<>();
        for(Expression expression: expressions){
                String decodedString = "";
                for(int objectID=0; objectID<expression.atoms.size(); objectID++){
                    Property property = expression.atoms.get(objectID);
                    decodedString += property.toString();
                    if(objectID < expression.symbols.size()){
                        decodedString += expression.symbols.get(objectID);
                    }
                }
                expressionStrings.add(decodedString);
        }
        return String.join(", ", expressionStrings);
    }

    public static String nonExpressionsToString(ArrayList<Property> properties){
        HashSet<String> nonExpressionStrings = new HashSet<>();
        for(Property nonExpression: properties){
                nonExpressionStrings.add(nonExpression.toString());
        }
        return String.join(", ", nonExpressionStrings);
    }

    public static HashMap<String, Integer> flattenDataGroup(HashMap<HashMap<String, Integer>, Integer> dataGroups){
        HashMap<String, Integer> flattened = new HashMap<>();
        for(HashMap<String, Integer> dataGroup: dataGroups.keySet()){
            for(int i=0; i<dataGroups.get(dataGroup); i++){
                for(String itemID: dataGroup.keySet()){
                    if(!flattened.containsKey(itemID)){
                        flattened.put(itemID, 0);
                    }
                    flattened.put(itemID, flattened.get(itemID)+dataGroup.get(itemID));
                }
            }
        }
        return flattened;
    }

    public static HashMap<Integer, ArrayList<HashMap<String, Integer>>> flattenDemon(
            HashMap<Integer, HashMap<Integer, ArrayList<HashMap<String, Integer>>>> groupedByData){
        return null;
    }

    public static ArrayList<ArrayList<Integer>> repairNonExpression(Integer nonExpCnt, HashSet<Integer> toRepairNonExprs,
                                                                    Integer[] nonExpressions,
                                                                    HashMap<Integer, HashSet<Integer>> coverNonExprMap){
        // Breadth first search to enumerate all possible repair
        try{
            Queue<ArrayList<Integer>> queue = new LinkedList<>();
            ArrayList<ArrayList<Integer>> result = new ArrayList<>();
            Integer ptr = 0;
            while(ptr<nonExpCnt){
                Boolean emptyQueue = queue.isEmpty();
                if(toRepairNonExprs.contains(ptr)){
                    if(emptyQueue){
                        if(!coverNonExprMap.containsKey(ptr)){
                            return new ArrayList<>();
                        }
                        for(Integer option: coverNonExprMap.get(ptr)){
                            queue.add(new ArrayList<>(Arrays.asList(option)));
                        }
                    } else {
                        for(int elementID=0; elementID<queue.size(); elementID++){
                            ArrayList<Integer> pastPart = queue.poll();
                            if(!coverNonExprMap.containsKey(ptr)){
                                return new ArrayList<>();
                            }
                            for(Integer option: coverNonExprMap.get(ptr)){
                                ArrayList<Integer> newPart = new ArrayList<>();
                                newPart.addAll(pastPart);
                                newPart.add(option);

                                queue.add(newPart);
                            }
                        }
                    }
                    ptr += 1;
                    break;
                } else {
                    if(emptyQueue){
                        queue.add(new ArrayList<>(Arrays.asList(nonExpressions[ptr])));
                    } else {
                        for(int elementID=0; elementID<queue.size(); elementID++){
                            ArrayList<Integer> pastPart = queue.poll();
                            ArrayList<Integer> newPart = new ArrayList<>();
                            newPart.addAll(pastPart);
                            newPart.add(nonExpressions[ptr]);

                            queue.add(newPart);
                        }
                    }
                }
                ptr += 1;
            }

            while (ptr < nonExpCnt) {
                for(int repairID=0; repairID < queue.size(); repairID++){
                    ArrayList<Integer> currRepaired = queue.poll();
                    if(toRepairNonExprs.contains(ptr)){
                        if(!coverNonExprMap.containsKey(ptr)){
                            return new ArrayList<>();
                        }
                        for(Integer option: coverNonExprMap.get(ptr)){
                            ArrayList<Integer> newPart = new ArrayList<>();
                            newPart.addAll(currRepaired);
                            newPart.add(option);

                            queue.add(newPart);
                        }
                    } else {
                        ArrayList<Integer> newPart = new ArrayList<>();
                        newPart.addAll(currRepaired);
                        newPart.add(nonExpressions[ptr]);

                        queue.add(newPart);
                    }
                }
                ptr+=1;
            }

            for(ArrayList<Integer> nonE: queue){
                result.add(nonE);
            }

            return result;
        } catch(Exception e){
            e.printStackTrace();
        }
        return null;
    }

    public static ArrayList<Integer[][]> repairExpressions(HashMap<Integer, HashSet<Integer>> toRepairExprs,
                                                                                    Integer[][] expressions,
                                                                                    HashMap<Integer, HashMap<Integer, HashSet<Integer>>> coverExprMap){
        // loc -> varID
        // Get all list of [eID, aID] first, then extend the search by iterating the list of [eID, aID]
        ArrayList<ArrayList<Integer>> tuple = new ArrayList<>();
        for(int eID=0; eID<expressions.length; eID++){
            for (int aID=0; aID<expressions[eID].length; aID++){
                tuple.add(new ArrayList<>(Arrays.asList(eID, aID)));
            }
        }

        Queue<HashMap<ArrayList<Integer>, Integer>> queue = new LinkedList<>();
        ArrayList<ArrayList<Integer>> result = new ArrayList<>();
        Integer ptr = 0;
        while(ptr<tuple.size()){
            Boolean emptyQueue = queue.isEmpty();
            Integer eID = tuple.get(ptr).get(0);
            Integer aID = tuple.get(ptr).get(1);
            if(toRepairExprs.containsKey(eID) && toRepairExprs.get(eID).contains(aID)){
                if(emptyQueue){
                    if(!coverExprMap.containsKey(eID) || !coverExprMap.get(eID).containsKey(aID)){
                        return new ArrayList<>();
                    }
                    for(Integer option: coverExprMap.get(eID).get(aID)){
                        HashMap<ArrayList<Integer>, Integer> eleMap = new HashMap<>();
                        eleMap.put(tuple.get(ptr), option);
                        queue.add(eleMap);
                    }
                } else {
                    for(int elementID=0; elementID<queue.size(); elementID++){
                        HashMap<ArrayList<Integer>, Integer> pastPart = queue.poll();
                        if(!coverExprMap.containsKey(eID) || !coverExprMap.get(eID).containsKey(aID)){
                            return new ArrayList<>();
                        }
                        for(Integer option: coverExprMap.get(eID).get(aID)){
                            HashMap<ArrayList<Integer>, Integer> newPart = new HashMap<>();
                            newPart.putAll(pastPart);
                            newPart.put(tuple.get(ptr), option);

                            queue.add(newPart);
                        }
                    }
                }
                ptr += 1;
                break;
            } else {
                if(emptyQueue){
                    HashMap<ArrayList<Integer>, Integer> eleMap = new HashMap<>();
                    eleMap.put(tuple.get(ptr), expressions[eID][aID]);
                    queue.add(eleMap);
                } else {
                    for(int elementID=0; elementID<queue.size(); elementID++){
                        HashMap<ArrayList<Integer>, Integer> pastPart = queue.poll();
                        HashMap<ArrayList<Integer>, Integer> newPart = new HashMap<>();
                        newPart.putAll(pastPart);
                        newPart.put(tuple.get(ptr), expressions[eID][aID]);

                        queue.add(newPart);
                    }
                }
            }
            ptr += 1;
        }

        while (ptr < tuple.size()) {
            for(int repairID=0; repairID < queue.size(); repairID++){
                Integer eID = tuple.get(ptr).get(0);
                Integer aID = tuple.get(ptr).get(1);
                HashMap<ArrayList<Integer>, Integer> currRepaired = queue.poll();
                if(toRepairExprs.containsKey(eID) && toRepairExprs.get(eID).contains(aID)){
                    if(!coverExprMap.containsKey(eID) || !coverExprMap.get(eID).containsKey(aID)){
                        return new ArrayList<>();
                    }
                    for(Integer option: coverExprMap.get(eID).get(aID)){
                        HashMap<ArrayList<Integer>, Integer> newPart = new HashMap<>();
                        newPart.putAll(currRepaired);
                        newPart.put(tuple.get(ptr), option);

                        queue.add(newPart);
                    }
                } else {
                    HashMap<ArrayList<Integer>, Integer> newPart = new HashMap<>();
                    newPart.putAll(currRepaired);
                    newPart.put(tuple.get(ptr), expressions[eID][aID]);

                    queue.add(newPart);
                }
            }
            ptr += 1;
        }

        // Transform queue to ArrayList<Integer[][]>
        ArrayList<Integer[][]> allRepairs = new ArrayList<>();
        for(HashMap<ArrayList<Integer>, Integer> repair: queue){
            Integer[][] transformedRepair = new Integer[expressions.length][expressions[0].length];
            for(ArrayList<Integer> loc: repair.keySet()){
                transformedRepair[loc.get(0)][loc.get(1)] = repair.get(loc);
            }
            allRepairs.add(transformedRepair);
        }

        return allRepairs;
    }

    public static Expr encodeExpression(Context ctx, ArrayList<String> expression){
        LinkedList<Expr> exprs = new LinkedList<>();
        Expr currExpr = null;
        String currOperator = "+";
        for(String chara: expression){
            if(!chara.equals("+") && !chara.equals("-") && !chara.equals("*") && !chara.equals("/")){
                currExpr = ctx.mkIntConst("v_"+chara);
            }
            if(currOperator.equals("+")){
                exprs.add(currExpr);
            } else if(currOperator.equals("-")){
                exprs.add(ctx.mkMul(ctx.mkInt(-1), currExpr));
            } else if(currOperator.equals("*")){
                exprs.add(ctx.mkMul(currExpr, exprs.pollLast()));
            } else if(currOperator.equals("/")) {
                exprs.add(ctx.mkDiv(exprs.pollLast(), currExpr));
            }
            if(chara.equals("+") || chara.equals("-") || chara.equals("*") || chara.equals("/")){
                currOperator = chara;
            }
        }

        Expr sum = exprs.poll();
        while(!exprs.isEmpty()){
            sum = ctx.mkAdd(sum, exprs.poll());
        }
        return sum;
    }

    /*
        Encode all objects with global map;
        Maintain a stack to prepare ctx.mkAdd(multiplied objects)
     */
    public static Boolean sameExpression(Context ctx, ArrayList<String> expressionA, ArrayList<String> expressionB){
//        Encode equivalence checking into constraints
        Expr sumA = encodeExpression(ctx, expressionA);
        Expr sumB = encodeExpression(ctx, expressionB);

        Solver tmpSolver = ctx.mkSolver();
        tmpSolver.add(ctx.mkNot(ctx.mkEq(sumA, sumB)));
        if(tmpSolver.check()==Status.SATISFIABLE){
            return false;
        }
        return true;
    }

}
