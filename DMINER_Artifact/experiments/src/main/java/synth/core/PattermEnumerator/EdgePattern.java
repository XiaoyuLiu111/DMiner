package synth.core.PattermEnumerator;

public class EdgePattern {
    public EdgePattern(String label, String variable, synth.ast.pattern.EdgePattern.Directions direction) {
        this.label = label;
        this.variable = variable;
        this.direction = direction;
    }

    public String label;
    public String variable;
    public synth.ast.pattern.EdgePattern.Directions direction;
}
