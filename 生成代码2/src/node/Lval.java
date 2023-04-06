package node;

import java.util.ArrayList;

public class Lval implements PrimaryExp {
    private int index = -1;
    private int lev = -1;
    private String type = "int";
    private String ident;
    private int regId = -1;
    private boolean isAddr = false;
    private boolean isVarExps = false;
    private ArrayList<PrimaryExp> constExps = new ArrayList<>();

    public int getIndex() {
        return index;
    }

    public void setIndex(int index) {
        this.index = index;
    }

    public int getLev() {
        return lev;
    }

    public void setLev(int lev) {
        this.lev = lev;
    }

    @Override
    public String getType() {
        return type;
    }

    @Override
    public void setType(String type) {
        this.type = type;
    }

    public String getIdent() {
        return ident;
    }

    public void setIdent(String ident) {
        this.ident = ident;
    }

    public String getRegName() {
        return "$" + regId;
    }

    public int getRegId() {
        return regId;
    }

    public void setRegId(int regId) {
        this.regId = regId;
    }

    public boolean isAddr() {
        return isAddr;
    }

    public void setAddr(boolean addr) {
        isAddr = addr;
    }

    public Integer getConstExpsSize() {
        return constExps.size();
    }

    public ArrayList<PrimaryExp> getConstExps() {
        return constExps;
    }

    public void addConstExp(PrimaryExp constExp) {
        this.constExps.add(constExp);
        if (!(constExp instanceof Number)) {
            isVarExps = true;
        }
    }

    public boolean isVarExps() {
        return isVarExps;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        if (regId >= 0) {
            sb.append(getRegName());
        } else {
            sb.append(ident);
        }
        sb.append("@" + lev);
        if (index >= 0) {
            if (isAddr) {
                sb.append("&" + index);
            } else {
                sb.append("~" + index);
            }
        }
        return sb.toString();
    }
}
