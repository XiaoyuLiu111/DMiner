package synth.ast.pred;

public class And extends Predicate {
    public final Predicate lhs;
    public final Predicate rhs;

    public And(Predicate lhs, Predicate rhs) {
        this.lhs = lhs;
        this.rhs = rhs;
    }

    @Override
    public String accept(IPredVisitor visitor) {
        return visitor.visit(this);
    }
}
