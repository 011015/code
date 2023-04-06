package node;

public interface SymbolRow {
    SymbolRow search(String name);

    String getType();

    String getIdent();

    int getLev();
}
