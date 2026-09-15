package synth.core.filterSyn;

import synth.core.data.dataStructures.Demonstration;
import synth.core.data.dataStructures.InputGraph;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;

public class Helpers {

    public static HashMap<Integer, String> mappingHelper(ArrayList<String> dataIDs, InputGraph graph) {
        HashMap<Integer, String> typeMap = new HashMap<>();
        Integer itemIdx = 0;
        for (String idx : dataIDs) {
            idx = idx.split("_")[1];
            if(idx.startsWith("n")){
                String ID = idx.replace("n", "");
                ArrayList<String> properties = new ArrayList<>(graph.nodes.get(ID).getAttributes().keySet());
                for (String property : properties) {
                    Object val = graph.nodes.get(ID).getAttributes().get(property);
                    if(val instanceof String){
                        typeMap.put(itemIdx, "String");
                    } else if(val instanceof Long){
                        typeMap.put(itemIdx, "Long");
                    } else if(val instanceof Integer){
                        typeMap.put(itemIdx, "Integer");
                    }
                    itemIdx += 1;
                }
            } else if(idx.startsWith("e")) {
                String ID = idx.replace("e", "");
                ArrayList<String> properties = new ArrayList<>(graph.edges.get(ID).getAttributes().keySet());
                for (String property : properties) {
                    Object val = graph.edges.get(ID).getAttributes().get(property);
                    if(val instanceof String){
                        typeMap.put(itemIdx, "String");
                    } else if(val instanceof Long){
                        typeMap.put(itemIdx, "Long");
                    } else if(val instanceof Integer){
                        typeMap.put(itemIdx, "Integer");
                    }
                    itemIdx += 1;
                }
            }

        }
        typeMap.put(itemIdx, "StringSumConstant");
        itemIdx ++;
        typeMap.put(itemIdx, "NumberSum");
        return typeMap;
    }

    /*
    Turn data in each path to a wide row.
     */
    public static ArrayList<LinkedHashMap<String, Object>> dataHelper(ArrayList<String> data, Demonstration demonstration) {
        // [node1Attri, node2Attri, ...] order is the same as variableNames
        ArrayList<LinkedHashMap<String, Object>> row = new ArrayList<>();
        for (String dataID : data) {
            String ID = dataID.split("_")[1];
            if(ID.startsWith("n")){
                ID = ID.replace("n", "");
                row.add(demonstration.inputGraph.nodes.get(ID).getAttributes());
            } else if(ID.startsWith("e")){
                ID = ID.replace("e", "");
                row.add(demonstration.inputGraph.edges.get(ID).getAttributes());
            }
        }
        return row;
    }
}
