package synth.ast.propertyList;

import synth.ast.AST;
import synth.ast.IAstVisitor;
import synth.ast.pred.Predicate;
import synth.ast.pred.expr.Property;

import java.util.ArrayList;

public class PropertyList extends AST {
    public final ArrayList<Property> properties;
    public PropertyList(ArrayList<Property> properties) {
        this.properties = properties;
    }

    @Override
    public String astAccept(IAstVisitor visitor) {
        return visitor.visit(this);
    }
}
