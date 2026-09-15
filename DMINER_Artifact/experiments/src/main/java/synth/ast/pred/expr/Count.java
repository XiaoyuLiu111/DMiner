package synth.ast.pred.expr;

import synth.ast.pred.IPredVisitor;
import synth.ast.pred.Predicate;

public class Count extends Aggregation{
    public final Predicate expression;
    public Count(Predicate expression) {
        this.expression = expression;
    }
    @Override
    public String accept(IPredVisitor visitor) {
        return visitor.visit(this);
    }
}
