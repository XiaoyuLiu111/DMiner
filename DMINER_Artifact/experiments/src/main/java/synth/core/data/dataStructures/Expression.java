package synth.core.data.dataStructures;

import synth.ast.pred.expr.Property;

import java.util.ArrayList;

public class Expression {
    public ArrayList<String> symbols = new ArrayList<>();
    public ArrayList<Property> atoms = new ArrayList<>();
}
