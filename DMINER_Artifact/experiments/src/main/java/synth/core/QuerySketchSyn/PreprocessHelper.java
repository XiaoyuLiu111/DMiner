package synth.core.QuerySketchSyn;

import synth.ast.pred.expr.Property;
import synth.core.PattermEnumerator.Helper;
import synth.core.data.dataStructures.Computation;
import synth.core.data.dataStructures.Demonstration;
import synth.core.data.dataStructures.Expression;

import java.lang.reflect.Array;
import java.util.*;

import static synth.core.filterSyn.Helpers.dataHelper;
import static synth.core.filterSyn.Helpers.mappingHelper;

/*
    Preprocess the demonstration outputs to obtain objects needed
 */
public class PreprocessHelper {
    public PreprocessHelper(ArrayList<Demonstration> demonstrations, ArrayList<String> variableName,
                            ArrayList<ArrayList<String>> values, HashMap<String, ArrayList<String>> varName2Labels,
                            HashMap<String, Expression> expressions, HashMap<String, Property> nonExpressions) {
        this.demonstrations = demonstrations;
        this.variableName = variableName;
        this.values = values;
        this.varName2Labels = varName2Labels;
        this.expressions = expressions;
        this.nonExpressions = nonExpressions;
    }

    public ArrayList<Demonstration> demonstrations;
    public ArrayList<String> variableName;
    public ArrayList<ArrayList<String>> values;
    public HashMap<String, ArrayList<String>> varName2Labels;

    // Label -> variable ID of which label corresponds with the property
    public HashMap<String, ArrayList<Integer>> initialOptions = new HashMap<>();
    public HashMap<ArrayList<String>, ArrayList<Integer>> pathPropertyValues = new HashMap<>();

    public HashMap<String, Expression> expressions; // valID -> Expression
    public HashMap<String, Property> nonExpressions; // valID -> Property
    public HashMap<Integer, Expression> exampleExpMap = new HashMap<>(); // idx of expression related hole -> example expression
    public HashMap<Integer, Property> exampleNonExpMap = new HashMap<>(); // idx of property related hole -> example property
    // dataGroups in col -> [loc represented by arraylist of integer]
    public HashMap<HashMap<HashMap<String, Integer>, Integer>, ArrayList<ArrayList<Integer>>> dataGroups2Col = new HashMap<>();
    public  HashMap<Integer, HashMap<Integer, HashMap<HashMap<String, Integer>, Integer>>> expHole2Datas = new HashMap<>(); // [eID, aID] -> [dataGroup] for expressions
    public HashMap<String, HashMap<String, HashMap<HashMap<String, Integer>, String>>> resultMap = new HashMap<>();
    public Integer resultUID=0;
    public HashMap<Integer, ArrayList<ArrayList<String>>> expressionEncoded = new HashMap<>(); //eID -> encoded expressions
    public  HashMap<Integer, HashMap<HashMap<String, Integer>, Integer>> nonExpHole2Datas = new HashMap<>(); // nonEID -> [dataGroup] for non-expressions
    public HashMap<Integer, HashMap<HashMap<HashMap<String, Integer>, Integer>, Integer>> rowDataGroups = new HashMap<>(); // rowID -> dataGroups in row

    // map from atom expression to idx of the atom expression: agg -> prop -> {inputIDs of one value} -> valID -> idx in expression
    public HashMap<String, HashMap<String, HashMap<HashMap<String, Integer>, HashMap<String, ArrayList<Integer>>>>> locExpMap = new HashMap<>();
    // map from atom non-expression to idx of the non expression property: agg -> prop -> NEId -> valID
    public HashMap<String, HashMap<HashMap<String, Integer>, ArrayList<String>>> locNonExpMap= new HashMap<>();

    // all nodes or edges from output (with aggregation or property info): aggregationOpr -> property -> NEIds
    public HashMap<String, HashMap<String, HashSet<String>>> singleData = new HashMap<>();
    // all nodes or edges from output (without aggregation or property info)
    public HashSet<String> NEs = new HashSet<>();
    // group target atom expressions: aggregation -> property -> colExpID -> ArrayList<atomIdx>
    public HashMap<String, HashMap<String, HashMap<Integer, ArrayList<Integer>>>> groupedExpressions = new HashMap<>();
    // group target non-expressions: aggregationOpr -> property -> colNonExpID
    public HashMap<String, HashMap<String, ArrayList<Integer>>> groupedNonExpressions = new HashMap<>();
    // grouped data without aggregation operators or properties
    public HashSet<HashMap<String, Integer>> groupedDatas = new HashSet<>();


    public void preprocessMap12(){
        locNonExpMap.put("empty", new HashMap<>());
        for (int demonstrationID = 0; demonstrationID < demonstrations.size(); demonstrationID++) {
            Integer nonExpressionID = 0;

            Demonstration demonstration = demonstrations.get(demonstrationID);
            HashSet<String> valIDs = new HashSet<>(demonstration.mapping1.keySet());
            for (String valID : valIDs) {
                ArrayList<String> inputIDs = demonstration.mapping1.get(valID);
                String property = demonstration.mapping2.get(valID).get(0);
                HashMap<String, Integer> dataCnt = new HashMap<>();
                for(String inputID: inputIDs){
                    String inputIDP = "d" + String.valueOf(demonstrationID) + "_" + inputID;
                    if(!dataCnt.containsKey(inputIDP)){
                        dataCnt.put(inputIDP, 0);
                    }
                    dataCnt.put(inputIDP, dataCnt.get(inputIDP) + 1);
                }

                // Update groupedDatas;
                groupedDatas.add(dataCnt);

                ArrayList<Integer> fullLoc = new ArrayList<>(Arrays.asList(demonstrationID, nonExpressionID));
                if (!locNonExpMap.containsKey(property)) {
                    locNonExpMap.put(property, new HashMap<>());
                }

                if (!locNonExpMap.get(property).containsKey(dataCnt)) {
                    locNonExpMap.get(property).put(dataCnt, new ArrayList<>());
                }
                locNonExpMap.get(property).get(dataCnt).add(valID);


                for (String inputIDB : inputIDs) {
                    String inputID = "d" + demonstrationID + "_" + inputIDB;
                    // Update NEs
                    NEs.add(inputID);
                    // Update singleData
                    addToSingleData("empty", property, inputID);
                }

                nonExpressionID++;
            }
        }
    }

    public void preprocessMap3(){
        for(int demonstrationID=0; demonstrationID < demonstrations.size(); demonstrationID++){
            ArrayList<Expression> expressionsInDemonstration = new ArrayList<>();
            for(int computationObjectID=0; computationObjectID<demonstrations.get(demonstrationID).mapping3.size(); computationObjectID++){
                String valID = "d" + String.valueOf(demonstrationID) + "_exp" + String.valueOf(computationObjectID);
                Expression flattened = flattenExpressionHelper(demonstrations.get(demonstrationID).mapping3.get(computationObjectID), demonstrationID);

                Integer atomExpIdx = 0;
                for(Property atomExpression: flattened.atoms){
                    String propertyName = atomExpression.propertyName;
                    String operator = atomExpression.operator;
                    // Update NEs
                    for(String NEId: atomExpression.data.keySet()){
                        NEs.add(NEId);
                        // Update to singleData
                        addToSingleData(operator, propertyName, NEId);
                    }
                    // Update groupedDatas;
                    groupedDatas.add(atomExpression.data);

                    // Update locExpMap
                    addToExpLoc(operator, propertyName, atomExpression.data, valID, atomExpIdx);

                    atomExpIdx++;
                }
                expressions.put(valID, flattened);
            }
        }
    }

    public ArrayList<ArrayList<String>> transpose2Cols(ArrayList<ArrayList<String>> corByRows){
        Integer rowID = 0;
        ArrayList<ArrayList<String>> corByCols = new ArrayList<>();
        LinkedHashMap<Integer, ArrayList<String>> corByColsMap = new LinkedHashMap<>();
        for(Demonstration demonstration: demonstrations){
            ArrayList<ArrayList<String>> corInDemon = demonstration.correspondence;
            for(ArrayList<String> rowCor: corInDemon){
                for(Integer colID=0; colID<rowCor.size(); colID++){
                    String colValID = rowCor.get(colID);
                    if(!corByColsMap.containsKey(colID)){
                        corByColsMap.put(colID, new ArrayList<>());
                    }
                    corByColsMap.get(colID).add(colValID);

                    HashMap<HashMap<String, Integer>, Integer> dataGroupsInVal = new HashMap<>();
                    if(colValID.contains("exp")){
                        // unfold the nested structure to multiple 'sub-columns'
                        for(Property atom: expressions.get(colValID).atoms){
                            if(!dataGroupsInVal.containsKey(atom.data)){
                                dataGroupsInVal.put(atom.data, 0);
                            }
                            dataGroupsInVal.put(atom.data, dataGroupsInVal.get(atom.data)+1);
                        }
                    } else {
                        dataGroupsInVal.put(nonExpressions.get(colValID).data, 1);
                    }
                    // add dataGroupsInVal to row map
                    if(!rowDataGroups.containsKey(rowID)){
                        rowDataGroups.put(rowID, new HashMap<>());
                    }
                    if(!rowDataGroups.get(rowID).containsKey(dataGroupsInVal)){
                        rowDataGroups.get(rowID).put(dataGroupsInVal, 0);
                    }
                    rowDataGroups.get(rowID).put(dataGroupsInVal, rowDataGroups.get(rowID).get(dataGroupsInVal)+1);
                }
                rowID += 1;
            }
        }
        for(Integer colID: corByColsMap.keySet()){
            corByCols.add(corByColsMap.get(colID));
        }
        return corByCols;
    }

    /*
        Preprocess and combine correspondence from different demonstrations to col2ValIDs and rowValIDs
     */
    public void preprocessCor(){
        // Put all rows from each demonstration to here as combined
        ArrayList<ArrayList<String>> corByRows = new ArrayList<>();
        for(Demonstration demonstration: demonstrations){
            corByRows.addAll(demonstration.correspondence);
        }
        ArrayList<ArrayList<String>> corByCols = transpose2Cols(corByRows);
        // [eID,aID] -> dataGroups
        HashMap<ArrayList<Integer>, HashMap<HashMap<String, Integer>, Integer>> loc2DataGroups = new HashMap<>();
        for(Integer rowID=0; rowID<corByRows.size(); rowID++){
            Integer eHoleID = 0;
            Integer nonEHoleID = 0;
            for(Integer wholeID=0; wholeID<corByCols.size(); wholeID++){
                ArrayList<String> encodedExpression = new ArrayList<>();
                String colValID = corByCols.get(wholeID).get(rowID);
                // Put aside expression column and non-expression columns
                if(colValID.contains("exp")){
                    // the target item is an expression
                    if(!expHole2Datas.containsKey(eHoleID)){
                        expHole2Datas.put(eHoleID, new HashMap<>());
                    }
                    Expression targetExpression = expressions.get(colValID);
                    for(Integer aID=0; aID < targetExpression.atoms.size(); aID++){
                        Property atom = targetExpression.atoms.get(aID);
                        HashMap<String, Integer> dataGroup = atom.data;
                        String aggregationOpr = atom.operator;
                        String propertyName = atom.propertyName;
                        if(!resultMap.containsKey(aggregationOpr)){
                            resultMap.put(aggregationOpr, new HashMap<>());
                        }
                        if(!resultMap.get(aggregationOpr).containsKey(propertyName)){
                            resultMap.get(aggregationOpr).put(propertyName, new HashMap<>());
                        }
                        if(!resultMap.get(aggregationOpr).get(propertyName).containsKey(dataGroup)){
                            resultMap.get(aggregationOpr).get(propertyName).put(dataGroup, String.valueOf(resultUID));
                            resultUID += 1;
                        }
                        encodedExpression.add(resultMap.get(aggregationOpr).get(propertyName).get(dataGroup));
                        if(aID < targetExpression.symbols.size()){
                            encodedExpression.add(targetExpression.symbols.get(aID));
                        }

                        // ID here should be ID in expression list
                        if(!expHole2Datas.get(eHoleID).containsKey(aID)){
                            expHole2Datas.get(eHoleID).put(aID, new HashMap<>());
                        }
                        if(!expHole2Datas.get(eHoleID).get(aID).containsKey(dataGroup)){
                            expHole2Datas.get(eHoleID).get(aID).put(dataGroup, 0);
                        }
                        expHole2Datas.get(eHoleID).get(aID).put(dataGroup, expHole2Datas.get(eHoleID).get(aID).get(dataGroup)+1);

                        ArrayList<Integer> expLoc = new ArrayList<>(Arrays.asList(eHoleID, aID));
                        if(!loc2DataGroups.containsKey(expLoc)){
                            loc2DataGroups.put(expLoc, new HashMap<>());
                        }
                        if(!loc2DataGroups.get(expLoc).containsKey(dataGroup)){
                            loc2DataGroups.get(expLoc).put(dataGroup, 0);
                        }
                        loc2DataGroups.get(expLoc).put(dataGroup, loc2DataGroups.get(expLoc).get(dataGroup)+1);
                    }
                    if(!expressionEncoded.containsKey(eHoleID)){
                        expressionEncoded.put(eHoleID, new ArrayList<>());
                    }
                    expressionEncoded.get(eHoleID).add(encodedExpression);
                    eHoleID += 1;
                } else {
                    // the target item is a non-expression
                    Property targetProperty = nonExpressions.get(colValID);
                    HashMap<String, Integer> dataGroup = targetProperty.data;

                    if(!nonExpHole2Datas.containsKey(nonEHoleID)){
                        nonExpHole2Datas.put(nonEHoleID, new HashMap<>());
                    }
                    if(!nonExpHole2Datas.get(nonEHoleID).containsKey(dataGroup)){
                        nonExpHole2Datas.get(nonEHoleID).put(dataGroup, 0);
                    }
                    nonExpHole2Datas.get(nonEHoleID).put(dataGroup, nonExpHole2Datas.get(nonEHoleID).get(dataGroup)+1);

                    ArrayList<Integer> nonExpLoc = new ArrayList<>(Arrays.asList(nonEHoleID));
                    if(!loc2DataGroups.containsKey(nonExpLoc)){
                        loc2DataGroups.put(nonExpLoc, new HashMap<>());
                    }
                    if(!loc2DataGroups.get(nonExpLoc).containsKey(dataGroup)){
                        loc2DataGroups.get(nonExpLoc).put(dataGroup, 0);
                    }
                    loc2DataGroups.get(nonExpLoc).put(dataGroup, loc2DataGroups.get(nonExpLoc).get(dataGroup)+1);

                    nonEHoleID += 1;
                }
            }
        }
        for(ArrayList<Integer> loc: loc2DataGroups.keySet()){
            HashMap<HashMap<String, Integer>, Integer> dataGroups = loc2DataGroups.get(loc);
            if(!dataGroups2Col.containsKey(dataGroups)){
                dataGroups2Col.put(dataGroups, new ArrayList<>());
            }
            dataGroups2Col.get(dataGroups).add(loc);
        }

        // Get example Expression or Property for each column
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

        // Update groupedExpressions and groupedNonExpressions
        for(Integer expColID: exampleExpMap.keySet()){
            Expression exampleExpression = exampleExpMap.get(expColID);
            for(Integer atomExpIdx=0; atomExpIdx<exampleExpression.atoms.size(); atomExpIdx++){
                String operator = exampleExpression.atoms.get(atomExpIdx).operator;
                String propertyName = exampleExpression.atoms.get(atomExpIdx).propertyName;

                if(!groupedExpressions.containsKey(operator)){
                    groupedExpressions.put(operator, new HashMap<>());
                }
                if(!groupedExpressions.get(operator).containsKey(propertyName)){
                    groupedExpressions.get(operator).put(propertyName, new HashMap<>());
                }
                if (!groupedExpressions.get(operator).get(propertyName).containsKey(expColID)) {
                    groupedExpressions.get(operator).get(propertyName).put(expColID, new ArrayList<>());
                }
                groupedExpressions.get(operator).get(propertyName).get(expColID).add(atomExpIdx);
            }
        }

        for(Integer nonExpColID: exampleNonExpMap.keySet()){
            Property exampleProperty = exampleNonExpMap.get(nonExpColID);
            String property = exampleProperty.propertyName;
            //  Update groupedNonExpressions
            if (!groupedNonExpressions.containsKey("empty")) {
                groupedNonExpressions.put("empty", new HashMap<>());
            }
            if (!groupedNonExpressions.get("empty").containsKey(property)) {
                groupedNonExpressions.get("empty").put(property, new ArrayList<>());
            }
            groupedNonExpressions.get("empty").get(property).add(nonExpColID);
        }

    }

    public static Expression flattenExpressionHelper(Computation computation, Integer demonstrationID){
        String operator = computation.operator;

        if(!computation.dataID.isEmpty()){
//            base layer of single operator
            String property = computation.property;
            HashMap<String, Integer> cntData = new HashMap<>();
            for(String data: computation.dataID){
                if(!cntData.containsKey(data)){
                    cntData.put(data, 0);
                }
                cntData.put(data, cntData.get(data) + 1);
            }
            Property atomExpression = new Property(property, null);
            atomExpression.data = cntData;
            atomExpression.operator = operator;

            Expression expression = new Expression();
            expression.atoms = new ArrayList<>(Arrays.asList(atomExpression));
            return expression;
        } else {
//            combinator case
            Expression lhs = flattenExpressionHelper(computation.lhs, demonstrationID);
            lhs.symbols.add(operator);
            Expression rhs = flattenExpressionHelper(computation.rhs, demonstrationID);
            lhs.symbols.addAll(rhs.symbols);
            lhs.atoms.addAll(rhs.atoms);
            return lhs;
        }
    }

    public void addToSingleData(String aggregationOpr, String property, String NEId){
        if(!singleData.containsKey(aggregationOpr)){
            singleData.put(aggregationOpr, new HashMap<>());
        }
        if(!singleData.get(aggregationOpr).containsKey(property)){
            singleData.get(aggregationOpr).put(property, new HashSet<>());
        }
        singleData.get(aggregationOpr).get(property).add(NEId);
    }

    public void addToNonExpLoc(String property, HashMap<String, Integer> dataCnt, String valID){
        if(!locNonExpMap.containsKey(property)){
            locNonExpMap.put(property, new HashMap<>());
        }
        if(!locNonExpMap.get(property).containsKey(dataCnt)){
            locNonExpMap.get(property).put(dataCnt, new ArrayList<>());
        }
        locNonExpMap.get(property).get(dataCnt).add(valID);
    }

    public void addToExpLoc(String aggregationOpr, String property, HashMap<String, Integer> NEIds,
                            String valID, Integer atomExpID){
        if(!locExpMap.containsKey(aggregationOpr)){
            locExpMap.put(aggregationOpr, new HashMap<>());
        }
        if(!locExpMap.get(aggregationOpr).containsKey(property)){
            locExpMap.get(aggregationOpr).put(property, new HashMap<>());
        }
        if(!locExpMap.get(aggregationOpr).get(property).containsKey(NEIds)){
            locExpMap.get(aggregationOpr).get(property).put(NEIds, new HashMap<>());
        }
        if(!locExpMap.get(aggregationOpr).get(property).get(NEIds).containsKey(valID)){
            locExpMap.get(aggregationOpr).get(property).get(NEIds).put(valID, new ArrayList<>());
        }
        locExpMap.get(aggregationOpr).get(property).get(NEIds).get(valID).add(atomExpID);
    }

    // Property -> variable ID of which label corresponds with the property
    public void getInitialOptions(){
        //        Iterate over all variables
        for(String varName: varName2Labels.keySet()){
            Integer variableID = variableName.indexOf(varName);
            for(String label: varName2Labels.get(varName)){
                if(!initialOptions.containsKey(label)){
                    initialOptions.put(label, new ArrayList<>());
                }
                initialOptions.get(label).add(variableID);
            }
        }
    }

    /*
        Transform NEIds to property values map
     */
    public void getPathPropertyValues(){
        HashMap<Integer, ArrayList<LinkedHashMap<String, Object>>> data = new HashMap<>(); // rowIndex -> all values in row
        for(int rowID=0; rowID<values.size(); rowID++){
            Integer demonstrationID = Integer.valueOf(values.get(rowID).get(0).split("_")[0].replace("d", ""));
            ArrayList<LinkedHashMap<String, Object>> propertyValsInPath = dataHelper(values.get(rowID), demonstrations.get(demonstrationID));
            ArrayList<String> allVals = new ArrayList<>();
            for(int variableID=0; variableID<propertyValsInPath.size(); variableID++){
                LinkedHashMap<String, Object> propertyVals = propertyValsInPath.get(variableID);
                for(String property: propertyVals.keySet()){
                    allVals.add(String.valueOf(propertyVals.get(property)));
                }
            }
            if(!pathPropertyValues.containsKey(allVals)){
                pathPropertyValues.put(allVals, new ArrayList<>());
            }
            pathPropertyValues.get(allVals).add(rowID);
        }
    }
}
