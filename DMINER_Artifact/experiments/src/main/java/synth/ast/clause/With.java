package synth.ast.clause;

import synth.ast.AST;
import synth.ast.IAstVisitor;
import synth.ast.pred.expr.Aggregation;
import synth.ast.pred.expr.Variable;

import java.util.ArrayList;

public class With extends AST {
    public final ArrayList<Aggregation> aggregations;
    public final ArrayList<Variable> variables;
    public With(ArrayList<Aggregation> aggregations, ArrayList<Variable> variables) {
        this.aggregations = aggregations;
        this.variables = variables;
    }

    @Override
    public String astAccept(IAstVisitor visitor) {
        return visitor.visit(this);
    }
}
