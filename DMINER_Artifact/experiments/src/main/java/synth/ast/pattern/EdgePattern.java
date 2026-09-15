package synth.ast.pattern;

public class EdgePattern extends ItemPattern{
    /*
    Data structure for AST
     */
    public enum Directions{
        RIGHT,
        LEFT,
        BIDIRECTION
    }

    public String getVariableName() {
        return variableName;
    }

    public void setVariableName(String variableName) {
        this.variableName = variableName;
    }

    public String variableName;
    public final String label;
    public String start;
    public String end;
    public String id;
    public final Directions direction;

    public EdgePattern(String variableName, String label, String start, String end, String id, Directions direction) {
        this.variableName = variableName;
        this.label = label;
        this.start = start;
        this.end = end;
        this.id = id;
        this.direction = direction;
    }

    @Override
    public String toCypher() {
        if(this.variableName == null){
            switch (this.direction) {
                case RIGHT:
                    return "-"+"["+":"+this.label+"]"+"->";
                case LEFT:
                    return "<-"+"["+":"+this.label+"]"+"-";
                case BIDIRECTION:
                    return "-"+"["+":"+this.label+"]"+"-";
                default:
                    return null;
            }
        } else {
            switch (this.direction) {
            case RIGHT:
                return "-"+"["+this.variableName+":"+this.label+"]"+"->";
            case LEFT:
                return "<-"+"["+this.variableName+":"+this.label+"]"+"-";
            case BIDIRECTION:
                return "<-"+"["+this.variableName+":"+this.label+"]"+"->";
            default:
                return null;
            }
        }
    }
}
