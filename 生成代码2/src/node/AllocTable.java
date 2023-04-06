package node;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class AllocTable {
    private String funcName;
    private HashMap<String, Integer> allocSpaces = new HashMap<>();
    private ArrayList<String> constArrs = new ArrayList<>();

    public String getFuncName() {
        return funcName;
    }

    public void setFuncName(String funcName) {
        this.funcName = funcName;
    }

    public HashMap<String, Integer> getAllocSpaces() {
        return allocSpaces;
    }

    public void addAllocSpace(String ident, int size) {
        allocSpaces.put(ident, size);
    }

    public boolean searchArr(String ident) {
        for (Map.Entry<String, Integer> alloc : allocSpaces.entrySet()) {
            if (ident.equals(alloc.getKey())) {
                return true;
            }
        }
        return false;
    }

    public boolean isConstArr(String constArr) {
        return constArrs.contains(constArr);
    }

    public void addConstArr(String constArr) {
        this.constArrs.add(constArr);
    }
}
