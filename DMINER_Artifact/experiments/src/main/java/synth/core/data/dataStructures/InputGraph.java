package synth.core.data.dataStructures;

import java.util.*;

/*
    Graph data structure for all graphs, including input graph, and cleaned graphs;
    For cleaned graphs, need to call findConnected to find connected graphs;
 */
public class InputGraph {
    public InputGraph(HashMap<String,Node> nodes, HashMap<String, Edge> edges) {
        this.nodes = nodes;
        this.edges = edges;
    }

    public final HashMap<String, Node> nodes;
    public final HashMap<String, Edge> edges;

    public static class NEN{
        public NEN(String startLabel, String endLabel, String edgeLabel) {
            this.startLabel = startLabel;
            this.endLabel = endLabel;
            this.edgeLabel = edgeLabel;
        }

        public String startLabel;
        public String endLabel;
        public String edgeLabel;

        public String ctoString(){
            return startLabel + ", " + edgeLabel + "," + endLabel;
        }
    }
    public HashMap<String, ArrayList<String>> NENMap = new HashMap<>(); //
    public HashMap<String, ArrayList<String>> NMap = new HashMap<>(); //
    public HashMap<String, ArrayList<String>> EMap = new HashMap<>(); //
    public HashMap<String, ArrayList<String>> neighbors = new HashMap<>();

    public Integer getSize(){
        return this.edges.size();
    }

    public static HashMap<String, ArrayList<String>> getNeighbors(InputGraph inputGraph){
        HashMap<String, ArrayList<String>> neighbors = new HashMap<>();
        for(String edgeID: inputGraph.edges.keySet()){
            String startID = inputGraph.edges.get(edgeID).getStart();
            String endID = inputGraph.edges.get(edgeID).getEnd();

            if(!neighbors.containsKey(startID)){
                neighbors.put(startID, new ArrayList<>());
            }
            if(!neighbors.containsKey(endID)){
                neighbors.put(endID, new ArrayList<>());
            }
            neighbors.get(startID).add(edgeID);
            neighbors.get(endID).add(edgeID);
        }
        return neighbors;
    }

    /*
        Return graphs, each graph is a connected graph
     */
    public static ArrayList<InputGraph> findConnected(InputGraph inputGraph){
//        return a list of graphs, each graph is connected itself
        ArrayList<InputGraph> connectedGraphs = new ArrayList<>();
        HashMap<String, ArrayList<String>> neighbors = getNeighbors(inputGraph);
//        bfs to find all connected nodes and edges
        ArrayList<String> nodeIDs = new ArrayList<>(inputGraph.nodes.keySet());

        while(!nodeIDs.isEmpty()){
            HelperReturn oneRound = helper(inputGraph, neighbors, nodeIDs);
            nodeIDs = oneRound.nodeIDs;
            connectedGraphs.add(oneRound.graph);
        }
//        connectedGraphs.sort(Comparator.comparingInt(InputGraph::getSize));
        return connectedGraphs;
    }

    public static class HelperReturn{
        public InputGraph graph;
        public ArrayList<String> nodeIDs;

        public HelperReturn(InputGraph graph, ArrayList<String> nodeIDs) {
            this.graph = graph;
            this.nodeIDs = nodeIDs;
        }
    }

    /*
        Helper function for findConnected
     */
    public static HelperReturn helper(InputGraph inputGraph, HashMap<String, ArrayList<String>> neighbors,
                                      ArrayList<String> nodeIDs){
        HashSet<String> visitedNodes = new HashSet<>();
        HashMap<String, Node> nodes = new HashMap<>();
        HashMap<String, Edge> edges = new HashMap<>();

        Queue<String> nodeQueue = new LinkedList<>();
        String firstNode = nodeIDs.get(0);
        nodeQueue.add(firstNode);
        nodes.put(firstNode, inputGraph.nodes.get(firstNode));
        visitedNodes.add(firstNode);
        nodeIDs.remove(0);

        while(!nodeQueue.isEmpty()){
            Integer currLayerSize = nodeQueue.size();
            for(int i=0; i<currLayerSize; i++){
                String currNode = nodeQueue.poll();
                if(!neighbors.containsKey(currNode)){
                    continue;
                }
                for(String edgeID: neighbors.get(currNode)){
                    String neighborNodeID = inputGraph.edges.get(edgeID).getOtherSide(currNode);

                    edges.put(edgeID, inputGraph.edges.get(edgeID));
                    nodes.put(neighborNodeID, inputGraph.nodes.get(neighborNodeID));

                    if(!visitedNodes.contains(neighborNodeID)){
                        nodeQueue.add(neighborNodeID);
                        visitedNodes.add(neighborNodeID);
                        nodeIDs.remove(neighborNodeID); // left nodes
                    }
                }
            }
        }

        return new HelperReturn(new InputGraph(nodes, edges), nodeIDs);
    }

    /*
        Group nodes and NEN with labels
     */
    public void hash(){
        for(String nodeID: this.nodes.keySet()){
            String nodeLabel = this.nodes.get(nodeID).label;
            if(!this.NMap.containsKey(nodeLabel)){
                this.NMap.put(nodeLabel, new ArrayList<>());
            }
            this.NMap.get(nodeLabel).add(nodeID);
        }

        for(String edgeID: this.edges.keySet()){
            Edge edge = this.edges.get(edgeID);
            NEN NENObject = new NEN(this.nodes.get(edge.getStart()).label, edge.label, this.nodes.get(edge.getEnd()).label);
            String NENString = NENObject.ctoString();
            if(!this.NENMap.containsKey(NENString)){
                this.NENMap.put(NENString, new ArrayList<>());
            }
            this.NENMap.get(NENString).add(edgeID);
        }
    }

    public InputGraph copy(){
        HashMap<String, Edge> cEdges = new HashMap<>();
        HashMap<String, Node> cNodes = new HashMap<>();
        HashMap<String, ArrayList<String>> cNeighbors = new HashMap<>();
        for(String edgeID: this.edges.keySet()){
            cEdges.put(edgeID, this.edges.get(edgeID).copy());
        }
        for(String nodeID: this.nodes.keySet()){
            cNodes.put(nodeID, this.nodes.get(nodeID).copy(nodeID));
        }
        if(this.neighbors.isEmpty()){
            this.neighbors = getNeighbors(this);
        }
        for(String neighborKey: this.neighbors.keySet()){
            cNeighbors.put(neighborKey, new ArrayList<>());
            for(String neighborID: this.neighbors.get(neighborKey)){
                cNeighbors.get(neighborKey).add(neighborID);
            }
        }
        InputGraph copiedGraph = new InputGraph(cNodes, cEdges);
        copiedGraph.neighbors = cNeighbors;
        return copiedGraph;
    }

    public static HashSet<String> serialize(InputGraph inputGraph){
        HashSet<String> serializedGraph = new HashSet<>();
        for(String nodeID: inputGraph.nodes.keySet()){
            serializedGraph.add("n_" + nodeID);
        }
        for(String edgeID: inputGraph.edges.keySet()){
            serializedGraph.add("e_" + edgeID);
        }
        return serializedGraph;
    }

    public Map<Integer, ArrayList<Integer>> toNeighborNodeDict(){
        // HashMap where keys are start nodeID, values are list of end nodeID

        Map<Integer, ArrayList<Integer>> neighborNodes = new HashMap<>();
        for(String edgeID: this.edges.keySet()){
            String startID = this.edges.get(edgeID).getStart().replace("n", "");
            String endID = this.edges.get(edgeID).getEnd().replace("n", "");
            Integer startIDInt = Integer.valueOf(startID);
            Integer endIDInt = Integer.valueOf(endID);
            if(!neighborNodes.containsKey(startIDInt)){
                neighborNodes.put(startIDInt, new ArrayList<>());
            }
            neighborNodes.get(startIDInt).add(endIDInt);
            if(!neighborNodes.containsKey(endIDInt)){
                neighborNodes.put(endIDInt, new ArrayList<>());
            }
            neighborNodes.get(endIDInt).add(startIDInt);
        }
        return neighborNodes;
    }

    public HashMap<Integer, HashMap<Integer, Integer>> nodes2EdgeDict(){
        // HashMap where keys are start nodeID, values are list of end nodeID

        HashMap<Integer, HashMap<Integer, Integer>> nodes2Edges = new HashMap<>();
        for(String edgeID: this.edges.keySet()){
            String startID = this.edges.get(edgeID).getStart().replace("n", "");
            String endID = this.edges.get(edgeID).getEnd().replace("e", "");
            Integer startIDInt = Integer.valueOf(startID);
            Integer endIDInt = Integer.valueOf(endID);
            if(!nodes2Edges.containsKey(startIDInt)){
                nodes2Edges.put(startIDInt, new HashMap<>());
            }
            nodes2Edges.get(startIDInt).put(endIDInt, Integer.valueOf(edgeID.replace("e", "")));
            if(!nodes2Edges.containsKey(endIDInt)){
                nodes2Edges.put(endIDInt, new HashMap<>());
            }
            nodes2Edges.get(endIDInt).put(startIDInt, Integer.valueOf(edgeID.replace("e", "")));

        }
        return nodes2Edges;
    }
}
