package node;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class VarDef implements SymbolRow {
    private int lev = -1;
    private String type;
    private String ident;
    private int index = 0;
    private ArrayList<PrimaryExp> constExps = new ArrayList<>();
    private ArrayList<PrimaryExp> initVals = new ArrayList<>();
    private HashMap<Integer, PrimaryExp> vals = new HashMap<>();

    public SymbolRow search(String name) {
        return name.equals(ident) ? this : null;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getType() {
        return type;
    }

    public int getLev() {
        return lev;
    }

    public void setLev(int lev) {
        this.lev = lev;
    }

    public void setValue(ArrayList<PrimaryExp> constExps, PrimaryExp value) {
        int index = getIndex(constExps);
        vals.put(index, value);
    }

    public void setNullValue() {
        for (Map.Entry<Integer, PrimaryExp> entry : vals.entrySet()) {
            vals.put(entry.getKey(), null);
        }
    }

    public PrimaryExp getValue(ArrayList<PrimaryExp> constExps) {
        if (constExps.size() == 0) {
            return vals.getOrDefault(0, null);
        }
        int index = getIndex(constExps);
        return vals.getOrDefault(index, null);
    }

    public int getIndex(ArrayList<PrimaryExp> constExps) {
        if (constExps.size() == 0) {
            return 0;
        }
        int value = 0;
        for (int i = 0; i < this.constExps.size() - 1; i++) {
            if (constExps.get(i) instanceof Number) {
                value += ((Number) constExps.get(i)).mul(this.constExps.get(i + 1));
            } else {
                // System.out.println("VarDef error:" + constExps.get(i));
                return -1;
            }
        }
        if (constExps.size() == this.constExps.size()) {
            if (constExps.get(constExps.size() - 1) instanceof Number) {
                value += ((Number) constExps.get(constExps.size() - 1)).getNum();
            } else {
                // System.out.println("VarDef error:" + constExps.get(constExps.size() - 1));
                return -1;
            }
        }
        return value;
    }

    public boolean isArr() {
        return constExps.size() != 0;
    }

    public String getIdent() {
        return ident;
    }

    public void setIdent(String ident) {
        this.ident = ident;
    }

    public int getConstExpsSize() {
        return constExps.size();
    }

    public int getArrSize() {
        int size = 4;
        for (PrimaryExp exp : constExps) {
            if (exp instanceof Number) {
                size *= ((Number) exp).getNum();
            } else {
                System.out.println("VarDef error");
            }
        }
        return size;
    }

    public void addConstExp(PrimaryExp constExp) {
        this.constExps.add(constExp);
    }

    public ArrayList<PrimaryExp> getConstExps() {
        return constExps;
    }

    public String addInitVal(PrimaryExp initVal) {
        String str;
        if (isArr()) {
            str = "decl var " + ident + "@" + lev + "&" + index + " " + initVal + "\n";
        } else {
            str = "decl var " + ident + "@" + lev + " " + initVal + "\n";
        }
        this.initVals.add(initVal);
        vals.put(index, initVal);
        index++;
        return str;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("decl " + type + " " + ident + "@" + lev);
        for (Map.Entry<Integer, PrimaryExp> entry : vals.entrySet()) {
            sb.append(" " + entry.getValue());
        }
        sb.append("\n");
        return sb.toString();
    }
}
