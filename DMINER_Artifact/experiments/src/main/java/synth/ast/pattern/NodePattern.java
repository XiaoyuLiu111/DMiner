package synth.ast.pattern;

public class NodePattern extends ItemPattern{
    public String getVariableName() {
        return variableName;
    }

    public void setVariableName(String variableName) {
        this.variableName = variableName;
    }

    public String variableName;
    public String label;
    public String id;

    public NodePattern(String label, String id) {
        this.label = label;
        this.id = id;
    }

    @Override
    public String toCypher(){
        return "(" + this.variableName + ":" + this.label + ")";
    }
}
