package synth.core.data.dataStructures;

import java.util.*;

public class Node {
    public Node(String label, LinkedHashMap<String, Object> attributes, String id) {
        this.label = label;
        this.attributes = attributes;
        this.id = id;
    }
    public String TId;

    public String getTId() {
        return TId;
    }

    public void setTId(String tId) {
        this.TId = tId;
    }

    public final String label;
    private LinkedHashMap<String, Object> attributes;
    public Integer exampleID;

    public LinkedHashMap<String, Object> getAttributes() {
        List<String> sortedKeys = new ArrayList<>(attributes.keySet());
        Collections.sort(sortedKeys);
        LinkedHashMap<String, Object> sorted = new LinkedHashMap<>();
        for (String key : sortedKeys) {
            sorted.put(key, attributes.get(key));
        }
        return sorted;
    }

    public void setAttributes(LinkedHashMap<String, Object> attributes) {
        this.attributes = attributes;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    private String id;
    public boolean contains(HashMap<String, Object> node2){
        return this.attributes.entrySet().containsAll(node2.entrySet());
    }

    public Node copy(String id){
        Node copied = new Node(label, attributes, id);
        return copied;
    }

}
