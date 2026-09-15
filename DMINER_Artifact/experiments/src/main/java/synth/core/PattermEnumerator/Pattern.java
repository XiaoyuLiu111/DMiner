package synth.core.PattermEnumerator;

import synth.ast.AST;

import java.util.ArrayList;

public class Pattern {
    public ArrayList<Pattern> basicPatterns = new ArrayList<>();

    public ArrayList<NodePattern> nodePatterns = new ArrayList<>();
    public ArrayList<EdgePattern> edgePatterns = new ArrayList<>();

    public AST pattern2Query(){
//        return new Return(new SingleMatch(new PathPattern(path)), new PropertyList(properties));
        return null;
    }

}
