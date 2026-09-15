package synth.core.filterSyn;
import com.microsoft.z3.*;
import synth.core.data.dataStructures.DataStructure;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.Set;

public class ConstraintHelper {

    public static IntExpr abs(Context ctx, IntExpr number){
        IntExpr absoluteVal = (IntExpr) ctx.mkITE(ctx.mkLe(number, ctx.mkInt(0)), ctx.mkMul(number, ctx.mkInt(-1)), number);
        return absoluteVal;
    }

    public static Optimize generateMixConstraints(Context ctx, Optimize optimizer, Integer orNumber, Integer andNumber, int[][][] data,
                                                   IntExpr[][][] numConstants, IntExpr[][][] stringConstants,
                                                   IntExpr[][][][] constants, IntExpr[][] operators,
                                                   ArrayList<Boolean> positiveOrNegative,
                                               LinkedHashSet<DataStructure.Pair> numConstantsPositions,
                                               LinkedHashSet<DataStructure.Pair> stringConstantsPositions,
                                                   Set<Integer> stringOptions){

        Integer andSoftWeight = 100;
        Integer commonConstraintWeight = 1000000; // constraint to make coefficient to be 1, -1, or 0

        BoolExpr[][][] rowConstraints = new BoolExpr[data.length][orNumber+1][andNumber+1];
        //        Constraints for each constant[i][j] are the same
        for(int i=0; i<orNumber+1; i++){
            ArrayList<IntExpr> lessAnd = new ArrayList<>();
            for(int j=0; j<andNumber+1; j++){
                ArrayList<IntExpr> coefficients = new ArrayList<>();

//                1. either string or numerical are all zeros; for string constant 0, -1, or 1
                int numId = 0;
                BoolExpr[] numTmp = new BoolExpr[numConstants[i][j].length];
                for(IntExpr numConstant: numConstants[i][j]){
                    numTmp[numId] = ctx.mkEq(numConstant, ctx.mkInt(0));
                    if(numId<numConstants[i][j].length-1){
                        IntExpr tmpVar = ctx.mkIntConst("zero_num_"+i+"_"+j+"_"+numId);
                        coefficients.add(tmpVar);
                        optimizer.Assert(ctx.mkOr(ctx.mkEq(tmpVar, ctx.mkInt(0)), ctx.mkEq(tmpVar, ctx.mkInt(1))));
                        optimizer.Assert(ctx.mkImplies(ctx.mkNot(ctx.mkEq(numConstant, ctx.mkInt(0))), ctx.mkEq(tmpVar, ctx.mkInt(1))));
                        optimizer.Assert(ctx.mkImplies(ctx.mkEq(numConstant, ctx.mkInt(0)), ctx.mkEq(tmpVar, ctx.mkInt(0))));

                        // No commonConstraint if the variable is for the constant in formula
                        BoolExpr[] commonTmp = new BoolExpr[3];
                        commonTmp[0] = ctx.mkEq(numConstants[i][j][numId], ctx.mkInt(0));
                        commonTmp[1] = ctx.mkEq(numConstants[i][j][numId], ctx.mkInt(1));
                        commonTmp[2] = ctx.mkEq(numConstants[i][j][numId], ctx.mkInt(-1));

                        optimizer.AssertSoft(ctx.mkOr(commonTmp), commonConstraintWeight, "common_"+i+"_"+j+"_"+numId);
                    }
                    numId++;
                }
                BoolExpr[] stringTmp = new BoolExpr[stringConstants[i][j].length];
                IntExpr[] absTmp = new IntExpr[stringConstants[i][j].length-1];
                IntExpr[] sCoefTmp = new IntExpr[stringConstants[i][j].length-1];
                for(int stringId = 0; stringId<stringConstants[i][j].length; stringId++){
                    IntExpr stringConstant = stringConstants[i][j][stringId];
                    stringTmp[stringId] = ctx.mkEq(stringConstant, ctx.mkInt(0));
                    optimizer.AssertSoft(stringTmp[stringId], commonConstraintWeight, "string_"+i+"_"+j+"_"+stringId);
                    if(stringId<stringConstants[i][j].length-1){
                        IntExpr tmpVar = ctx.mkIntConst("zero_string_"+i+"_"+j+"_"+stringId);
                        coefficients.add(tmpVar);
                        optimizer.Assert(ctx.mkOr(ctx.mkEq(tmpVar, ctx.mkInt(0)), ctx.mkEq(tmpVar, ctx.mkInt(1))));
                        optimizer.Assert(ctx.mkImplies(ctx.mkNot(ctx.mkEq(stringConstant, ctx.mkInt(0))), ctx.mkEq(tmpVar, ctx.mkInt(1))));
                        optimizer.Assert(ctx.mkImplies(ctx.mkEq(stringConstant, ctx.mkInt(0)), ctx.mkEq(tmpVar, ctx.mkInt(0))));

                        absTmp[stringId] = abs(ctx, stringConstant);
                        sCoefTmp[stringId] = stringConstants[i][j][stringId];
                        optimizer.Assert(ctx.mkOr(ctx.mkEq(stringConstant, ctx.mkInt(0)),
                                ctx.mkEq(stringConstant, ctx.mkInt(-1)),
                                ctx.mkEq(stringConstant, ctx.mkInt(1))));
                        optimizer.AssertSoft(ctx.mkEq(ctx.mkInt(0), stringConstant), commonConstraintWeight, "common_"+i+"_"+j+"_"+stringId);
                    } else {
                        //  Add option constraints to stringTmp[stringId]
                        BoolExpr[] stringCTmp = new BoolExpr[stringOptions.size()];
                        int optionId = 0;
                        for(Integer option: stringOptions){
                            stringCTmp[optionId] = ctx.mkEq(stringConstants[i][j][stringId], ctx.mkInt(option));
                            optionId++;
                        }

                        optimizer.Assert(ctx.mkOr(stringCTmp));
                    }
                }
//              Add constraint that if string constant is not zero, then sum(abs)=1
                optimizer.Assert(ctx.mkImplies(ctx.mkNot(ctx.mkEq(ctx.mkInt(0), stringConstants[i][j][stringConstants[i][j].length-1])),
                        ctx.mkEq(ctx.mkAdd(sCoefTmp), ctx.mkInt(-1))));
                optimizer.Assert(ctx.mkImplies(ctx.mkEq(ctx.mkInt(0), stringConstants[i][j][stringConstants[i][j].length-1]),
                        ctx.mkEq(ctx.mkAdd(sCoefTmp), ctx.mkInt(0))));
//                Constraints for string constants sum(abs())=0 or sum(abs())=2 or sum(abs())=1, then sum()=0
                BoolExpr[] absSumOptions = new BoolExpr[3];
                absSumOptions[0] = ctx.mkEq(ctx.mkAdd(absTmp), ctx.mkInt(1));
                absSumOptions[1] = ctx.mkEq(ctx.mkAdd(absTmp), ctx.mkInt(2));
                absSumOptions[2] = ctx.mkEq(ctx.mkAdd(absTmp), ctx.mkInt(0));
                optimizer.Assert(ctx.mkOr(absSumOptions));

//                either include constraints as numerical or string
                optimizer.Assert(ctx.mkOr(ctx.mkAnd(numTmp), ctx.mkAnd(stringTmp)));

//        Add soft-constraints
//                optimizer.AssertSoft(ctx.mkAnd(ctx.mkAnd(numTmp), ctx.mkAnd(stringTmp)), 1, String.valueOf((i + 1) * (j + 1)));
//                2. if string not zeros then numerical zeros; if numerical not zeros string zeros;
                optimizer.Assert(ctx.mkImplies(ctx.mkNot(ctx.mkAnd(numTmp)), ctx.mkAnd(stringTmp)));
                optimizer.Assert(ctx.mkImplies(ctx.mkNot(ctx.mkAnd(stringTmp)), ctx.mkAnd(numTmp)));
//                3. Operator either 0, 1, 2, 3, 4, means num >=, num <=, num !=, string =, string !=
                optimizer.Assert(ctx.mkOr(ctx.mkEq(operators[i][j], ctx.mkInt(0)),
                        ctx.mkEq(operators[i][j], ctx.mkInt(1)),
                        ctx.mkEq(operators[i][j], ctx.mkInt(2)),
                        ctx.mkEq(operators[i][j], ctx.mkInt(3)),
                        ctx.mkEq(operators[i][j], ctx.mkInt(4)),
                        ctx.mkEq(operators[i][j], ctx.mkInt(5))));

                for(int rowId=0; rowId<data.length; rowId++) {
//                    TODO: Change formulas to max range of and included
//                4. either numerical constraints for data or string constraints for data
                    ArithExpr[] numSumTmp = new ArithExpr[numConstantsPositions.size()+1];
                    ArithExpr[] stringSumTmp = new ArithExpr[stringConstantsPositions.size()+1];
                    int numSumId = 0;
                    for(DataStructure.Pair numPosition: numConstantsPositions){
                        IntExpr weight = constants[i][j][(int)numPosition.first][(int)numPosition.second];
                        Integer val = data[rowId][(int)numPosition.first][(int)numPosition.second];
                        numSumTmp[numSumId] = ctx.mkMul(weight, ctx.mkInt(val));
                        numSumId++;
                    }
                    numSumTmp[numSumId] = ctx.mkMul(ctx.mkInt(1), numConstants[i][j][numSumId]);
                    int stringSumId = 0;
                    for(DataStructure.Pair stringPosition: stringConstantsPositions){
                        IntExpr weight = constants[i][j][(int)stringPosition.first][(int)stringPosition.second];
                        Integer val = data[rowId][(int)stringPosition.first][(int)stringPosition.second];
                        stringSumTmp[stringSumId] = ctx.mkMul(weight, ctx.mkInt(val));
                        stringSumId++;
                    }
                    stringSumTmp[stringSumId] = ctx.mkMul(ctx.mkInt(1), stringConstants[i][j][stringSumId]);


                    BoolExpr[] implies = new BoolExpr[6];
                    implies[0] = ctx.mkAnd(ctx.mkEq(operators[i][j], ctx.mkInt(0)), ctx.mkGe(ctx.mkAdd(numSumTmp), ctx.mkInt(0)));
                    implies[1] = ctx.mkAnd(ctx.mkEq(operators[i][j], ctx.mkInt(1)), ctx.mkLe(ctx.mkAdd(numSumTmp), ctx.mkInt(0)));
                    implies[3] = ctx.mkAnd(ctx.mkEq(operators[i][j], ctx.mkInt(3)), ctx.mkNot(ctx.mkEq(ctx.mkAdd(numSumTmp), ctx.mkInt(0))));
                    implies[2] = ctx.mkAnd(ctx.mkEq(operators[i][j], ctx.mkInt(2)), ctx.mkEq(ctx.mkAdd(numSumTmp), ctx.mkInt(0)));

                    implies[4] = ctx.mkAnd(ctx.mkEq(operators[i][j], ctx.mkInt(4)), ctx.mkEq(ctx.mkAdd(stringSumTmp), ctx.mkInt(0)));
                    implies[5] = ctx.mkAnd(ctx.mkEq(operators[i][j], ctx.mkInt(5)), ctx.mkNot(ctx.mkEq(ctx.mkAdd(stringSumTmp), ctx.mkInt(0))));

                    rowConstraints[rowId][i][j] = ctx.mkOr(implies);
                    optimizer.Assert(ctx.mkImplies(ctx.mkEq(operators[i][j], ctx.mkInt(0)), ctx.mkAnd(stringTmp)));
                    optimizer.Assert(ctx.mkImplies(ctx.mkEq(operators[i][j], ctx.mkInt(1)), ctx.mkAnd(stringTmp)));
                    optimizer.Assert(ctx.mkImplies(ctx.mkEq(operators[i][j], ctx.mkInt(2)), ctx.mkAnd(stringTmp)));
                    optimizer.Assert(ctx.mkImplies(ctx.mkEq(operators[i][j], ctx.mkInt(3)), ctx.mkAnd(stringTmp)));

                    optimizer.Assert(ctx.mkImplies(ctx.mkEq(operators[i][j], ctx.mkInt(4)), ctx.mkAnd(numTmp)));
                    optimizer.Assert(ctx.mkImplies(ctx.mkEq(operators[i][j], ctx.mkInt(5)), ctx.mkAnd(numTmp)));
                }
                //            Add soft constraints to include less 'and'

                IntExpr coefficientsInAndAllZero = ctx.mkIntConst("and4Or"+"_"+i+j);
                BoolExpr[] inAndZeroCoef = new BoolExpr[coefficients.size()];
                for (int inId = 0; inId < coefficients.size(); inId++) {
                    inAndZeroCoef[inId] = ctx.mkEq(coefficients.get(inId), ctx.mkInt(0));
                }
                optimizer.AssertSoft(ctx.mkAnd(inAndZeroCoef), andSoftWeight, "lessAnd"+"_"+i+"_"+j);
                lessAnd.add(coefficientsInAndAllZero);
            }
        }


        for(int rowId=0; rowId<data.length; rowId++){
            BoolExpr[] tmp = new BoolExpr[orNumber+1];
            for(int i=0; i<orNumber+1; i++){
                tmp[i] = ctx.mkAnd(rowConstraints[rowId][i]);
            }
            if(orNumber==0){
                if(positiveOrNegative.get(rowId)){
                    optimizer.Assert(tmp[0]);
                } else {
                    optimizer.Assert(ctx.mkNot(tmp[0]));
                }
            } else {
                if(positiveOrNegative.get(rowId)){
                    optimizer.Assert(ctx.mkOr(tmp));
                } else {
                    optimizer.Assert(ctx.mkNot(ctx.mkOr(tmp)));
                }
            }
        }

        return optimizer;
    }

    public static Optimize generateNumConstraints(Context ctx, Optimize optimizer, Integer orNumber, Integer andNumber, int[][][] data,
                                                  IntExpr[][][] numConstants, IntExpr[][][] stringConstants,
                                                  IntExpr[][][][] constants, IntExpr[][] operators,
                                                  ArrayList<Boolean> positiveOrNegative,
                                                  LinkedHashSet<DataStructure.Pair> numConstantsPositions,
                                                  LinkedHashSet<DataStructure.Pair> stringConstantsPositions,
                                                  Set<Integer> stringOptions){

        Integer andSoftWeight = 1000;
        Integer commonConstraintWeight = 1000000; // constraint to make coefficient to be 1, -1, or 0
        Integer eachSoftWeight = 1000;

        BoolExpr[][][] rowConstraints = new BoolExpr[data.length][orNumber+1][andNumber+1];
        //        Constraints for each constant[i][j] are the same
        for(int i=0; i<orNumber+1; i++){

            for(int j=0; j<andNumber+1; j++){
                ArrayList<IntExpr> coefficients = new ArrayList<>();
//                1. either string or numerical are all zeros; for string constant 0, -1, or 1
                int numId = 0;
                BoolExpr[] numTmp = new BoolExpr[numConstants[i][j].length];
                for(IntExpr numConstant: numConstants[i][j]){
                    numTmp[numId] = ctx.mkEq(numConstant, ctx.mkInt(0));
                    if(numId<numConstants[i][j].length-1){
                        IntExpr tmpVar = ctx.mkIntConst("zero_num_"+i+"_"+j+"_"+numId);
                        coefficients.add(tmpVar);
                        optimizer.Assert(ctx.mkOr(ctx.mkEq(tmpVar, ctx.mkInt(0)), ctx.mkEq(tmpVar, ctx.mkInt(1))));
                        optimizer.Assert(ctx.mkImplies(ctx.mkNot(ctx.mkEq(numConstant, ctx.mkInt(0))), ctx.mkEq(tmpVar, ctx.mkInt(1))));
                        optimizer.Assert(ctx.mkImplies(ctx.mkEq(numConstant, ctx.mkInt(0)), ctx.mkEq(tmpVar, ctx.mkInt(0))));

                        // No commonConstraint if the variable is for the constant in formula
                        BoolExpr[] commonTmp = new BoolExpr[3];
                        commonTmp[0] = ctx.mkEq(numConstants[i][j][numId], ctx.mkInt(0));
                        commonTmp[1] = ctx.mkEq(numConstants[i][j][numId], ctx.mkInt(1));
                        commonTmp[2] = ctx.mkEq(numConstants[i][j][numId], ctx.mkInt(-1));

                        optimizer.AssertSoft(ctx.mkOr(commonTmp), commonConstraintWeight, "common_"+i+"_"+j+"_"+numId);
                    }
                    numId++;
                }

                optimizer.Assert(ctx.mkOr(ctx.mkEq(operators[i][j], ctx.mkInt(0)),
                        ctx.mkEq(operators[i][j], ctx.mkInt(1)),
                        ctx.mkEq(operators[i][j], ctx.mkInt(2)),
                        ctx.mkEq(operators[i][j], ctx.mkInt(3))));

                for(int rowId=0; rowId<data.length; rowId++) {
//                4. either numerical constraints for data or string constraints for data
                    ArithExpr[] numSumTmp = new ArithExpr[numConstantsPositions.size()+1];
                    int numSumId = 0;
                    for(DataStructure.Pair numPosition: numConstantsPositions){
                        IntExpr weight = constants[i][j][(int)numPosition.first][(int)numPosition.second];
                        Integer val = data[rowId][(int)numPosition.first][(int)numPosition.second];
                        numSumTmp[numSumId] = ctx.mkMul(weight, ctx.mkInt(val));
                        numSumId++;
                    }
                    numSumTmp[numSumId] = ctx.mkMul(ctx.mkInt(1), numConstants[i][j][numSumId]);
                    BoolExpr[] implies = new BoolExpr[4];
                    implies[0] = ctx.mkAnd(ctx.mkEq(operators[i][j], ctx.mkInt(0)), ctx.mkGe(ctx.mkAdd(numSumTmp), ctx.mkInt(0)));
                    implies[1] = ctx.mkAnd(ctx.mkEq(operators[i][j], ctx.mkInt(1)), ctx.mkLe(ctx.mkAdd(numSumTmp), ctx.mkInt(0)));
                    implies[3] = ctx.mkAnd(ctx.mkEq(operators[i][j], ctx.mkInt(3)), ctx.mkNot(ctx.mkEq(ctx.mkAdd(numSumTmp), ctx.mkInt(0))));
                    implies[2] = ctx.mkAnd(ctx.mkEq(operators[i][j], ctx.mkInt(2)), ctx.mkEq(ctx.mkAdd(numSumTmp), ctx.mkInt(0)));

                    rowConstraints[rowId][i][j] = ctx.mkOr(implies);
                }
                //            Add soft constraints to include less 'and'
                BoolExpr[] inAndZeroCoef = new BoolExpr[coefficients.size()];
                for (int inId = 0; inId < coefficients.size(); inId++) {
                    inAndZeroCoef[inId] = ctx.mkEq(coefficients.get(inId), ctx.mkInt(0));
                }
                optimizer.AssertSoft(ctx.mkAnd(inAndZeroCoef), andSoftWeight, "lessAnd_"+i+"_"+j);

            }
        }


        for(int rowId=0; rowId<data.length; rowId++){
            BoolExpr[] tmp = new BoolExpr[orNumber+1];
            for(int i=0; i<orNumber+1; i++){
                tmp[i] = ctx.mkAnd(rowConstraints[rowId][i]);
            }
            if(orNumber==0){
                if(positiveOrNegative.get(rowId)){
                    optimizer.Assert(tmp[0]);
                } else {
                    optimizer.Assert(ctx.mkNot(tmp[0]));
                }
            } else {
                if(positiveOrNegative.get(rowId)){
                    optimizer.Assert(ctx.mkOr(tmp));
                } else {
                    optimizer.Assert(ctx.mkNot(ctx.mkOr(tmp)));
                }
            }
        }

        return optimizer;
    }

    public static Optimize generateStringConstraints(Context ctx, Optimize optimizer, Integer orNumber, Integer andNumber, int[][][] data,
                                                  IntExpr[][][] numConstants, IntExpr[][][] stringConstants,
                                                  IntExpr[][][][] constants, IntExpr[][] operators,
                                                  ArrayList<Boolean> positiveOrNegative,
                                                  LinkedHashSet<DataStructure.Pair> numConstantsPositions,
                                                  LinkedHashSet<DataStructure.Pair> stringConstantsPositions,
                                                  Set<Integer> stringOptions){

        Integer andSoftWeight = 1000;
        Integer commonConstraintWeight = 1000000; // constraint to make coefficient to be 1, -1, or 0
        Integer eachSoftWeight = 1000;

        BoolExpr[][][] rowConstraints = new BoolExpr[data.length][orNumber+1][andNumber+1];
        ArrayList<IntExpr> allCoefficientsZero = new ArrayList<>();
        //        Constraints for each constant[i][j] are the same
        for(int i=0; i<orNumber+1; i++){
            ArrayList<IntExpr> lessAnd = new ArrayList<>();

            for(int j=0; j<andNumber+1; j++){
                ArrayList<IntExpr> coefficients = new ArrayList<>();
//                1. either string or numerical are all zeros; for string constant 0, -1, or 1
                BoolExpr[] stringTmp = new BoolExpr[stringConstants[i][j].length];
                IntExpr[] absTmp = new IntExpr[stringConstants[i][j].length-1];
                IntExpr[] sCoefTmp = new IntExpr[stringConstants[i][j].length-1];
                for(int stringId = 0; stringId<stringConstants[i][j].length; stringId++){
                    IntExpr stringConstant = stringConstants[i][j][stringId];
                    stringTmp[stringId] = ctx.mkEq(stringConstant, ctx.mkInt(0));

                    if(stringId<stringConstants[i][j].length-1){
                        IntExpr tmpVar = ctx.mkIntConst("zero_string_"+i+"_"+j+"_"+stringId);
                        allCoefficientsZero.add(tmpVar);
                        coefficients.add(tmpVar);
                        optimizer.Assert(ctx.mkOr(ctx.mkEq(tmpVar, ctx.mkInt(0)), ctx.mkEq(tmpVar, ctx.mkInt(1))));
                        optimizer.Assert(ctx.mkImplies(ctx.mkNot(ctx.mkEq(stringConstant, ctx.mkInt(0))), ctx.mkEq(tmpVar, ctx.mkInt(1))));
                        optimizer.Assert(ctx.mkImplies(ctx.mkEq(stringConstant, ctx.mkInt(0)), ctx.mkEq(tmpVar, ctx.mkInt(0))));

                        absTmp[stringId] = abs(ctx, stringConstant);
                        sCoefTmp[stringId] = stringConstants[i][j][stringId];
                        optimizer.Assert(ctx.mkOr(ctx.mkEq(stringConstant, ctx.mkInt(0)),
                                ctx.mkEq(stringConstant, ctx.mkInt(-1)),
                                ctx.mkEq(stringConstant, ctx.mkInt(1))));
                        optimizer.AssertSoft(ctx.mkEq(stringConstant, ctx.mkInt(0)), commonConstraintWeight, "common_"+i+"_"+j+"_"+stringId);
                    } else {
                        //  Add option constraints to stringTmp[stringId]
                        BoolExpr[] stringCTmp = new BoolExpr[stringOptions.size()];
                        int optionId = 0;
                        for(Integer option: stringOptions){
                            stringCTmp[optionId] = ctx.mkEq(stringConstants[i][j][stringId], ctx.mkInt(option));
                            optionId++;
                        }

                        optimizer.Assert(ctx.mkOr(stringCTmp));
                    }
                }
                optimizer.Assert(ctx.mkImplies(ctx.mkNot(ctx.mkEq(ctx.mkInt(0), stringConstants[i][j][stringConstants[i][j].length-1])),
                        ctx.mkEq(ctx.mkAdd(absTmp), ctx.mkInt(1))));
                optimizer.Assert(ctx.mkImplies(ctx.mkEq(ctx.mkInt(0), stringConstants[i][j][stringConstants[i][j].length-1]),
                        ctx.mkEq(ctx.mkAdd(sCoefTmp), ctx.mkInt(0))));
                optimizer.Assert(ctx.mkImplies(ctx.mkEq(ctx.mkInt(0), stringConstants[i][j][stringConstants[i][j].length-1]),
                        ctx.mkOr(ctx.mkEq(ctx.mkAdd(absTmp), ctx.mkInt(0)), ctx.mkEq(ctx.mkAdd(absTmp), ctx.mkInt(2)))));
//                Constraints for string constants sum(abs())=0 or sum(abs())=2, then sum()=0
                BoolExpr[] absSumOptions = new BoolExpr[3];
                absSumOptions[0] = ctx.mkEq(ctx.mkAdd(absTmp), ctx.mkInt(1));
                absSumOptions[1] = ctx.mkEq(ctx.mkAdd(absTmp), ctx.mkInt(2));
                absSumOptions[2] = ctx.mkEq(ctx.mkAdd(absTmp), ctx.mkInt(0));
                optimizer.Assert(ctx.mkOr(absSumOptions));

//                3. Operator either 0, 1, 2, 3, 4, means num >=, num <=, num !=, string =, string !=
                optimizer.Assert(ctx.mkOr(
                        ctx.mkEq(operators[i][j], ctx.mkInt(4)),
                        ctx.mkEq(operators[i][j], ctx.mkInt(5))));

                for(int rowId=0; rowId<data.length; rowId++) {
//                4. either numerical constraints for data or string constraints for data
                    ArithExpr[] stringSumTmp = new ArithExpr[stringConstantsPositions.size()+1];
                    int stringSumId = 0;
                    for(DataStructure.Pair stringPosition: stringConstantsPositions){
                        IntExpr weight = constants[i][j][(int)stringPosition.first][(int)stringPosition.second];
                        Integer val = data[rowId][(int)stringPosition.first][(int)stringPosition.second];
                        stringSumTmp[stringSumId] = ctx.mkMul(weight, ctx.mkInt(val));
                        stringSumId++;
                    }

                    stringSumTmp[stringSumId] = ctx.mkMul(ctx.mkInt(1), stringConstants[i][j][stringSumId]);

                    BoolExpr[] implies = new BoolExpr[2];
                    implies[0] = ctx.mkAnd(ctx.mkEq(operators[i][j], ctx.mkInt(4)), ctx.mkEq(ctx.mkAdd(stringSumTmp), ctx.mkInt(0)));
                    implies[1] = ctx.mkAnd(ctx.mkEq(operators[i][j], ctx.mkInt(5)), ctx.mkNot(ctx.mkEq(ctx.mkAdd(stringSumTmp), ctx.mkInt(0))));

                    rowConstraints[rowId][i][j] = ctx.mkOr(implies);
                }
                //            Add soft constraints to include less 'and'
                BoolExpr[] inAndZeroCoef = new BoolExpr[coefficients.size()];
                for (int inId = 0; inId < coefficients.size(); inId++) {
                    inAndZeroCoef[inId] = ctx.mkEq(coefficients.get(inId), ctx.mkInt(0));
                }
                optimizer.AssertSoft(ctx.mkAnd(inAndZeroCoef), andSoftWeight, "lessAnd_"+i+"_"+j);
            }
        }


        for(int rowId=0; rowId<data.length; rowId++){
            BoolExpr[] tmp = new BoolExpr[orNumber+1];
            for(int i=0; i<orNumber+1; i++){
                tmp[i] = ctx.mkAnd(rowConstraints[rowId][i]);
            }
            if(positiveOrNegative.get(rowId)){
                optimizer.Assert(ctx.mkOr(tmp));
            } else {
                optimizer.Assert(ctx.mkNot(ctx.mkOr(tmp)));
            }
        }

        return optimizer;
    }
}
