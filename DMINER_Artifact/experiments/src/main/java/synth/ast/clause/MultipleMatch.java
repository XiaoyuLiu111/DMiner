package synth.ast.clause;

import synth.ast.AST;
import synth.ast.IAstVisitor;

public class MultipleMatch extends AST {
    public final AST clause;
    public final SingleMatch match;
    public MultipleMatch(AST clause, SingleMatch match) {
        this.clause = clause;
        this.match = match;
    }


    @Override
    public String astAccept(IAstVisitor visitor) {
        return visitor.visit(this);
    }
}
