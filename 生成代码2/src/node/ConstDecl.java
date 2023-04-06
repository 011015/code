package node;

import java.util.ArrayList;

public class ConstDecl {
    private String type;
    private ArrayList<ConstDef> constDefs = new ArrayList<>();

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public void addConstDef(ConstDef constDef) {
        constDefs.add(constDef);
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        for (ConstDef constDef : constDefs) {
            sb.append(constDef.toString());
        }
        return sb.toString();
    }
}
