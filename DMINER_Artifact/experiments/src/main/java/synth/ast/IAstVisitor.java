package synth.ast;

import synth.ast.clause.*;
import synth.ast.pattern.PathPattern;
import synth.ast.propertyList.PropertyList;

public interface IAstVisitor {
    public String visit(PropertyList propertyList);
    public String visit(PathPattern pathPattern);
    public String visit(FilterClause filterClause);
    public String visit(MultipleMatch multipleMatch);
    public String visit(SingleMatch singleMatch);
    public String visit(Return returnClause);
    public String visit(With with);
//    public String visit(AbstractFilter abstractFilter);
}
