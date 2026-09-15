package synth.ast.pred;

public class Operators {
    public enum Calculation{
        ADD,
        MINUS,
        MULTIPLE,
        DIVIDE
    }

    public enum LogicalOperator{
        SMALLER,
        SMALLEROREQUAL,
        LARGER,
        LARGEROREQUAL,
        EQUAL,
        NOTEQUAL
    }
}
