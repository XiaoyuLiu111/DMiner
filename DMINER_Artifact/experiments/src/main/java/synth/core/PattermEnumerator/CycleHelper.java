package synth.core.PattermEnumerator;

import synth.core.data.dataStructures.Edge;
import synth.core.data.dataStructures.InputGraph;

import java.util.*;

import static synth.core.data.dataStructures.InputGraph.findConnected;

public class CycleHelper {
    public HashMap<Integer, HashMap<String, ArrayList<String>>> neighborMap = new HashMap<>();
    public HashSet<HashSet<String>> cycles = new HashSet<>(); // demonstrationID -> {[IDs on cycle]}
    public InputGraph graph;

    public CycleHelper(InputGraph graph) {
        this.graph = graph;
    }

    public HashMap<String, ArrayList<String>> findNeighbours(){
        HashMap<String, ArrayList<String>> neighbours = new HashMap<>();
        for(Edge edge: graph.edges.values()){
            String start = edge.getStart();
            String end = edge.getEnd();

            if(!neighbours.containsKey(start)){
                neighbours.put(start, new ArrayList<>());
            }
            if(!neighbours.containsKey(end)){
                neighbours.put(end, new ArrayList<>());
            }
            neighbours.get(start).add(end);
            neighbours.get(end).add(start);
        }
        return neighbours;
    }

    public HashSet<HashSet<String>> findCycles(){
        HashMap<String, ArrayList<String>> neighbours = findNeighbours();
        for (String node : neighbours.keySet()) { // graph is a connected graph
            findCyclesHelper(neighbours, node, new ArrayList<>(), new HashSet<>());
            break;
        }
        return cycles;
    }

    public void findCyclesHelper(HashMap<String, ArrayList<String>> neighbours, String current, List<String> path, Set<String> visited) {
        path.add(current);
        visited.add(current);

        if(neighbours.containsKey(current)){
            for (String neighbor : neighbours.get(current)) {
                if (path.contains(neighbor)) {
                    int idx = path.indexOf(neighbor);
                    HashSet<String> cycle = new HashSet<>(path.subList(idx, path.size()));
                    cycle.add(neighbor);  // close the cycle
                    cycles.add(cycle); // avoid duplicates
                } else if (!visited.contains(neighbor)) {
                    findCyclesHelper(neighbours, neighbor, new ArrayList<>(path), new HashSet<>(visited));
                }
            }
        }
    }
}
