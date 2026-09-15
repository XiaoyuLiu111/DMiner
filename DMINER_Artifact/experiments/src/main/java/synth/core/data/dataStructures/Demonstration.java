package synth.core.data.dataStructures;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;

public class Demonstration {
    public Demonstration(InputGraph inputGraph, HashMap<String, ArrayList<String>> mapping1, HashMap<String, ArrayList<String>> mapping2, ArrayList<Computation> mapping3) {
        this.inputGraph = inputGraph;
        this.mapping1 = mapping1;
        this.mapping2 = mapping2;
        this.mapping3 = mapping3;
    }

    public InputGraph inputGraph;
    public HashMap<String, ArrayList<String>> mapping1; // n/e+ID -> n/e+ID
    public HashMap<String, ArrayList<String>> mapping2; // n/e+ID -> property
    public ArrayList<Computation> mapping3;
    public ArrayList<ArrayList<String>> correspondence;
}
