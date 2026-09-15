package synth.core.PattermEnumerator;

import synth.core.data.dataStructures.Demonstration;
import synth.core.data.dataStructures.InputGraph;

import java.util.*;

import static synth.core.data.dataStructures.InputGraph.findConnected;

public class Cleaner {
    public static class cleanObject {
        public HashMap<Integer, ArrayList<InputGraph>> tmp;

        public cleanObject(HashMap<Integer, ArrayList<InputGraph>> tmp, PriorityQueue<List<Object>> inputGraphs) {
            this.tmp = tmp;
            this.inputGraphs = inputGraphs;
        }

        public PriorityQueue<List<Object>> inputGraphs;
    }

    public static cleanObject clean(ArrayList<Demonstration> demonstrations) {
        PriorityQueue<List<Object>> inputGraphs = new PriorityQueue<>(
                (a, b) -> Integer.compare(((InputGraph) b.get(0)).getSize(), ((InputGraph) a.get(0)).getSize())
        );
        Integer i = 0;
        for(Demonstration demonstration : demonstrations) {
            InputGraph graph = demonstration.inputGraph;
            inputGraphs.add(new ArrayList<Object>(Arrays.asList(graph, i)));
            i++;
        }
        ArrayList<InputGraph> cleaned = helper(demonstrations);
        HashMap<Integer, ArrayList<InputGraph>> tmp = new HashMap<>();
        PriorityQueue<List<Object>> orderedGraphs =
        new PriorityQueue<>(inputGraphs);

        while (!orderedGraphs.isEmpty()) {
            List<Object> tuple = orderedGraphs.poll();

            Integer demonstrationID = (Integer) tuple.get(1);
            InputGraph cleanedGraph = cleaned.get(demonstrationID);
            tmp.put(demonstrationID, findConnected(cleanedGraph));
        }
        return new cleanObject(tmp, inputGraphs);
    }
//    access point of graphs cleaning
    public static ArrayList<InputGraph> helper(ArrayList<Demonstration> demonstrations){
        InputGraph sampleGraph = demonstrations.get(0).inputGraph;
        sampleGraph.hash();
        HashSet<String> nodeLabels = new HashSet<>(sampleGraph.NMap.keySet());
        HashSet<String> NENLabels = new HashSet<>(sampleGraph.NENMap.keySet());

        for(int i=1; i<demonstrations.size(); i++){
            demonstrations.get(i).inputGraph.hash();
        }
        for(String nodeType: sampleGraph.NMap.keySet()){
            for(int i=1; i<demonstrations.size(); i++){
                if(!demonstrations.get(i).inputGraph.NMap.containsKey(nodeType)){
                    nodeLabels.remove(nodeType);
                }
            }
        }
        for(String NENType: sampleGraph.NENMap.keySet()){
            for(int i=1; i<demonstrations.size(); i++){
                if(!demonstrations.get(i).inputGraph.NENMap.containsKey(NENType)){
                    NENLabels.remove(NENType);
                }
            }
        }

//        clean up
        ArrayList<InputGraph> cleaned = new ArrayList<>();
        for(int demonstrationID = 0; demonstrationID < demonstrations.size(); demonstrationID++){
            cleaned.add(helper(demonstrations.get(demonstrationID).inputGraph, NENLabels, nodeLabels));
        }
        return cleaned;
    }

    /*
        Helper function to clean not common edges and nodes
     */
    public static InputGraph helper(InputGraph graph, HashSet<String> NENLabels, HashSet<String> nodeLabels){
        for(String NENLabel: graph.NENMap.keySet()){
            if(!NENLabels.contains(NENLabel)){
                for(String edgeID: graph.NENMap.get(NENLabel)){
                    graph.edges.remove(edgeID);
                }
            }
        }
        for(String nodeLabel: graph.NMap.keySet()){
            if(!nodeLabels.contains(nodeLabel)){
                for(String nodeID: graph.NMap.get(nodeLabel)){
                    graph.nodes.remove(nodeID);
                }
            }
        }
        return graph;
    }
}
