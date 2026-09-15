package synth.ast.pred;

public class Not extends Predicate {
    public final Predicate expression;

    public Not(Predicate expression) {
        this.expression = expression;
    }
    @Override
    public String accept(IPredVisitor visitor) {
        return visitor.visit(this);
    }
}
