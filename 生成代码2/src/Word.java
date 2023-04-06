public class Word {
    private int line;
    private String categoryCode;
    private String name;

    public Word(int line, String categoryCode, String name) {
        this.line = line;
        this.categoryCode = categoryCode;
        this.name = name;
    }

    public int getLine() {
        return line;
    }

    public void setLine(int line) {
        this.line = line;
    }

    public String getCategoryCode() {
        return categoryCode;
    }

    public void setCategoryCode(String categoryCode) {
        this.categoryCode = categoryCode;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String toString() {
        return categoryCode + ' ' + name + '\n';
    }
}
