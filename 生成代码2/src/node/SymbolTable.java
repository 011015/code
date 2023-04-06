package node;

import java.util.ArrayList;

public class SymbolTable {
    private ArrayList<SymbolRow> symbolRows = new ArrayList<>();
    private SymbolTable parentTable = null;
    private ArrayList<SymbolTable> childTables = new ArrayList<>();

    public ArrayList<SymbolRow> getSymbolRows() {
        return symbolRows;
    }

    public void addSymbolRow(SymbolRow symbolRow) {
        this.symbolRows.add(symbolRow);
    }

    public SymbolTable getParentTable() {
        return parentTable;
    }

    public void setParentTable(SymbolTable parentTable) {
        this.parentTable = parentTable;
    }

    public ArrayList<SymbolTable> getChildTables() {
        return childTables;
    }

    public void addChildTable(SymbolTable childTable) {
        this.childTables.add(childTable);
    }

    public void delChildTable(SymbolTable childTable) {
        this.childTables.remove(childTable);
    }

    public SymbolRow searchTable(String name) {
        SymbolRow symbolRow;
        for (SymbolRow sr : symbolRows) {   //  当前表
            symbolRow = sr.search(name);
            if (symbolRow != null) {
                return symbolRow;
            }
        }
        if (parentTable != null) {  // 父表
            symbolRow = parentTable.searchTable(name);
            if (symbolRow != null) {
                return symbolRow;
            }
        }
        return null;
    }

    public boolean checkB(String name) {
        int count = 0;
        SymbolRow symbolRow;
        for (SymbolRow sr : symbolRows) {   //  当前表
            if (count >= 2) {
                return true;
            }
            symbolRow = sr.search(name);
            if (symbolRow != null) {
                count++;
            }
        }
        if (count >= 2) {
            return true;
        } else {
            return false;
        }
    }
}
