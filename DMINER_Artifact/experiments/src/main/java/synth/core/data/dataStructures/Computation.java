package synth.core.data.dataStructures;

import java.util.ArrayList;

public class Computation {
    //    data structure for lowest layer
    public String operator;
    public String property;
    public ArrayList<String> dataID = new ArrayList<>(); // n/e + ID
//    data structure for higher layer
    public Computation lhs;
    public Computation rhs;


}
