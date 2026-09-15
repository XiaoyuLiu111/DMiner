package synth.ast.pred.expr;

import synth.ast.pred.IPredVisitor;
import synth.ast.pred.Predicate;

import java.util.HashMap;

public class Property extends Predicate {
    public final String propertyName;
    public final String variableName;
    public String operator="";
    public HashMap<String,Integer> data;
    public Property(String propertyName, String variableName) {
        this.propertyName = propertyName;
        this.variableName = variableName;
    }
    @Override
    public String accept(IPredVisitor visitor) {
        return visitor.visit(this);
    }

    public Property copy() {
        Property newProperty = new Property(this.propertyName, this.variableName);
        newProperty.operator = this.operator;
        newProperty.data = new HashMap<>(this.data);
        return newProperty;
    }

    public String toString() {
        String var = "";
        if(this.propertyName != null && !this.propertyName.equals("full")) {
            var = this.variableName + "." + String.valueOf(this.propertyName);
        } else {
            var = String.valueOf(this.variableName);
        }
        if(this.operator.length() > 0){
//            String var = "";
//            if(this.propertyName != null && !this.propertyName.equals("full")) {
//                var = this.variableName + "." + String.valueOf(this.propertyName);
//            } else {
//                var = String.valueOf(this.variableName);
//            }
            if(this.operator.equals("empty")){
                return var;
            }
            return String.valueOf(this.operator) + "(" + var + ")";
        }
        return var;
//        if(this.propertyName != null) {
//            return String.valueOf(this.variableName) + "." + String.valueOf(this.propertyName);
//        } else {
//            return String.valueOf(this.variableName);
//        }
    }
}
