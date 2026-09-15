package synth.core.filterSyn;

import java.util.ArrayList;
import java.util.HashMap;

public class StringEncoder {

    public HashMap<String, Integer> getEncodingMap() {
        return encodingMap;
    }

    public HashMap<Integer, String> getDecodingMap() {
        return decodingMap;
    }

    public HashMap<String, Integer> encodingMap = new HashMap<>();
    public HashMap<Integer, String> decodingMap = new HashMap<>();
    public Integer encodePosi = 1;

    public void updateEncodingMap(String string, Integer number){
        if(!this.encodingMap.containsKey(string)){
            this.encodingMap.put(string, number);
        }
    }

    public void updateDecodingMap(String string, Integer number){
        if(!this.decodingMap.containsKey(number)){
            this.decodingMap.put(number, string);
        }
    }

    public Integer encode(String val){
        if(this.encodingMap.isEmpty()){
            this.encodingMap.put("", 0);
            this.decodingMap.put(0, "");
            encodePosi ++;
        }
        if(!this.encodingMap.containsKey(val)){
            updateEncodingMap((String) val, this.encodePosi);
            updateDecodingMap((String) val, this.encodePosi);
            this.encodePosi++;
        }
        return this.encodingMap.get(val);
    }
}
