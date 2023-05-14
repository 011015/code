package node;

import java.util.ArrayList;

public class VarDecl {
    private String type;
    private ArrayList<VarDef> varDefs = new ArrayList<>();

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public ArrayList<VarDef> getVarDefs() {
        return varDefs;
    }

    public void addVarDef(VarDef varDef) {
        this.varDefs.add(varDef);
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        for (VarDef varDef : varDefs) {
            sb.append(varDef.toString());
        }
        return sb.toString();
    }
}
