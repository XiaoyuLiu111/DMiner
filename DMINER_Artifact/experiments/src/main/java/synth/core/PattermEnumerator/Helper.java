package synth.core.PattermEnumerator;

import synth.ast.pred.expr.Property;
import synth.core.data.dataStructures.*;

import java.util.*;

import static synth.core.QuerySketchSyn.PreprocessHelper.flattenExpressionHelper;

public class Helper {
    public ArrayList<Demonstration> demonstrations;
    public HashMap<Integer, HashMap<String, HashSet<String>>> outputNeed = new HashMap<>(); // demonstrationID -> node/edge -> dataIDs
    public HashMap<Integer, HashMap<String, HashSet<String>>> outputLabels = new HashMap<>(); // demonstrationID -> node/edge -> label
    public HashMap<String, HashSet<String>> element2Property = new HashMap<>(); // dmonID+n/e+ID -> Properties
    public HashMap<String, HashSet<String>> nodeLabel2Properties = new HashMap<>(); // label -> [properties]
    public HashMap<String, HashSet<String>> edgeLabel2Properties = new HashMap<>(); // label -> [properties]
    public HashSet<String> allNeedIDs = new HashSet<>();
    public HashMap<String, Expression> expressions = new HashMap<>(); // valID -> Expression
    public HashMap<String, Property> nonExpressions = new HashMap<>(); // valID -> Property
    public HashMap<String, HashSet<ArrayList<Integer>>> inputItemsMap = new HashMap<>();
    public Integer atomCnt = 0;
    public ArrayList<Integer> demoIDs = new ArrayList<>();

//     list all potential groups of IDs of input nodes or edges
//    public HashSet<HashMap<String, Integer>> needIDsPotential = new HashSet<>(); // {{IDs cnt on subgraph}, }
//    public HashSet<ArrayList<HashSet<String>>> allNeedIDsCor = new HashSet<>(); // {[{IDs of nodes/edges for one value}, {}, ...]}
    public Helper(ArrayList<Demonstration> demonstrations, ArrayList<Integer> demoIDs) {
        this.demonstrations = demonstrations;
        this.demoIDs = demoIDs;
    }
    public void getOutputLabels(){
        if(this.outputNeed.isEmpty()){
            getOutputNeeds();
        }
        for(Integer demonstrationID: this.outputNeed.keySet()){
            HashSet<String> nodeLabels = new HashSet<>();
            HashSet<String> edgeLabels = new HashSet<>();
            for(String nodeID: this.outputNeed.get(demonstrationID).get("node")){
                nodeLabels.add(this.demonstrations.get(demonstrationID).inputGraph.nodes.get(nodeID).label);
            }
            for(String edgeID: this.outputNeed.get(demonstrationID).get("edge")){
                edgeLabels.add(this.demonstrations.get(demonstrationID).inputGraph.edges.get(edgeID).label);
            }

            HashMap<String, HashSet<String>> map = new HashMap<>();
            map.put("node", nodeLabels);
            map.put("edge", edgeLabels);

            this.outputLabels.put(demonstrationID, map);
        }
    }

    public void getOutputNeeds(){
        if(this.outputNeed.isEmpty()) {
            Demonstration demonstration = null;
            for (int i: demoIDs) {
                if(i >= demonstrations.size()){
                    demonstration = demonstrations.get(0);
                } else {
                    demonstration = demonstrations.get(i);
                }
                HashSet<String> allDataIDs = new HashSet<>();

                if(demonstration.mapping1 != null){
                    HashMap<String, ArrayList<String>> mapping1 = demonstration.mapping1;
                    for(ArrayList<String> itemIDs: mapping1.values()){
                        allDataIDs.addAll(itemIDs);
                        for(String ID: itemIDs){
                            allNeedIDs.add("d"+i+"_"+ID);
                        }
                    }
                }
                ArrayList<Computation> mapping3 = demonstration.mapping3;
                for (Computation computationObject : mapping3) {
                    HashSet<String> compIDs = computationObjectHelper(computationObject);
                    allDataIDs.addAll(compIDs);
                    allNeedIDs.addAll(compIDs);
                }

                HashSet<String> nodeIDs = new HashSet<>();
                HashSet<String> edgeIDs = new HashSet<>();
                for (String dataID : allDataIDs) {
                    if(dataID.startsWith("d")){
                        dataID = dataID.replace("d"+String.valueOf(i)+"_", "");
                    }
                    if (dataID.startsWith("n")) {
                        nodeIDs.add(dataID.replace("n", ""));
                    }
                    if (dataID.startsWith("e")) {
                        edgeIDs.add(dataID.replace("e", ""));
                    }
                }

                HashMap<String, HashSet<String>> dataIDMap = new HashMap<>();
                dataIDMap.put("node", nodeIDs);
                dataIDMap.put("edge", edgeIDs);
                this.outputNeed.put(i, dataIDMap);
            }
        }

    }

    public HashSet<String> computationObjectHelper(Computation computationObject){
        HashSet<String> dataIDs = new HashSet<>(computationObject.dataID);
        if(computationObject.lhs!=null){
            dataIDs.addAll(computationObjectHelper(computationObject.lhs));
        }
        if(computationObject.rhs!=null){
            dataIDs.addAll(computationObjectHelper(computationObject.rhs));
        }

        return dataIDs;
    }

    public void computationObjectHelperWithProperty(Computation computationObject, Integer demonstrationID) {
        if(computationObject.property != null){
            String property = computationObject.property;
            for (int i = 0; i < computationObject.dataID.size(); i++) {
                String dataID = computationObject.dataID.get(i);

                if (!this.element2Property.containsKey(dataID)) {
                    this.element2Property.put(dataID, new HashSet<>());
                }
                this.element2Property.get(dataID).add(property);
            }
        }

        if(computationObject.rhs!=null){
            computationObjectHelperWithProperty(computationObject.rhs, demonstrationID);
        }
        if(computationObject.lhs!=null){
            computationObjectHelperWithProperty(computationObject.lhs, demonstrationID);
        }
    }

    /*
        From mappings in all demonstrations, get requirements
    */
    public void graphEle2Property(){
        for(int i: demoIDs){
            Demonstration demonstration = null;
            if(i >= demonstrations.size()){
                demonstration = demonstrations.get(0);
            } else {
                demonstration = demonstrations.get(i);
            }
            HashMap<String, ArrayList<String>> mapping1 = demonstration.mapping1;
            HashMap<String, ArrayList<String>> mapping2 = demonstration.mapping2;

            for(String elementID: mapping2.keySet()){
                HashSet<String> property = new HashSet<>(mapping2.get(elementID));
                ArrayList<String> inputDataIDs = mapping1.get(elementID);
                for(String inputDataID: inputDataIDs){
                    if(!this.element2Property.containsKey("d"+i+"_"+inputDataID)){
                        this.element2Property.put("d"+i+"_"+inputDataID, new HashSet<>());
                    }
                    this.element2Property.get("d"+i+"_"+inputDataID).addAll(property);
                }
            }

            for(Computation computation: demonstration.mapping3){
                computationObjectHelperWithProperty(computation, i);
            }
        }
    }

    public void label2Property(){
        if(this.element2Property.isEmpty()){
            graphEle2Property();
        }
        for(String ID: this.element2Property.keySet()){
            int demonstrationID = Integer.parseInt(ID.split("_")[0].replace("d", ""));
            String dataID = ID.split("_")[1];
            String label = null;

            if(dataID.startsWith("n")){
                String nodeID = dataID.replace("n", "");
                if(demonstrationID >= demonstrations.size()){
                    label = demonstrations.get(0).inputGraph.nodes.get(nodeID).label;
                } else {
                    label = demonstrations.get(demonstrationID).inputGraph.nodes.get(nodeID).label;
                }
                if(!this.nodeLabel2Properties.containsKey(label)){
                    this.nodeLabel2Properties.put(label, new HashSet<>());
                }
                this.nodeLabel2Properties.get(label).addAll(this.element2Property.get(ID));
            } else {
                String edgeID = dataID.replace("e", "");
                if(demonstrationID >= demonstrations.size()){
                    label = demonstrations.get(0).inputGraph.edges.get(edgeID).label;
                } else {
                    label = demonstrations.get(demonstrationID).inputGraph.edges.get(edgeID).label;
                }

                if(!this.edgeLabel2Properties.containsKey(label)){
                    this.edgeLabel2Properties.put(label, new HashSet<>());
                }
                this.edgeLabel2Properties.get(label).addAll(this.element2Property.get(ID));
            }
        }
    }

    public void getAllExpNonExp(){
        for (int demonstrationID: demoIDs) {
            Demonstration demonstration = null;
            if(demonstrationID >= demonstrations.size()){
                demonstration = demonstrations.get(0);
            } else {
                demonstration = demonstrations.get(demonstrationID);
            }
            HashSet<String> valIDs = new HashSet<>(demonstration.mapping1.keySet());
            for (String valID : valIDs) {
                ArrayList<String> inputIDs = demonstration.mapping1.get(valID);
                String property = demonstration.mapping2.get(valID).get(0);
                HashMap<String, Integer> dataCnt = new HashMap<>();
                for(String inputID: inputIDs){
                    String inputIDP = "d" + String.valueOf(demonstrationID) + "_" + inputID;
                    if(!dataCnt.containsKey(inputIDP)){
                        dataCnt.put(inputIDP, 0);
                    }
                    dataCnt.put(inputIDP, dataCnt.get(inputIDP) + 1);
                }

                //   Add property to nonExpressions
                Property nonExpression = new Property(property, null);
                nonExpression.data = dataCnt;
                nonExpression.operator = "empty";
                nonExpressions.put(valID, nonExpression);
            }

            ArrayList<Expression> expressionsInDemonstration = new ArrayList<>();
            for(int computationObjectID=0; computationObjectID<demonstration.mapping3.size(); computationObjectID++){
                String valID = "d" + String.valueOf(demonstrationID) + "_exp" + String.valueOf(computationObjectID);
                Expression flattened = flattenExpressionHelper(demonstration.mapping3.get(computationObjectID), demonstrationID);
                expressions.put(valID, flattened);
            }
        }
    }

    public void prepSubgraphTargets(HashMap<String, Expression> expressions, HashMap<String, Property> nonExpressions){
        // TODO: Get expressions and nonExpressions in dataPrep
        // Put all rows from each demonstration to here as combined
        ArrayList<ArrayList<String>> corByRows = new ArrayList<>();
        for(Demonstration demonstration: demonstrations){
            corByRows.addAll(demonstration.correspondence);
        }
        for(String valID: corByRows.get(0)){
            if(valID.contains("exp")){
                Expression exp = expressions.get(valID);
                for(Property atom: exp.atoms){
                    atomCnt++;
                }
            } else {
                atomCnt++;
            }
        }
        for(int rowID=0; rowID<corByRows.size(); rowID++){
            Integer atomID = 0;
            for(String valID: corByRows.get(rowID)){
                if(valID.contains("exp")){
                    Expression exp = expressions.get(valID);
                    for(Property atom: exp.atoms){
                        HashMap<String, Integer> dataCnt = atom.data;
                        for(String dataID: dataCnt.keySet()){
                            if(!inputItemsMap.containsKey(dataID)){
                                inputItemsMap.put(dataID, new HashSet<>());
                            }
                            inputItemsMap.get(dataID).add(new ArrayList<>(Arrays.asList(rowID, atomID)));
                        }
                        atomID++;
                    }
                } else {
                    HashMap<String, Integer> dataCnt = nonExpressions.get(valID).data;
                    for(String dataID: dataCnt.keySet()){
                        if(!inputItemsMap.containsKey(dataID)){
                            inputItemsMap.put(dataID, new HashSet<>());
                        }
                        inputItemsMap.get(dataID).add(new ArrayList<>(Arrays.asList(rowID, atomID)));
                    }
                    atomID++;
                }
            }
        }
    }
}
