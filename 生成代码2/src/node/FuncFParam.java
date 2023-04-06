package node;

import java.util.ArrayList;

public class FuncFParam implements SymbolRow {
    private int lev = -1;
    private String type;
    private String ident;
    private ArrayList<PrimaryExp> constExps = new ArrayList<>();

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getLev() {
        return lev;
    }

    public void setLev(int lev) {
        this.lev = lev;
    }

    public String getIdent() {
        return ident;
    }

    public void setIdent(String ident) {
        this.ident = ident;
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
                // System.out.println("FuncFParam error");
                return -1;
            }
        }
        if (constExps.get(constExps.size() - 1) instanceof Number) {
            value += ((Number) constExps.get(constExps.size() - 1)).getNum();
        } else {
            // System.out.println("FuncFParam error");
            return -1;
        }
        return value;
    }

    public ArrayList<PrimaryExp> getConstExps() {
        return constExps;
    }

    public int getConstExpsSize() {
        return constExps.size();
    }

    public void addConstExp(PrimaryExp constExp) {
        this.constExps.add(constExp);
    }

    public SymbolRow search(String name) {
        return name.equals(ident) ? this : null;
    }

    @Override
    public String toString() {
        return ident + "@" + lev + "\n";
    }
}
