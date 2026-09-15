package synth.ast.pred;

public abstract class Predicate {

    public abstract String accept(IPredVisitor visitor);
}
