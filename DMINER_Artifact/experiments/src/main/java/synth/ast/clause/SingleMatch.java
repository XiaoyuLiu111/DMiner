package synth.ast.clause;

import synth.ast.AST;
import synth.ast.IAstVisitor;
import synth.ast.pattern.PathPattern;

public class SingleMatch extends AST {
    public final PathPattern pathPattern;

    public SingleMatch(PathPattern pathPattern) {
        this.pathPattern = pathPattern;
    }

    @Override
    public String astAccept(IAstVisitor visitor) {
        return visitor.visit(this);
    }
}
