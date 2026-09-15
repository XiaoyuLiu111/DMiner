package synth.core.filterSyn;

import com.microsoft.z3.*;
import synth.ast.pred.*;
import synth.ast.pred.expr.BinaryCalculation;
import synth.ast.pred.expr.Property;
import synth.ast.pred.expr.Value;
import synth.core.PatternEvaluator;
import synth.core.QuerySketchSyn.SketchSynthesizer;
import synth.core.data.dataStructures.Demonstration;
import synth.core.data.dataStructures.DataStructure;

import java.util.*;

import static synth.core.filterSyn.ConstraintHelper.*;
import static synth.core.filterSyn.Helpers.*;

public class PredicateSynthesize {
    public static class ReturnZ3Object {

        public ReturnZ3Object(Model model, IntExpr[][][] numConstants, IntExpr[][][] stringConstants, IntExpr[][][][] constants, IntExpr[][] operators) {
            this.model = model;
            this.numConstants = numConstants;
            this.stringConstants = stringConstants;
            this.constants = constants;
            this.operators = operators;
        }

        public Model model;
        public IntExpr[][][] numConstants;
        public IntExpr[][][] stringConstants;
        public IntExpr[][][][] constants;
        public IntExpr[][] operators;
    }

    public static class ReturnPredSyn{
        public ReturnPredSyn(Integer predicateCnt, Predicate predicateClause, HashMap<Integer, Long> predicateTimeMap) {
            this.predicateCnt = predicateCnt;
            this.predicateClause = predicateClause;
            this.predicateTimeMap = predicateTimeMap;
        }

        public Integer predicateCnt;
        public Predicate predicateClause;
        public HashMap<Integer, Long> predicateTimeMap;
    }

    public StringEncoder encoder = new StringEncoder();
    public HashMap<Integer, String> typeMap = new HashMap<>();
    public Boolean needPredicate = true;
    public ArrayList<String> varNames;
    public LinkedHashMap<String, ArrayList<String>> varName2Properties;
    public Integer predicateCnt;
    public HashMap<Integer, Long> predicateTimeMap = new HashMap<>();

    public ReturnPredSyn predicateSynthesizer(ArrayList<Integer> toInclude, ArrayList<Integer> toExclude, ArrayList<Demonstration> demonstrations, PatternEvaluator.ReturnQuery data,
                                          LinkedHashMap<String, ArrayList<String>> varName2Properties, Integer predicateCnt) {
        this.predicateCnt = predicateCnt;
        if (toExclude.isEmpty()) {
//            No predicate needed
            needPredicate = false;
            return null;
        }
        this.varNames = data.variableName;
        this.varName2Properties = varName2Properties;

        ReturnZ3Object constraints = z3Helper(toInclude, toExclude, demonstrations, data.vals);

        Predicate predicateClause = toPredicate(constraints);

//        Return AST of complete clause here
        return new ReturnPredSyn(predicateCnt, predicateClause, predicateTimeMap);
    }


    public ReturnZ3Object z3Helper(ArrayList<Integer> toInclude, ArrayList<Integer> toExclude,
                                   ArrayList<Demonstration> demonstrations, ArrayList<ArrayList<String>> values) {
//        3. Transform data
        HashMap<Integer, ArrayList<LinkedHashMap<String, Object>>> data = new HashMap<>(); // rowIndex -> all values in row
        Integer rowIdx = 0;
        for (Integer includeID : toInclude) {
            Integer demonstrationID = Integer.valueOf(values.get(includeID).get(0).split("_")[0].replace("d", ""));
            ArrayList<LinkedHashMap<String, Object>> includeRow = dataHelper(values.get(includeID), demonstrations.get(demonstrationID));
            data.put(rowIdx, includeRow);
            rowIdx += 1;
        }
        for (Integer excludeID : toExclude) {
            Integer demonstrationID = Integer.valueOf(values.get(excludeID).get(0).split("_")[0].replace("d", ""));
            ArrayList<LinkedHashMap<String, Object>> excludeRow = dataHelper(values.get(excludeID), demonstrations.get(demonstrationID));
            data.put(rowIdx, excludeRow);
            rowIdx += 1;
        }

        this.typeMap = mappingHelper(values.get(0), demonstrations.get(0).inputGraph);

//        transform to value list with the same key order
        int[][][] toPassData = new int[data.size()][][];
        Integer idx = 0;
        for (Integer rowId : data.keySet()) {
            ArrayList<LinkedHashMap<String, Object>> rowData = data.get(rowId);
            toPassData[rowId] = new int[rowData.size()][];
            idx = 0;
            for (int variableID = 0; variableID < rowData.size(); variableID++) {
                toPassData[rowId][variableID] = new int[rowData.get(variableID).size()];
                LinkedHashMap<String, Object> itemData = rowData.get(variableID);
                toPassData[rowId][variableID] = new int[itemData.size()];
                Integer propertyId = 0;
                for (String propertyKey : itemData.keySet()) {
                    Integer num = 0;
                    if (typeMap.get(idx).equals("String")) {
                        num = this.encoder.encode((String) rowData.get(variableID).get(propertyKey));
                    } else if (typeMap.get(idx).equals("Long")) {
                        num = ((Long) rowData.get(variableID).get(propertyKey)).intValue();
                    }
                    toPassData[rowId][variableID][propertyId] = num;
                    propertyId++;
                    idx++;
                }
            }
        }
//        create array to record expected and notExpected idx
        ArrayList<Boolean> expectedOrNot = new ArrayList<>();
        for (int i = 0; i < toInclude.size(); i++) {
            expectedOrNot.add(true);
        }
        for (int i = 0; i < toExclude.size(); i++) {
            expectedOrNot.add(false);
        }

        LinkedHashSet<DataStructure.Pair> numConstantsPositions = new LinkedHashSet<>();
        LinkedHashSet<DataStructure.Pair> stringConstantsPositions = new LinkedHashSet<>();
        int k = 0;
        for (int variableID = 0; variableID < toPassData[0].length; variableID++) {
            int propertyNum = toPassData[0][variableID].length;
            for (int propertyId = 0; propertyId < propertyNum; propertyId++) {
                if (this.typeMap.get(k).equals("String")) {
                    stringConstantsPositions.add(new DataStructure.Pair(variableID, propertyId));
                } else if (this.typeMap.get(k).equals("Long") || this.typeMap.get(k).equals("Integer")) {
                    numConstantsPositions.add(new DataStructure.Pair(variableID, propertyId));
                }
                k++;
            }
        }

//      4. Pass into encoder in rounds
        ReturnZ3Object constraints = null;
        Integer or = null;
        Integer and = null;
        for (int orNum = 0; orNum < toInclude.size(); orNum++) {
            int andNum = typeMap.size() - 3;
            predicateCnt += 1;
            Long synStart = System.currentTimeMillis();
            constraints = solver(orNum, andNum,
                    toPassData, numConstantsPositions, stringConstantsPositions, expectedOrNot);
            Long synEnd = System.currentTimeMillis();
            predicateTimeMap.put(predicateCnt, synEnd - synStart);
            if (constraints != null) {
                or = orNum;
                and = andNum;
                break;
//            }
            }
            if (constraints != null) {
                break;
            }
        }
        if (constraints == null) {
            return null;
        }
        return constraints;
    }


    public ReturnZ3Object solver(Integer orNumber, Integer andNumber,
                                 int[][][] data,
                                 LinkedHashSet<DataStructure.Pair> numConstantsPositions,
                                 LinkedHashSet<DataStructure.Pair> stringConstantsPositions,
                                 ArrayList<Boolean> positiveOrNegative) {
        Integer operatorNum = (orNumber + 1) * (andNumber + 1);
        int rowNum = data.length;
        int varNum = data[0].length;

        Context ctx = new Context();
        Optimize optimizer = ctx.mkOptimize();
        IntExpr[][] operators = new IntExpr[orNumber + 1][andNumber + 1];
        IntExpr[][][][] constants = new IntExpr[orNumber + 1][andNumber + 1][][]; // last two branches are number constant or string constant
        IntExpr[][][] numConstants = new IntExpr[orNumber + 1][andNumber + 1][]; // one more constant than number of numeric columns
        IntExpr[][][] stringConstants = new IntExpr[orNumber + 1][andNumber + 1][]; // two more constants than number of string columns

        Boolean hasNum = false;
        Boolean hasString = false;
//        generate constants and operators
        for (int i = 0; i < orNumber + 1; i++) {
            for (int j = 0; j < andNumber + 1; j++) {
                int idx = 0;
                constants[i][j] = new IntExpr[varNum][];
                ArrayList<IntExpr> numC = new ArrayList<>();
                ArrayList<IntExpr> stringC = new ArrayList<>();

                for (int variableID = 0; variableID < varNum; variableID++) {
                    int propertyNum = data[0][variableID].length;
                    constants[i][j][variableID] = new IntExpr[propertyNum];
                    for (int propertyId = 0; propertyId < propertyNum; propertyId++) {
                        constants[i][j][variableID][propertyId] = ctx.mkIntConst("w_" + i + "_" + j +
                                "_" + this.varNames.get(variableID) + "_" + this.varName2Properties.get(this.varNames.get(variableID)).get(propertyId));
                        if (this.typeMap.get(idx).equals("String")) {
                            hasString = true;
                            stringC.add(constants[i][j][variableID][propertyId]);
                        } else if (this.typeMap.get(idx).equals("Long") || this.typeMap.get(idx).equals("Integer")) {
                            hasNum = true;
                            numC.add(constants[i][j][variableID][propertyId]);
                        }
                        idx++;
                    }
                }

                int numId = 0;
                numConstants[i][j] = new IntExpr[numC.size() + 1];
                for (IntExpr numConstant : numC) {
                    numConstants[i][j][numId] = numConstant;
                    numId++;
                }
                int stringId = 0;
                stringConstants[i][j] = new IntExpr[stringC.size() + 1];
                for (IntExpr stringConstant : stringC) {
                    stringConstants[i][j][stringId] = stringConstant;
                    stringId++;
                }
//                Add more to numConstants and stringConstants as non-weight part
                numConstants[i][j][numId] = ctx.mkIntConst("w_" + i + "_" + j + "_" + "numConstant");
                stringConstants[i][j][stringId] = ctx.mkIntConst("w_" + i + "_" + j + "_" + "stringConstant");

//                construct operators, 2 for numerical columns, 2 for string columns
                operators[i][j] = ctx.mkIntConst("o_" + i + "_" + j);
            }
        }

        if(hasNum && hasString) {
            //        Add hard constraint about values
            optimizer = generateMixConstraints(ctx, optimizer, orNumber, andNumber, data, numConstants,
                    stringConstants, constants, operators, positiveOrNegative, numConstantsPositions, stringConstantsPositions, encoder.decodingMap.keySet());
        } else if (hasNum) {
            optimizer = generateNumConstraints(ctx, optimizer, orNumber, andNumber, data, numConstants,
                    stringConstants, constants, operators, positiveOrNegative, numConstantsPositions, stringConstantsPositions, encoder.decodingMap.keySet());
        } else if (hasString) {
            optimizer = generateStringConstraints(ctx, optimizer, orNumber, andNumber, data, numConstants,
                    stringConstants, constants, operators, positiveOrNegative, numConstantsPositions, stringConstantsPositions, encoder.decodingMap.keySet());
        }

        if (optimizer.Check() == Status.SATISFIABLE) {
            Model solution = optimizer.getModel();
            return new ReturnZ3Object(solution, numConstants, stringConstants, constants, operators);
        }
        return null;
    }

    public Predicate toPredicate(ReturnZ3Object constraints) {
        //      5. Transform model back to filter clause AST
        if (constraints == null) {
            return null;
        }
        int orNum = constraints.constants.length;
        int andNum = constraints.constants[0].length;
        Predicate[][] predicates = new Predicate[orNum][andNum];
        ArrayList<Predicate> orCandi = new ArrayList<>();
        for (int i = 0; i < orNum; i++) {
            for (int j = 0; j < andNum; j++) {
//                into one predicate, check each column 0 or not, check data type
                ArrayList<Predicate> weightedItems = new ArrayList<>();
                int idx = 0;
                for (int variableID = 0; variableID < constraints.constants[i][j].length; variableID++) {
                    String variableName = this.varNames.get(variableID);
                    for (int propertyId = 0; propertyId < constraints.constants[i][j][variableID].length; propertyId++) {
                        int val = Integer.parseInt(constraints.model.getConstInterp(constraints.constants[i][j][variableID][propertyId]).toString());
                        String property = this.varName2Properties.get(variableName).get(propertyId);
                        if (val != 0) {
                            if (this.typeMap.get(idx).equals("String")) {
                                weightedItems.add(new Property(property, variableName));
                            } else {
                                weightedItems.add(new BinaryCalculation(new Value(val), new Property(property, variableName), Operators.Calculation.MULTIPLE));
                            }
                        }
                        idx++;
                        }
                    }

//                Interpret when weights are not zeros
                if (!weightedItems.isEmpty()) {
                    //                get operator
                    int operator = Integer.parseInt(constraints.model.getConstInterp(constraints.operators[i][j]).toString());

//                get constants from last items in constraints.numConstraints and constraints.stringConstraints
                    Long numRight = Long.valueOf(0);
                    try{
                        numRight = Long.parseLong(constraints.model.getConstInterp(constraints.numConstants[i][j][constraints.numConstants[i][j].length - 1]).toString());
                    } catch (Exception e){

                    }
                    if (numRight != 0) {
                        weightedItems.add(new Value(numRight));
                    }
                    int stringRightVal = 0;
                    try{
                        stringRightVal = Integer.parseInt(constraints.model.getConstInterp(constraints.stringConstants[i][j][constraints.stringConstants[i][j].length - 1]).toString());
                    } catch (Exception e){}
                    String stringRight = "";
                    if (stringRightVal != 0) {
                        stringRight = "'"+this.encoder.decodingMap.get(stringRightVal)+"'";
                    }

//                    to Predicate
                    BinaryComparison compare = new BinaryComparison(null, null, null);
                    if (operator == 0 || operator == 1 || operator == 2 || operator == 3) {
                        BinaryCalculation lhs = new BinaryCalculation(weightedItems.get(0), null, Operators.Calculation.ADD);
                        for (int k = 1; k < weightedItems.size(); k++) {
                            Predicate weightedItem = weightedItems.get(k);
                            lhs = new BinaryCalculation(lhs, weightedItem, Operators.Calculation.ADD);
                        }
                        compare.setLhsExpression(lhs);
                        compare.setRhsExpression(new Value(0));
                        if (operator == 0) {
                            compare.setLogicalOperator(Operators.LogicalOperator.LARGEROREQUAL);
                        }
                        if (operator == 1) {
                            compare.setLogicalOperator(Operators.LogicalOperator.SMALLEROREQUAL);
                        }
                        if (operator == 2) {
                            compare.setLogicalOperator(Operators.LogicalOperator.EQUAL);
                        }
                        if (operator == 3) {
                            compare.setLogicalOperator(Operators.LogicalOperator.NOTEQUAL);
                        }
                    }
                    if (operator == 4 || operator == 5) {
                        if (!stringRight.equals("")) {
                            compare.setRhsExpression(new Value(stringRight));
                        }
                        compare.setLhsExpression(weightedItems.get(0));
                        if(weightedItems.size() > 1) {
                            compare.setRhsExpression(weightedItems.get(1));
                        }
                        if (operator == 4) {
                            compare.setLogicalOperator(Operators.LogicalOperator.EQUAL);
                        }
                        if (operator == 5) {
                            compare.setLogicalOperator(Operators.LogicalOperator.NOTEQUAL);
                        }
                    }
//                    Into and conditions
                    predicates[i][j] = compare;
                }
            }
            if (predicates[i].length > 1) {
                And lhs = new And(predicates[i][0], predicates[i][1]);
                for (int k = 2; k < predicates[i].length; k++) {
                    lhs = new And(lhs, predicates[i][k]);
                }
                orCandi.add(lhs);
            } else if (predicates[i].length == 1) {
                orCandi.add(predicates[i][0]);
            }
        }
        if (orCandi.size() == 1) {
            return orCandi.get(0);
        } else {
            Or lhs = new Or(orCandi.get(0), orCandi.get(1));
            for (int k = 2; k < orCandi.size(); k++) {
                lhs = new Or(lhs, orCandi.get(k));
            }
            return lhs;
        }
    }
}