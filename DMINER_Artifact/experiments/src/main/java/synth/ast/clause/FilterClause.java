package synth.ast.clause;

import synth.ast.AST;
import synth.ast.IAstVisitor;
import synth.ast.pred.Predicate;

public class FilterClause extends AST {
    public final AST clause;
    public final Predicate predicate;
    public FilterClause(AST clause, Predicate predicate) {
        this.clause = clause;
        this.predicate = predicate;
    }

    @Override
    public String astAccept(IAstVisitor visitor) {
        return visitor.visit(this);
    }
}
