package synth.ast.clause;

import synth.ast.AST;
import synth.ast.IAstVisitor;
import synth.ast.propertyList.PropertyList;

public class Return extends AST {
    public final AST clause;
    public final PropertyList propertyList;

    public Return(AST clause, PropertyList propertyList) {
        this.clause = clause;
        this.propertyList = propertyList;
    }

    @Override
    public String astAccept(IAstVisitor visitor) {
        return visitor.visit(this);
    }
}
