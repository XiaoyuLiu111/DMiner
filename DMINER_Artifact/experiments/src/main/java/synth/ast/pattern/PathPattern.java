package synth.ast.pattern;

import synth.ast.AST;
import synth.ast.IAstVisitor;

import java.util.ArrayList;

public class PathPattern extends AST {
    public final ArrayList<ArrayList<ItemPattern>> patterns;
    public PathPattern(ArrayList<ArrayList<ItemPattern>> patterns) {
        this.patterns = patterns;
    }

    @Override
    public String astAccept(IAstVisitor visitor) {
        return visitor.visit(this);
    }
}
