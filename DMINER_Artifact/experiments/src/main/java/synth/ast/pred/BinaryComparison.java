package synth.ast.pred;

public class BinaryComparison extends Predicate {
    public Predicate lhsExpression;
    public Predicate rhsExpression;
    public Operators.LogicalOperator logicalOperator;

    public Predicate getLhsExpression() {
        return lhsExpression;
    }

    public void setLhsExpression(Predicate lhsExpression) {
        this.lhsExpression = lhsExpression;
    }

    public Predicate getRhsExpression() {
        return rhsExpression;
    }

    public void setRhsExpression(Predicate rhsExpression) {
        this.rhsExpression = rhsExpression;
    }

    public Operators.LogicalOperator getLogicalOperator() {
        return logicalOperator;
    }

    public void setLogicalOperator(Operators.LogicalOperator logicalOperator) {
        this.logicalOperator = logicalOperator;
    }

    public BinaryComparison(Predicate lhsExpression, Predicate rhsExpression, Operators.LogicalOperator logicalOperator) {
        this.lhsExpression = lhsExpression;
        this.rhsExpression = rhsExpression;
        this.logicalOperator = logicalOperator;
    }

    @Override
    public String accept(IPredVisitor visitor) {
        return visitor.visit(this);
    }
}
