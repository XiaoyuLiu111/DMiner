package synth.ast;

public abstract class AST {
    public abstract String astAccept(IAstVisitor visitor);
}
