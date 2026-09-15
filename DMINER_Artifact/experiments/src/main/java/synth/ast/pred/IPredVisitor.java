package synth.ast.pred;

import synth.ast.pred.expr.*;

public interface IPredVisitor {

    public String visit(And and);

    public String visit(Or or);

    public String visit(Not not);

    public String visit(BinaryComparison binaryComparison);

    public String visit(IsNull isNull);

    public String visit(Value value);
    public String visit(Variable variable);
    public String visit(Property property);
    public String visit(Sum sum);
    public String visit(Min min);
    public String visit(Max max);
    public String visit(Avg avg);
    public String visit(Count cnt);
    public String visit(BinaryCalculation calculation);
}
