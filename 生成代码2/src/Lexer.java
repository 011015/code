import java.io.IOException;
import java.util.HashMap;

public class Lexer {
    private int line = 1;
    private int pos = 0;
    private final String input;
    private final HashMap<String, String> reservedWord = new HashMap<>();
    private final HashMap<String, String> symbol = new HashMap<>();

    public Lexer(String input) {
        this.input = input;
        setReservedWord();
        setSymbol();
    }

    public void peekPos() {
        System.out.println("-----------:" + pos);
    }

    public boolean searchEQ() {
        int pos = this.pos;
        while (pos < input.length()) {
            if (input.charAt(pos) == '=') {
                return true;
            } else if (input.charAt(pos) == ';') {
                return false;
            }
            pos++;
        }
        return false;
    }

    public int view1() throws IOException {
        int pos = this.pos;
        Word curWord = getWord();
        if (curWord.getCategoryCode().equals("IDENFR")) {
            Word nextWord = getWord();
            this.pos = pos;
            if (nextWord.getCategoryCode().equals("LPARENT")) {
                return 1; // FuncDef
            } else {
                return 0; // VarDef
            }
        } else if (curWord.getCategoryCode().equals("MAINTK")) {
            this.pos = pos;
            return 2; // MainFuncDef
        }
        this.pos = pos;
        return -1; // Error
    }

    public boolean view2() {
        return input.charAt(this.pos) == '(';
    }

    public Word getWord() throws IOException {
        for (; pos < input.length(); ) {
            char sym = input.charAt(pos);
            if (sym == '_' || Character.isLetter(sym)) {
                String word = getIdentOrReservedWord();
                return new Word(line, getReservedWordType(word), word);
            } else if (Character.isDigit(sym)) {
                return new Word(line, "INTCON", getIntConst());
            } else if ("+-*%;,()[]{}".indexOf(sym) != -1) {
                pos++;
                String word = String.valueOf(sym);
                String type = getSymType(word);
                return new Word(line, type, word);
            } else if ("!<>=".indexOf(sym) != -1) {
                pos++;
                StringBuilder word = new StringBuilder(String.valueOf(sym));
                char nextSym = input.charAt(pos);
                if (nextSym == '=') {
                    pos++;
                    word.append(nextSym);
                }
                String type = getSymType(word.toString());
                return new Word(line, type, word.toString());
            } else if (sym == '&' || sym == '|') {
                pos++;
                StringBuilder word = new StringBuilder(String.valueOf(sym));
                char nextSym = input.charAt(pos);
                if (nextSym == sym) {
                    pos++;
                    word.append(nextSym);
                    String type = getSymType(word.toString());
                    return new Word(line, type, word.toString());
                }
            } else if (sym == '/') {
                pos++;
                char nextSym = input.charAt(pos);
                if (nextSym == sym) {
                    pos++;
                    while (pos < input.length() && input.charAt(pos) != '\n') {
                        pos++;
                    }
                } else if (nextSym == '*') {
                    pos++;
                    while (pos + 1 < input.length() && !(input.charAt(pos) == '*' &&
                            input.charAt(pos + 1) == '/')) {
                        if (input.charAt(pos) == '\n') {
                            line++;
                        }
                        pos++;
                    }
                    if (input.charAt(pos) == '*' && input.charAt(pos + 1) == '/') {
                        pos = pos + 2; // "*/"
                    }
                } else {
                    String word = String.valueOf(sym);
                    String type = getSymType(word);
                    return new Word(line, type, word);
                }
            } else if (sym == '"') {
                pos++;
                StringBuilder word = new StringBuilder();
                word.append(sym);
                while (pos < input.length() && input.charAt(pos) != '"') {
                    word.append(input.charAt(pos));
                    pos++;
                }
                if (input.charAt(pos) == '"') {
                    word.append(input.charAt(pos));
                    pos++; // '"'
                }
                return new Word(line, "STRCON", word.toString());
            } else if (sym == '\n') {
                pos++;
                line++;
            } else {
                pos++;
            }
        }
        return null;
    }

    private String getIntConst() {
        StringBuilder sb = new StringBuilder();
        while (pos < input.length() && Character.isDigit(input.charAt(pos))) {
            sb.append(input.charAt(pos));
            pos++;
        }
        return sb.toString();
    }

    private String getIdentOrReservedWord() {
        StringBuilder sb = new StringBuilder();
        while (pos < input.length() && (input.charAt(pos) == '_' ||
                Character.isLetterOrDigit(input.charAt(pos)))) {
            sb.append(input.charAt(pos));
            pos++;
        }
        return sb.toString();
    }

    private void setReservedWord() {
        reservedWord.put("main", "MAINTK");
        reservedWord.put("const", "CONSTTK");
        reservedWord.put("int", "INTTK");
        reservedWord.put("break", "BREAKTK");
        reservedWord.put("continue", "CONTINUETK");
        reservedWord.put("if", "IFTK");
        reservedWord.put("else", "ELSETK");
        reservedWord.put("while", "WHILETK");
        reservedWord.put("getint", "GETINTTK");
        reservedWord.put("printf", "PRINTFTK");
        reservedWord.put("return", "RETURNTK");
        reservedWord.put("void", "VOIDTK");
    }

    private void setSymbol() {
        symbol.put("!", "NOT");
        symbol.put("&&", "AND");
        symbol.put("||", "OR");
        symbol.put("+", "PLUS");
        symbol.put("-", "MINU");
        symbol.put("*", "MULT");
        symbol.put("/", "DIV");
        symbol.put("%", "MOD");
        symbol.put("<", "LSS");
        symbol.put("<=", "LEQ");
        symbol.put(">", "GRE");
        symbol.put(">=", "GEQ");
        symbol.put("==", "EQL");
        symbol.put("!=", "NEQ");
        symbol.put("=", "ASSIGN");
        symbol.put(";", "SEMICN");
        symbol.put(",", "COMMA");
        symbol.put("(", "LPARENT");
        symbol.put(")", "RPARENT");
        symbol.put("[", "LBRACK");
        symbol.put("]", "RBRACK");
        symbol.put("{", "LBRACE");
        symbol.put("}", "RBRACE");
    }

    private String getReservedWordType(String sym) {
        if (reservedWord.containsKey(sym)) {
            return reservedWord.get(sym);
        } else {
            return "IDENFR";
        }
    }

    private String getSymType(String sym) {
        return symbol.get(sym);
    }
}
