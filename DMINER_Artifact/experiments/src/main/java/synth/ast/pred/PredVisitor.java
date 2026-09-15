package synth.ast.pred;

import synth.ast.pred.expr.*;

public class PredVisitor implements IPredVisitor{

    /**
     *
     * param: Include all operators in
     *          Pred P ::= E lop E | IsNull(E) | P /\ P | P \/ P | not P
     *        Include all expressions in
     *          Expr E ::= x | x.k | v | Agg(E) | E op E
     * @return A string of Cypher query
     */

    @Override
    public String visit(And and){
        if(and.lhs!=null || and.rhs!=null){
            if(and.lhs == null){
                return and.rhs.accept(this);
            }
            if(and.rhs == null){
                return and.lhs.accept(this);
            }
            String lhs = and.lhs.accept(this);
            String rhs = and.rhs.accept(this);
            if(!lhs.isEmpty() || !rhs.isEmpty()){
                if(lhs.isEmpty()){
                    return rhs;
                }
                if(rhs.isEmpty()){
                    return lhs;
                }
                if(!lhs.isEmpty() && !rhs.isEmpty()){
                    return "(" + lhs + ")" + " AND " + "(" + rhs + ")";
                }
            }
        }
        return "";
    }

    @Override
    public String visit(Or or) {
        if(or.lhs == null){
            return or.rhs.accept(this);
        }
        if(or.rhs == null){
            return or.lhs.accept(this);
        }
        return "(" + or.lhs.accept(this) + ")" + " OR " + "(" + or.rhs.accept(this) + ")";

    }

    @Override
    public String visit(Not not) {
        return "NOT " + "(" + not.expression.accept(this) + ")";
    }

    @Override
    public String visit(BinaryComparison binaryComparison) {

        if(binaryComparison.lhsExpression==null || binaryComparison.rhsExpression==null){
            return "";
        }
        switch (binaryComparison.logicalOperator){
            case SMALLER:
                return binaryComparison.lhsExpression.accept(this) + "<" + binaryComparison.rhsExpression.accept(this);
            case SMALLEROREQUAL:
                return binaryComparison.lhsExpression.accept(this) + "<=" + binaryComparison.rhsExpression.accept(this);
            case LARGER:
                return binaryComparison.lhsExpression.accept(this) + ">" + binaryComparison.rhsExpression.accept(this);
            case LARGEROREQUAL:
                return binaryComparison.lhsExpression.accept(this) + ">=" + binaryComparison.rhsExpression.accept(this);
            case EQUAL:
                return binaryComparison.lhsExpression.accept(this) + "=" + binaryComparison.rhsExpression.accept(this);
            case NOTEQUAL:
                return binaryComparison.lhsExpression.accept(this) + "<>" + binaryComparison.rhsExpression.accept(this);
            default:
                return null;
        }
    }

    @Override
    public String visit(IsNull isNull) {
        return isNull.expression.accept(this) + " IS NULL";
    }

    @Override
    public String visit(Value value){
        return String.valueOf(value.value);
    }

    @Override
    public String visit(Variable variable){
        return String.valueOf(variable.variableName);
    }

    @Override
    public String visit(Property property) {
//        TODO: Deprecate when expressions is complete
        if(property.operator.length() > 0){
            return String.valueOf(property.operator) + "(" + String.valueOf(property.variableName) + "." + String.valueOf(property.propertyName) + ")";
        }
        if(property.propertyName != null) {
            return String.valueOf(property.variableName) + "." + String.valueOf(property.propertyName);
        } else {
            return String.valueOf(property.variableName);
        }
    }

    @Override
    public String visit(Sum sum){
        return "sum(" + sum.expression.accept(this) + ")";
    }
    @Override
    public String visit(Min min){
        return "min(" + min.expression.accept(this) + ")";
    }

    @Override
    public String visit(Max max){
        return "max(" + max.expression.accept(this) + ")";
    }

    @Override
    public String visit(Avg avg){
        return "avg(" + avg.expression.accept(this) + ")";
    }

    @Override
    public String visit(Count cnt){
        return "count(" + cnt.expression.accept(this) + ")";
    }

    @Override
    public String visit(BinaryCalculation calculation){
        if(calculation.rhs == null){
            return calculation.lhs.accept(this);
        }
        switch(calculation.calculationOperator){
            case ADD:
                return calculation.lhs.accept(this) + "+" + calculation.rhs.accept(this);
            case MINUS:
                return calculation.lhs.accept(this) + "-" + calculation.rhs.accept(this);
            case MULTIPLE:
                return calculation.lhs.accept(this) + "*" + calculation.rhs.accept(this);
            case DIVIDE:
                return calculation.lhs.accept(this) + "/" + calculation.rhs.accept(this);
            default:
                return null;
        }
    }
}
