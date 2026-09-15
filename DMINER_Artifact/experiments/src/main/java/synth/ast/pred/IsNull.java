package synth.ast.pred;

public class IsNull extends Predicate{
    public final Predicate expression;

    public IsNull(Predicate expression) {
        this.expression = expression;
    }

    @Override
    public String accept(IPredVisitor visitor) {
        return visitor.visit(this);
    }
}
