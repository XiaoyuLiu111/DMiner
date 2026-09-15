package synth.core.QuerySketchSyn;

import com.microsoft.z3.*;
import synth.ast.pred.expr.Property;
import synth.core.PatternEvaluator;
import synth.core.data.dataStructures.Demonstration;
import synth.core.data.dataStructures.Edge;
import synth.core.data.dataStructures.Node;
import synth.core.PattermEnumerator.Helper;

import java.util.*;

import static synth.core.filterSyn.Helpers.dataHelper;

public class SketchSynthesizer<VarsReturn> implements Iterable<VarsReturn> {
    public ArrayList<Demonstration> demonstrations;
    public Context ctx = new Context();
    public Solver solver = this.ctx.mkSolver();
    public Model solution;
    public Helper helper;
    public HashMap<String, ArrayList<String>> element2Property = new HashMap<>();
    public HashMap<String, ArrayList<String>> nodeLabel2Properties = new HashMap<>(); // label -> [properties]
    public HashMap<String, ArrayList<String>> edgeLabel2Properties = new HashMap<>(); // label -> [properties]

    public ArrayList<String> variableName;
    public ArrayList<ArrayList<String>> values;

    public HashMap<String, HashMap<String, ArrayList<BoolExpr>>> element2PathAVar = new HashMap<>();

    public BoolExpr[] pathVars;
    public BoolExpr[][] varPropertyVars;

    public Boolean started = false;
    public Boolean canFind = true;
    public ArrayList<Integer> demoIDs;

    public static HashMap<String, ArrayList<String>> toArrayHelper(HashMap<String, HashSet<String>> hashset){
        HashMap<String, ArrayList<String>> wArray = new HashMap<>();
        for(String key: hashset.keySet()){
            wArray.put(key, new ArrayList<>(hashset.get(key)));
        }
        return wArray;
    }

    public SketchSynthesizer(ArrayList<Demonstration> demonstrations, PatternEvaluator.ReturnQuery data, ArrayList<Integer> demoIDs) {
        this.demonstrations = demonstrations;
        this.variableName = data.variableName;
        this.values = data.vals;
        this.demoIDs = demoIDs;
    }

    public static class VarsReturn{
        public VarsReturn(ArrayList<Integer> toInclude, ArrayList<Integer> toExclude, ArrayList<Property> properties) {
            this.toInclude = toInclude;
            this.properties = properties;
            this.toExclude = toExclude;
        }

        public ArrayList<Integer> toInclude;
        public ArrayList<Property> properties;
        public ArrayList<Integer> toExclude;
    }

    @Override
    public Iterator iterator() {
        Iterator<SketchSynthesizer.VarsReturn> it = new Iterator<>() {
            @Override
            public boolean hasNext() {
                if(helper == null){
                    helper = new Helper(demonstrations, demoIDs);
                }
                if(element2Property.isEmpty()){
                    helper.graphEle2Property();
                    element2Property = toArrayHelper(helper.element2Property);
                }
                if(nodeLabel2Properties.isEmpty() || edgeLabel2Properties.isEmpty()){
                    helper.label2Property();
                    nodeLabel2Properties = toArrayHelper(helper.nodeLabel2Properties);
                    edgeLabel2Properties = toArrayHelper(helper.edgeLabel2Properties);
                }
                if(!started){
                    genVars();
                    genConstraints();
                }
                if(!canFind){
                    return false;
                }
                if (solver.check() == Status.SATISFIABLE) {
                    solution = solver.getModel();
                    return true;
                }
                return false;
            }

            @Override
            public SketchSynthesizer.VarsReturn next() {
                ban();
                return constraint2Return();
            }
        };
        return it;
    }

    /*
        Generate all variables for constraint solving problem;
        Name of var includes variable name and property
     */
    public void genVars() {
        ArrayList<BoolExpr[]> allvarPropertyVars = new ArrayList<>();

        ArrayList<String> valSample = this.values.get(0);
        for (int i = 0; i < valSample.size(); i++) {
            String val = valSample.get(i);
//            get dataID from variable name, then label
            Integer demonstrationID = Integer.valueOf(val.split("_")[0].replace("d", ""));
            String dataID = val.split("_")[1];

            String label = null;
            ArrayList<String> properties = new ArrayList<>();
            if (dataID.startsWith("n")) {
                Node node = this.demonstrations.get(demonstrationID).inputGraph.nodes.get(dataID.replace("n", ""));
                label = node.label;
                properties = this.nodeLabel2Properties.get(label);
            } else {
                Edge edge = this.demonstrations.get(demonstrationID).inputGraph.edges.get(dataID.replace("e", ""));
                label = edge.label;
                properties = this.edgeLabel2Properties.get(label);
            }
            if(properties != null){
                BoolExpr[] tmp = new BoolExpr[properties.size()];
                for (int j = 0; j < properties.size(); j++) {
                    String property = properties.get(j);
                    tmp[j] = ctx.mkBoolConst(this.variableName.get(i) + "_" + property);
                }
                allvarPropertyVars.add(tmp);
            }
        }
        this.varPropertyVars = new BoolExpr[allvarPropertyVars.size()][];
        for(int i = 0; i < allvarPropertyVars.size(); i++){
            this.varPropertyVars[i] = allvarPropertyVars.get(i);
        }

        this.pathVars = new BoolExpr[this.values.size()];
        for(int pathID=0; pathID<this.values.size(); pathID++){
            String sampleDemonID = this.values.get(pathID).get(0).split("_")[0].replace("d", "");
            this.pathVars[pathID] = ctx.mkBoolConst("d" + sampleDemonID + "_" + pathID);
        }
    }

    public void genConstraints(){

//      get concrete data ID then check whether in outputNeed; if in, update hashmap; otherwise add banning constraint
        for(int pathID=0; pathID<this.pathVars.length; pathID++){
            for(int varInID=0; varInID<this.varPropertyVars.length; varInID++){
                String variableName = this.varPropertyVars[varInID][0].toString().split("_")[0];
                String dataID = this.values.get(pathID).get(this.variableName.indexOf(variableName));
//                If data point not in output mappings
                if(!this.element2Property.containsKey(dataID)){
                    for(int propertyID=0; propertyID<this.varPropertyVars[varInID].length; propertyID++) {
                        solver.add(ctx.mkNot(ctx.mkAnd(ctx.mkEq(this.pathVars[pathID], ctx.mkBool(true)),
                                ctx.mkEq(this.varPropertyVars[varInID][propertyID], ctx.mkBool(true)))));
                    }
                } else {
                    for(int propertyID=0; propertyID<this.varPropertyVars[varInID].length; propertyID++) {
                        String property = this.varPropertyVars[varInID][propertyID].toString().split("_")[1];
//                        If certain property of data point not in output mappings
                        if(!this.element2Property.get(dataID).contains(property)){
                            solver.add(ctx.mkNot(ctx.mkAnd(ctx.mkEq(this.pathVars[pathID], ctx.mkBool(true)),
                                    ctx.mkEq(this.varPropertyVars[varInID][propertyID], ctx.mkBool(true)))));
                        } else {
//                          Add to element2PathAVar
                            if(!this.element2PathAVar.containsKey(dataID)){
                                this.element2PathAVar.put(dataID, new HashMap<>());
                            }
                            if(!this.element2PathAVar.get(dataID).containsKey(property)){
                                this.element2PathAVar.get(dataID).put(property, new ArrayList<>());
                            }
                            this.element2PathAVar.get(dataID).get(property).add(ctx.mkAnd(ctx.mkEq(this.pathVars[pathID], ctx.mkBool(true)),
                                    ctx.mkEq(this.varPropertyVars[varInID][propertyID], ctx.mkBool(true))));
                            }
                        }
                    }
                }
            }


        //  for each data in keys of element2PathAVar, add must-have condition with "or"
        for(String elementID: this.element2Property.keySet()){
            for(String propertyID: this.element2Property.get(elementID)){
                if(this.element2PathAVar.containsKey(elementID) && this.element2PathAVar.get(elementID).containsKey(propertyID)) {
                    BoolExpr[] options = new BoolExpr[this.element2PathAVar.get(elementID).get(propertyID).size()];
                    for (int k = 0; k < options.length; k++) {
                        options[k] = this.element2PathAVar.get(elementID).get(propertyID).get(k);
                    }
                    solver.add(ctx.mkOr(options));
                } else {
                    canFind = false;
                    break;
                }
            }
            if(!canFind){
                break;
            }
        }

        equalPath();
    }

    public SketchSynthesizer.VarsReturn constraint2Return(){
        ArrayList<Integer> includePaths = new ArrayList<>();
        ArrayList<Integer> excludePaths = new ArrayList<>();

        ArrayList<Property> properties = new ArrayList<>();
// 1. cpId to specify which cps to include
        for(int cpIdx=0; cpIdx<this.pathVars.length; cpIdx++){
            String val = "true";
            try{
                val = solution.getConstInterp(pathVars[cpIdx]).toString();
            } catch(Exception e){
                System.out.println("Random OPTIONS");
            }
            if(val.equals("true")){
                includePaths.add(cpIdx);
            } else {
                excludePaths.add(cpIdx);
            }
        }

        for(int variableID=0; variableID<this.varPropertyVars.length; variableID++) {
            for (int propertyIdx = 0; propertyIdx < this.varPropertyVars[variableID].length; propertyIdx++) {
                BoolExpr expr = this.varPropertyVars[variableID][propertyIdx];
                String val = "true";
                try{
                    val = solution.getConstInterp(expr).toString();
                } catch(Exception e){
                    System.out.println("Random OPTIONS");
                }
                if (val.equals("true")) {
                    String property = this.varPropertyVars[variableID][propertyIdx].toString().split("_")[1];
                    String varName = this.varPropertyVars[variableID][propertyIdx].toString().split("_")[0];
                    if (property.equals("full")) {
                        properties.add(new Property(null, varName));
                    } else {
                        properties.add(new Property(property, varName));
                    }
                }
            }
        }

        return new SketchSynthesizer.VarsReturn(includePaths, excludePaths, properties);
    }

    /*
        If multiple paths have exactly same property values, then they should be equal in pathVars
     */
    public void equalPath(){
        HashMap<ArrayList<LinkedHashMap<String, Object>>, HashSet<Integer>> pathVals = new HashMap<>();
        for(int rowId = 0; rowId < values.size(); rowId++) {
            Integer demonstrationID = Integer.valueOf(values.get(rowId).get(0).split("_")[0].replace("d", ""));
            ArrayList<LinkedHashMap<String, Object>> allValsInRow = dataHelper(values.get(rowId), demonstrations.get(demonstrationID));
            if(!pathVals.containsKey(allValsInRow)){
                pathVals.put(allValsInRow, new HashSet<>());
            }
            pathVals.get(allValsInRow).add(rowId);
        }

        for(HashSet<Integer> samePaths: pathVals.values()){
            if(samePaths.size() > 1){
                BoolExpr[] tmpT = new BoolExpr[samePaths.size()];
                BoolExpr[] tmpF = new BoolExpr[samePaths.size()];
                Integer index = 0;
                for(int pathID: samePaths){
                    tmpT[index] = ctx.mkEq(ctx.mkBool(true), pathVars[pathID]);
                    tmpF[index] = ctx.mkEq(ctx.mkBool(false), pathVars[pathID]);
                    index++;
                }
                solver.add(ctx.mkOr(ctx.mkAnd(tmpT), ctx.mkAnd(tmpF)));
            }
        }
    }

    public void ban(){
        ArrayList<BoolExpr> bans = new ArrayList<>();
        for(int cpIdx=0; cpIdx<pathVars.length; cpIdx++){
            String val = "true";
            try{
                val = solution.getConstInterp(pathVars[cpIdx]).toString();
            } catch(Exception e){
                System.out.println("Random OPTIONS");
            }
            if(val.equals("true")){
                bans.add(ctx.mkEq(ctx.mkBool(true), pathVars[cpIdx]));
            } else {
                bans.add(ctx.mkEq(ctx.mkBool(false), pathVars[cpIdx]));
            }
        }
        for(int variableID=0; variableID<this.varPropertyVars.length; variableID++) {
            for (int propertyIdx = 0; propertyIdx < varPropertyVars[variableID].length; propertyIdx++) {
                    BoolExpr expr = varPropertyVars[variableID][propertyIdx];
                    String val = "true";
                    try{
                        val = solution.getConstInterp(expr).toString();
                    } catch(Exception e){
                        System.out.println("Random OPTIONS");
                    }
                    if (val.equals("true")) {
                        bans.add(ctx.mkEq(ctx.mkBool(true), expr));
                    } else {
                        bans.add(ctx.mkEq(ctx.mkBool(false), expr));
                    }
                }
            }

        BoolExpr[] turnedBans = new BoolExpr[bans.size()];
        int k=0;
        for(BoolExpr ban: bans){
            turnedBans[k] = ban;
            k++;
        }
        solver.add(ctx.mkNot(ctx.mkAnd(turnedBans)));
    }
}
