package synth.ast.pred.expr;

import synth.ast.pred.IPredVisitor;
import synth.ast.pred.Predicate;

public class Variable extends Predicate {

//    variable has to be either Node instance or Edge instance
    public final String variableName;
    public Variable(String variableName) {
        this.variableName = variableName;
    }
    @Override
    public String accept(IPredVisitor visitor) {
        return visitor.visit(this);
    }
}
