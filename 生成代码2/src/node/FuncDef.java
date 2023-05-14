package node;

import java.util.ArrayList;

public class FuncDef implements SymbolRow {
    private int lev = -1;
    private String type;
    private String ident;
    private ArrayList<FuncFParam> funcFParams = new ArrayList<>();

    public SymbolRow search(String name) {
        return ident.equals(name) ? this : null;
    }

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

    public void setParamsLev(int lev) {
        for (FuncFParam funcFParam : funcFParams) {
            funcFParam.setLev(lev);
        }
    }

    public String getIdent() {
        return ident;
    }

    public void setIdent(String ident) {
        this.ident = ident;
    }

    public ArrayList<FuncFParam> getFuncFParams() {
        return funcFParams;
    }

    public void addFuncFParam(FuncFParam funcFParam) {
        this.funcFParams.add(funcFParam);
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("proc " + type + " " + ident + "@" + lev + " " + funcFParams.size() + "\n");
        for (FuncFParam funcFParam : funcFParams) {
            sb.append("para" + " " + funcFParam.getType() + " " + ident + "@" + lev + " ");
            sb.append(funcFParam.toString());
        }
        return sb.toString();
    }
}
