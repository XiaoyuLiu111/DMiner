package synth.ast.pred.expr;

import synth.ast.pred.IPredVisitor;
import synth.ast.pred.Operators;
import synth.ast.pred.Predicate;

public class BinaryCalculation extends Aggregation{
    public Predicate getLhs() {
        return lhs;
    }

    public void setLhs(Predicate lhs) {
        this.lhs = lhs;
    }

    public Predicate getRhs() {
        return rhs;
    }

    public void setRhs(Predicate rhs) {
        this.rhs = rhs;
    }

    public Operators.Calculation getCalculationOperator() {
        return calculationOperator;
    }

    public void setCalculationOperator(Operators.Calculation calculationOperator) {
        this.calculationOperator = calculationOperator;
    }

    public Predicate lhs;
    public Predicate rhs;
    public Operators.Calculation calculationOperator;
    public BinaryCalculation(Predicate lhs, Predicate rhs, Operators.Calculation calculationOperator) {
        this.lhs = lhs;
        this.rhs = rhs;
        this.calculationOperator = calculationOperator;
    }
    @Override
    public String accept(IPredVisitor visitor) {
        return visitor.visit(this);
    }
}
