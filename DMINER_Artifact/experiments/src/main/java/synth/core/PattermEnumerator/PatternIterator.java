package synth.core.PattermEnumerator;

import synth.core.data.dataStructures.Edge;
import synth.core.data.dataStructures.InputGraph;
import synth.core.data.dataStructures.Node;

import java.util.*;

import static synth.core.PattermEnumerator.PatternIterator.checkOutputCoverage;
import static synth.core.data.dataStructures.InputGraph.findConnected;
import static synth.core.data.dataStructures.InputGraph.serialize;

public class PatternIterator<Pattern> implements Iterable<Pattern> {
    public ArrayList<InputGraph> graphs;
    public ArrayList<Integer> demonstrationIDs;
    public InputGraph mGraph;
    public ArrayList<InputGraph> allSubGraphs = new ArrayList<>();
    public ArrayList<HashSet<String>> visitedNodeIDs = new ArrayList<>();
    public ArrayList<HashSet<String>> visitedEdgeIDs = new ArrayList<>();
    public HashSet<String> targetNodeLabels;
    public HashSet<String> targetEdgeLabels;
    public Integer currIdx = 0;
    public Integer nextCorIdx = 0;
    public LinkedList<InputGraph> nextRound = new LinkedList<>();
    public HashMap<Integer, HashMap<String, HashSet<String>>> outputNeed;
    public Boolean minSynAblation;
    public Boolean dataDrivenAblation;
    public Boolean isomorphismAblation;
    public Boolean start;
    public Integer currDemonstrationID;
    public Integer patternCnt;
    public LinkedHashMap<Integer, Integer> patternCntDict = new LinkedHashMap<>();
    public HashMap<String, HashSet<ArrayList<Integer>>> inputItemsMap;
    public Integer atomCnt;
    public ArrayList<synth.core.PattermEnumerator.Pattern> patterns;
    public ArrayList<HashSet<String>> visited = new ArrayList<>();
    public ArrayList<InputGraph> backUpGraphs = new ArrayList<>();

    public PatternIterator(ArrayList<InputGraph> graphs, ArrayList<Integer> demonstrationIDs, HashSet<String> targetNodeLabels,
                           HashSet<String> targetEdgeLabels, HashMap<Integer, HashMap<String, HashSet<String>>> outputNeed,
                           Boolean minSynAblation, Boolean dataDrivenAblation, Boolean isomorphismAblation,
                           HashMap<String, HashSet<ArrayList<Integer>>> inputItemsMap, Integer atomCnt){
        this.graphs = graphs;
        this.demonstrationIDs = demonstrationIDs;
        this.targetNodeLabels = targetNodeLabels;
        this.targetEdgeLabels = targetEdgeLabels;
        this.outputNeed = outputNeed;
        this.minSynAblation = minSynAblation;
        this.dataDrivenAblation = dataDrivenAblation;
        this.isomorphismAblation = isomorphismAblation;
        this.start = false;
        this.patternCnt = 0;
        this.inputItemsMap = inputItemsMap;
        this.atomCnt = atomCnt;
    }

    @Override
    public Iterator iterator() {
        Iterator<Pattern> it = new Iterator<>() {
            @Override
            public boolean hasNext() {
                if(!start){
                    nextRound.add(graphs.get(0));
                    currDemonstrationID = demonstrationIDs.get(0);
                    mGraph = graphs.get(0);
                    graphs.remove(0);
                    demonstrationIDs.remove(0);
                    start = true;
                }
                if(!nextRound.isEmpty()){
                    return true;
                } else {
                    if(graphs.isEmpty()){
                        return false;
                    }
                    else {
                        nextRound.add(graphs.get(0));
                        currDemonstrationID = demonstrationIDs.get(0);
                        mGraph = graphs.get(0);
                        graphs.remove(0);
                        demonstrationIDs.remove(0);
                        // TODO: Empty the visited list
                        visited = new ArrayList<>();


                        if(!isomorphismAblation){
                            nextCorIdx = currIdx;
                            Integer nextRoundSize = nextRound.size();
                            while(!graphs.isEmpty()){
                                if(nextCorIdx == nextRoundSize){
                                    nextRound.add(graphs.get(0));
                                    currDemonstrationID = demonstrationIDs.get(0);
                                    mGraph = graphs.get(0);
                                    graphs.remove(0);
                                    demonstrationIDs.remove(0);
                                    nextCorIdx = 0;
                                }
                                nextRoundSize = nextRound.size();
                                while(nextCorIdx < nextRoundSize){
                                    if(checkIsomorphism(nextRound.get(nextCorIdx))){
                                        nextCorIdx ++;
                                        nextRound.poll();
                                    } else {
                                        return true;
                                    }
                                }
                                if(graphs.isEmpty()){
                                    return false;
                                }
                            }
                        }
                        return true;
                    }
                }
            }

            @Override
            public Pattern next() {
                currIdx = nextCorIdx;
                InputGraph newGraph = getSubGraphs();
                currIdx = 0;

                patternCnt++;
                patternCntDict.put(patternCnt, 0);
                Graph2Pattern patternGetter = new Graph2Pattern();
                ArrayList<synth.core.PattermEnumerator.Pattern> pat = patternGetter.getPattern(newGraph);
                if(pat == null){
                    return null;
                }
                patterns = pat;
                if(patternGetter.backUpList.size() > 0){
                    graphs.addAll(patternGetter.backUpList);
                }
                return (Pattern) patterns.get(0);
            }
        };
        return it;
    }

    public HashMap<String, HashSet<String>> getNode2Edge(InputGraph currGraph){
        HashMap<String, HashSet<String>> node2Edge = new HashMap<>();
        for(String edgeID: currGraph.edges.keySet()){
            String start = currGraph.edges.get(edgeID).getStart();
            String end = currGraph.edges.get(edgeID).getEnd();
            if(!node2Edge.containsKey(start)){
                node2Edge.put(start, new HashSet<>());
            }
            if(!node2Edge.containsKey(end)){
                node2Edge.put(end, new HashSet<>());
            }
            node2Edge.get(start).add(edgeID);
            node2Edge.get(end).add(edgeID);
        }
        return node2Edge;
    }

    public HashMap<Integer, ArrayList<String>> getDegreeMap(InputGraph currGraph){
        HashMap<Integer, ArrayList<String>> degreeMap = new HashMap<>();
        HashMap<String, Integer> degreeMapReverse = new HashMap<>();

        for(String edgeID: currGraph.edges.keySet()){
            String start = currGraph.edges.get(edgeID).getStart();
            String end = currGraph.edges.get(edgeID).getEnd();
            if(!degreeMapReverse.containsKey(start)){
                degreeMapReverse.put(start, 0);
            }
            degreeMapReverse.put(start, degreeMapReverse.get(start) + 1);
            if(!degreeMapReverse.containsKey(end)){
                degreeMapReverse.put(end, 0);
            }
            degreeMapReverse.put(end, degreeMapReverse.get(end) + 1);
        }

        for(String nodeID: currGraph.nodes.keySet()){
            Integer degree = 0;
            if(degreeMapReverse.containsKey(nodeID)){
                degree = degreeMapReverse.get(nodeID);
            }
            if(!degreeMap.containsKey(degree)){
                degreeMap.put(degree, new ArrayList<>());
            }
            degreeMap.get(degree).add(nodeID);
        }
        return degreeMap;
    }

    public InputGraph getSubGraphs(){
        this.nextRound.subList(currIdx, this.nextRound.size());
        InputGraph currGraph = this.nextRound.poll();

        for (String edgeID : currGraph.edges.keySet()) {
            ArrayList<InputGraph> nextGraphs = removerHelper(currGraph, edgeID);
            ArrayList<InputGraph> toEnumerate = new ArrayList<>();
            for (InputGraph nextGraph : nextGraphs) {
                HashSet<String> ser = serialize(nextGraph);
                if(!visited.contains(ser)){
                    toEnumerate.add(nextGraph);
                    visited.add(ser);
                }
            }
            for (InputGraph nextGraph : toEnumerate) {
                if(isomorphismAblation){
                    if(!dataDrivenAblation){
                        if(checkOutputCoverage(nextGraph, inputItemsMap, atomCnt, currDemonstrationID)){
                            visitedEdgeIDs.add(new HashSet<>(nextGraph.edges.keySet()));
                            visitedNodeIDs.add(new HashSet<>(nextGraph.nodes.keySet()));

                            this.nextRound.add(nextGraph);
                        }
                    } else {
                        visitedEdgeIDs.add(new HashSet<>(nextGraph.edges.keySet()));
                        visitedNodeIDs.add(new HashSet<>(nextGraph.nodes.keySet()));

                        this.nextRound.add(nextGraph);
                    }
                } else {
                    if(!dataDrivenAblation) {
                        if(checkOutputCoverage(nextGraph, inputItemsMap, atomCnt, currDemonstrationID)){
                            visitedEdgeIDs.add(new HashSet<>(nextGraph.edges.keySet()));
                            visitedNodeIDs.add(new HashSet<>(nextGraph.nodes.keySet()));

                            this.nextRound.add(nextGraph);
                        }
                    } else {
                        if (!checkVisited(nextGraph)){
                            if (!checkIsomorphism(nextGraph)) {
                                visitedEdgeIDs.add(new HashSet<>(nextGraph.edges.keySet()));
                                visitedNodeIDs.add(new HashSet<>(nextGraph.nodes.keySet()));

                                this.nextRound.add(nextGraph);
                            }
                        }
                    }
                }
            }
        }

        return currGraph.copy();
    }

    public ArrayList<InputGraph> removerHelper(InputGraph currGraph, String edgeID){
//        remove edge and decrease related degree
        InputGraph nextGraph = currGraph.copy();
        nextGraph.edges.remove(edgeID);

        ArrayList<InputGraph> nextGraphs = findConnected(nextGraph);
        return nextGraphs;
    }


    public Boolean checkVisited(InputGraph currGraph){
        Boolean nodesVisited = false;
        Boolean edgesVisited = false;

        for(HashSet<String> visitedEdgeSet: this.visitedEdgeIDs){
            if(visitedEdgeSet.equals(currGraph.edges.keySet())){
                nodesVisited = true;
            }
        }
        for(HashSet<String> visitedNodeSet: this.visitedNodeIDs){
            if(visitedNodeSet.equals(currGraph.nodes.keySet())){
                edgesVisited = true;
            }
        }
        if(nodesVisited && edgesVisited){
            return true;
        }
        return false;
    }

    public static Boolean checkOutputCoverage(InputGraph currGraph, HashMap<String, HashSet<ArrayList<Integer>>> inputItemsMap,
                                              Integer atomCnt, Integer demonstrationID){
        HashMap<Integer, HashSet<Integer>> outputCover = new HashMap<>();
        for(Node node: currGraph.nodes.values()){
            String ID = "d" + String.valueOf(demonstrationID) + "_n" + node.getId();
            if(inputItemsMap.containsKey(ID)){
                for(ArrayList<Integer> loc: inputItemsMap.get(ID)){
                    Integer rowID = loc.get(0);
                    Integer atomID = loc.get(1);
                    if(!outputCover.containsKey(rowID)){
                        outputCover.put(rowID, new HashSet<>());
                    }
                    outputCover.get(rowID).add(atomID);
                }
            }
        }
        for(Edge edge: currGraph.edges.values()){
            String ID = "d" + String.valueOf(demonstrationID) + "_e" + edge.getId();
            if(inputItemsMap.containsKey(ID)){
                for(ArrayList<Integer> loc: inputItemsMap.get(ID)){
                    Integer rowID = loc.get(0);
                    Integer atomID = loc.get(1);
                    if(!outputCover.containsKey(rowID)){
                        outputCover.put(rowID, new HashSet<>());
                    }
                    outputCover.get(rowID).add(atomID);
                }
            }
        }

        for(Integer rowID: outputCover.keySet()){
            if(outputCover.get(rowID).size() == atomCnt){
                return true;
            }
        }
        return false;
    }

    //    Check whether label types in current subgraph is complete
    public static Boolean checkComplete(InputGraph currGraph, HashSet<String> targetNodeLabels, HashSet<String> targetEdgeLabels,
                                        HashMap<String, HashSet<String>> outputNeed){
        HashMap<String, Boolean> currNodeFlags = new HashMap<>();
        HashMap<String, Boolean> currEdgeFlags = new HashMap<>();

        for(Node node: currGraph.nodes.values()){
            if(!currNodeFlags.containsKey(node.label)){
                currNodeFlags.put(node.label, false);
            }
            if(!currNodeFlags.get(node.label)) {
                if(outputNeed.get("node").contains(node.getId())){
                    currNodeFlags.put(node.label, true);
                }
            }
        }
        for(Edge edge: currGraph.edges.values()){
            if(!currEdgeFlags.containsKey(edge.label)){
                currEdgeFlags.put(edge.label, false);
            }
            if(!currEdgeFlags.get(edge.label)) {
                if(outputNeed.get("edge").contains(edge.getId())){
                    currEdgeFlags.put(edge.label, true);
                }
            }
        }

        for(String nodeLabel: targetNodeLabels){
            if(!currNodeFlags.containsKey(nodeLabel)){
                return false;
            }
            if(!currNodeFlags.get(nodeLabel)){
                return false;
            }
        }
        for(String edgeLabel: targetEdgeLabels){
            if(!currEdgeFlags.containsKey(edgeLabel)){
                return false;
            }
            if(!currEdgeFlags.get(edgeLabel)){
                return false;
            }
        }
        return true;
    }


    public Boolean checkIsomorphism(InputGraph currGraph){
//        check whether current subgraph is part from the former evaluated result
        return false;
    }
}
