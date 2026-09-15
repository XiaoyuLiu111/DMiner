package synth.ast.pred.expr;

import synth.ast.pred.IPredVisitor;
import synth.ast.pred.Predicate;

public abstract class Aggregation extends Predicate {
   public abstract String accept(IPredVisitor visitor);
}
