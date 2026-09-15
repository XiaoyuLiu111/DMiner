package synth.core.data.dataStructures;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import java.io.FileReader;
import java.io.IOException;
import java.util.*;

public class IntermediateData {

    public static ArrayList<Demonstration> getDemonstrations(String filePath, Integer startDemonID, Boolean onlyOriginal){
        ArrayList<Demonstration> demons = new ArrayList<>();
        JSONParser parser = new JSONParser();
        try {
            JSONObject obj = (JSONObject) parser.parse(new FileReader(filePath));
            JSONArray demonstrations = (JSONArray) obj.get("demonstrations");
            Integer endDemonID = startDemonID + demonstrations.size();
            if(onlyOriginal){
                endDemonID = startDemonID + 1;
            }
            for(int exampleID=startDemonID; exampleID<endDemonID; exampleID++) {
                JSONObject demonstration = (JSONObject) demonstrations.get(exampleID);

                JSONObject inputGraphData = (JSONObject) demonstration.get("inputGraph");
                InputGraph inputData = inputGraphHelper(inputGraphData);

                JSONObject mapping1Data = (JSONObject) demonstration.get("mapping1");
                HashMap<String, ArrayList<String>> mapping1 = mapping1Helper(mapping1Data, exampleID);
                JSONObject mapping2Data = (JSONObject) demonstration.get("mapping2");
                HashMap<String, ArrayList<String>> mapping2 = mapping2Helper(mapping2Data, exampleID);
                JSONArray mapping3Data = (JSONArray) demonstration.get("mapping3");
                ArrayList<Computation> mapping3 = mapping3Helper(mapping3Data, exampleID);
                JSONArray correspondenceData = (JSONArray) demonstration.get("correspondence");
                ArrayList<ArrayList<String>> correspondence = corHelper(correspondenceData, exampleID);

                Demonstration demo = new Demonstration(inputData, mapping1, mapping2, mapping3);
                demo.correspondence = correspondence;
                demons.add(demo);
            }

            return demons;
        } catch (
                ParseException | IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static InputGraph inputGraphHelper(JSONObject inputGraphData){
        JSONArray nodes =  (JSONArray) inputGraphData.get("nodes");
        JSONArray edges =  (JSONArray) inputGraphData.get("edges");
        HashMap<String, Node> nodesList = new HashMap<>();
        HashMap<String, Edge> edgesList = new HashMap<>();
        HashMap<String, ArrayList<String>> nodeLabel2PropertiesStandard = new HashMap<>();
        HashMap<String, ArrayList<String>> edgeLabel2PropertiesStandard = new HashMap<>();

        for (int i=0; i<nodes.size(); i++) {
            JSONObject nodeObject = (JSONObject) nodes.get(i);
            String label = (String) nodeObject.get("label");
            ArrayList<String> keys = new ArrayList<String>(nodeObject.keySet());
            HashMap<String, Object> tmp = new HashMap<>();
            String nodeID = null;
            Boolean reOrder = true;
            if(!nodeLabel2PropertiesStandard.containsKey(label)) {
                reOrder = false;
                for (String key: keys){
                    if (key.equals("element_id")){
                        nodeID = String.valueOf(nodeObject.get("element_id"));
                    }
                    else if(!key.equals("label")){
                        tmp.put(key, nodeObject.get(key));
                        if(!nodeLabel2PropertiesStandard.containsKey(label)) {
                            nodeLabel2PropertiesStandard.put(label, new ArrayList<>());
                        }
                        nodeLabel2PropertiesStandard.get(label).add(key);
                    }
                }
            } else {
                for (String key: keys){
                    if (key.equals("element_id")){
                        nodeID = String.valueOf(nodeObject.get("element_id"));
                    }
                    else if(!key.equals("label")){
                        tmp.put(key, nodeObject.get(key));
                    }
                }
            }

            LinkedHashMap<String,Object> properties = new LinkedHashMap<>();
            if (reOrder){
                for (String property: nodeLabel2PropertiesStandard.get(label)) {
                    properties.put(property, tmp.get(property));
                }
            } else {
                properties.putAll(tmp);
            }
            Node node = new Node(label, properties, nodeID);
            nodesList.put(nodeID, node);
        }

        for (int i=0; i<edges.size(); i++) {
            JSONObject edgeObject = (JSONObject) edges.get(i);
            String edgeLabel = (String)edgeObject.get("label");
            ArrayList<String> keys = new ArrayList<String>(edgeObject.keySet());
            HashMap<String, Object> tmp = new HashMap<>();
            String edgeID = null;
            String start = null;
            String end = null;
            Boolean reOrder = true;
            if(!edgeLabel2PropertiesStandard.containsKey(edgeLabel)){
                reOrder = false;
                for (String key: keys){
                    if (key.equals("element_id")){
                        edgeID = String.valueOf(edgeObject.get("element_id"));
                    }
                    else if (key.equals("start")){
                        start = String.valueOf(edgeObject.get("start"));
                    }
                    else if (key.equals("end")){
                        end = String.valueOf(edgeObject.get("end"));
                    }
                    else if(!key.equals("label")) {
                        tmp.put(key, edgeObject.get(key));
                        if(!edgeLabel2PropertiesStandard.containsKey(edgeLabel)) {
                            edgeLabel2PropertiesStandard.put(edgeLabel, new ArrayList<>());
                        }
                        edgeLabel2PropertiesStandard.get(edgeLabel).add(key);
                    }
                }
            } else {
                for (String key: keys){
                    if (key.equals("element_id")){
                        edgeID = String.valueOf(edgeObject.get("element_id"));
                    }
                    else if (key.equals("start")){
                        start = String.valueOf(edgeObject.get("start"));
                    }
                    else if (key.equals("end")){
                        end = String.valueOf(edgeObject.get("end"));
                    }
                    else if(!key.equals("label")) {tmp.put(key, edgeObject.get(key));}
                }
            }
            boolean bidirection = false;
            LinkedHashMap<String,Object> properties = new LinkedHashMap<>();
            if (reOrder){
                for (String property: edgeLabel2PropertiesStandard.get(edgeLabel)){
                    properties.put(property, tmp.get(property));
                }
            } else {
                properties.putAll(tmp);
            }
            Edge edge = new Edge(edgeLabel, properties, start, end, edgeID, bidirection);
            edgesList.put(edgeID, edge);
        }
        InputGraph inputGraph = new InputGraph(nodesList, edgesList);
        return inputGraph;
    }

    public static HashMap<String, ArrayList<String>> mapping1Helper(JSONObject mapping1Data, Integer demonstrationID){
        JSONArray nodes =  (JSONArray) mapping1Data.get("nodes");
        JSONArray edges =  (JSONArray) mapping1Data.get("edges");
        HashMap<String, ArrayList<String>> mapping1 = new HashMap<>();

        for (int i=0; i<nodes.size(); i++) {
            JSONObject nodeObject = (JSONObject) nodes.get(i);
            String valID =  "d" + String.valueOf(demonstrationID) + "_n" + nodeObject.get("output");
            JSONArray inputItems = (JSONArray) nodeObject.get("input");
            ArrayList<String> inputIDs = (ArrayList<String>) inputItems.get(0);
            ArrayList<String> inputIDsP = new ArrayList<>();
            for(String inputID: inputIDs){
                inputIDsP.add("n" + inputID);
            }
            mapping1.put(valID, inputIDsP);
        }
        for (int i=0; i<edges.size(); i++) {
            JSONObject edgeObject = (JSONObject) edges.get(i);
            String valID = "d" + String.valueOf(demonstrationID) + "_e" + edgeObject.get("output");
            JSONArray inputItems = (JSONArray) edgeObject.get("input");
            ArrayList<String> inputIDs = (ArrayList<String>) inputItems.get(0);
            ArrayList<String> inputIDsP = new ArrayList<>();
            for(String inputID: inputIDs){
                inputIDsP.add("e" + inputID);
            }
            mapping1.put(valID, inputIDsP);
        }

        return mapping1;
    }

    public static HashMap<String, ArrayList<String>> mapping2Helper(JSONObject mapping2Data, Integer demonstrationID){
        JSONArray nodes =  (JSONArray) mapping2Data.get("nodes");
        JSONArray edges =  (JSONArray) mapping2Data.get("edges");
        HashMap<String, ArrayList<String>> mapping2 = new HashMap<>();

        for (int i=0; i<nodes.size(); i++) {
            JSONObject nodeObject = (JSONObject) nodes.get(i);
//            JSONArray propertiesData =  (JSONArray) nodeObject.get("property");
            String propertyData = (String) nodeObject.get("property");
//            ArrayList<String> properties = new ArrayList<>();
            ArrayList<String> properties = new ArrayList<>(Arrays.asList(propertyData));
//            for(int j=0; j<propertiesData.size(); j++){
//                properties.add((String) propertiesData.get(j));
//            }
            mapping2.put("d" + String.valueOf(demonstrationID) + "_n" + nodeObject.get("output"), properties);
        }
        for (int i=0; i<edges.size(); i++) {
            JSONObject edgeObject = (JSONObject) edges.get(i);
//            JSONArray propertiesData =  (JSONArray) edgeObject.get("property");
            String propertyData = (String) edgeObject.get("property");
//            ArrayList<String> properties = new ArrayList<>();
            ArrayList<String> properties = new ArrayList<>(Arrays.asList(propertyData));
//            for(int j=0; j<propertiesData.size(); j++){
//                properties.add((String) propertiesData.get(j));
//            }
            mapping2.put("d" + String.valueOf(demonstrationID) + "_e" + edgeObject.get("output"), properties);
        }

        return mapping2;
    }

    public static ArrayList<Computation> mapping3Helper(JSONArray mapping3Data, Integer demonstrationID){
        ArrayList<Computation> computations = new ArrayList<>();
        for (int i=0; i<mapping3Data.size(); i++) {
            JSONObject computationData = (JSONObject) mapping3Data.get(i);
//            Integer val = (Integer) computationData.get("value");
            Computation single = helper(computationData, demonstrationID);

            computations.add(single);
        }
        return computations;
    }

    public static Computation helper(JSONObject computationData, Integer demonstrationID){
        String operator = (String) computationData.get("operator");
        if(operator.length() == 0){
            operator = "empty";
        }
        String property = (String) computationData.get("property");
        ArrayList<String> dataIDs = new ArrayList<>();
        JSONArray data = (JSONArray) computationData.get("data");
        for(int i=0; i<data.size(); i++){
            dataIDs.add("d"+demonstrationID+"_"+(String) data.get(i));
        }

        // TODO: Deduplicate if operator is max or min
        ArrayList<String> tmp = new ArrayList<>();
        if(operator.equals("max") || operator.equals("min")){
            for(String dataID: dataIDs){
                if(!tmp.contains(dataID)){
                    tmp.add(dataID);
                }
            }
            dataIDs = tmp;
        }

        Computation computation = new Computation();

        JSONObject lhsObject = (JSONObject) computationData.get("lhs");
        if(!lhsObject.isEmpty()){
            computation.lhs = helper(lhsObject, demonstrationID);
        }
        JSONObject rhsObject = (JSONObject) computationData.get("rhs");
        if(!rhsObject.isEmpty()){
            computation.rhs = helper(rhsObject, demonstrationID);
        }

        computation.operator = operator;
        computation.property = property;
        computation.dataID=dataIDs;

        return computation;
    }

    public static ArrayList<ArrayList<String>> corHelper(JSONArray correpondences, Integer demonstrationID){
//        TODO: Read as a set of list, each list contains value IDs that are in the same group
        ArrayList<ArrayList<String>> allCors = new ArrayList<>();
//        correpsondences is array of array
        for(int rowID=0; rowID < correpondences.size(); rowID++){
            JSONArray row = (JSONArray) correpondences.get(rowID);
            ArrayList<String> corOnRow = new ArrayList<>();
            for(int colID=0; colID < row.size(); colID++){
                corOnRow.add("d" + String.valueOf(demonstrationID) + "_" + (String) row.get(colID));
            }
            allCors.add(corOnRow);
        }
        return allCors;
    }
}
