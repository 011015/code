import node.*;
import node.Number;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Map;

public class Parser {
    private Word word;
    private final Lexer lexer;
    private SymbolTable curTable = new SymbolTable();   // <ConstDef>,<VarDef>,<FuncDef>,<FuncFParam>
    private ArrayList<AllocTable> allocTables = new ArrayList<>();
    private AllocTable curAllocTable;
    private AllocTable globalAllocTable;
    private HashSet<String> strings = new HashSet<>();
    private int id1 = 0;
    private int id2 = 0;
    private int lev = 0;
    private int indexCond = -1;
    private int indexLoop = -1;
    private int lineC;
    private int lineDE;
    private int lineF;
    private int lineG;
    private int lineH;
    private int lineIJK;
    private int lineL;
    private boolean isGlobal = false;
    private boolean isCond = false;
    private boolean isLoop = false;
    private boolean isCall = false;
    private boolean isReturn = false;
    private boolean hasReturnValue = false;

    public Parser(Lexer lexer) throws IOException {
        // Switch.openLexer();
        // Switch.openParser();
        Switch.openMidCode();
        // Switch.openError();
        this.lexer = lexer;
        word = lexer.getWord();
        _compUnit();
        // printAllocAndStr();
        // Switch.closeError();
        Switch.closeMidCode();
        // Switch.closeParser();
        // Switch.closeLexer();
    }

    public void printAllocAndStr() {
        System.out.print("\n");
        for (AllocTable allocTable : allocTables) {
            for (Map.Entry<String, Integer> alloc : allocTable.getAllocSpaces().entrySet()) {
                System.out.println(alloc.getKey() + "," + alloc.getValue());
            }
        }
        for (String str : strings) {
            System.out.println(str);
        }
    }

    public ArrayList<AllocTable> getAllocTables() {
        return allocTables;
    }

    public HashSet<String> getStrings() {
        return strings;
    }

    private void _compUnit() throws IOException {
        curAllocTable = new AllocTable();
        curAllocTable.setFuncName("@global");
        globalAllocTable = curAllocTable;
        isGlobal = true;
        while (word.getCategoryCode().equals("CONSTTK") ||
                (word.getCategoryCode().equals("INTTK") &&
                        lexer.view1() == 0)) {
            if (word.getCategoryCode().equals("CONSTTK")) {
                _constDecl();
            } else if (word.getCategoryCode().equals("INTTK")) {
                _varDecl();
            }
        }
        isGlobal = false;
        writeMidCode("return\n");
        allocTables.add(curAllocTable);
        while (word.getCategoryCode().equals("VOIDTK") ||
                (word.getCategoryCode().equals("INTTK") &&
                        lexer.view1() == 1)) {
            curAllocTable = new AllocTable();
            hasReturnValue = false;
            _funcDef();
            if (!isReturn) {
                writeMidCode("ret\n");
            }
            writeMidCode("return\n");
            allocTables.add(curAllocTable);
        }
        curAllocTable = new AllocTable();
        hasReturnValue = false;
        _mainFuncDef();
        writeMidCode("return\n");
        allocTables.add(curAllocTable);
        writeParser("<CompUnit>\n");
    }

    private void _constDecl() throws IOException {
        ConstDecl constDecl = new ConstDecl();
        String type;
        if (word.getCategoryCode().equals("CONSTTK")) {
            getWord();
            if (word.getCategoryCode().equals("INTTK")) {
                constDecl.setType("int");
                type = "int";
                getWord();
                constDecl.addConstDef(_constDef(type));
                while (word.getCategoryCode().equals("COMMA")) {
                    getWord();
                    constDecl.addConstDef(_constDef(type));
                }
                if (word.getCategoryCode().equals("SEMICN")) {
                    getWord();
                } else {
                    writeError(lineIJK, "i");
                }
                /*writeMidCode(constDecl.toString());*/
            }
        }
        writeParser("<ConstDecl>\n");
    }

    private ConstDef _constDef(String type) throws IOException {
        ConstDef constDef = new ConstDef();
        curTable.addSymbolRow(constDef);
        constDef.setLev(lev);
        constDef.setType(type);
        if (word.getCategoryCode().equals("IDENFR")) {
            constDef.setIdent(word.getName());
            checkB(word.getName(), word.getLine());
            getWord();
            while (word.getCategoryCode().equals("LBRACK")) {
                getWord();
                int id1 = this.id1, id2 = this.id2;
                constDef.addConstExp(_constExp());
                this.id1 = id1;
                this.id2 = id2;
                if (word.getCategoryCode().equals("RBRACK")) {
                    getWord();
                } else {
                    writeError(lineIJK, "k");
                }
            }
            if (constDef.isArr()) {
                curAllocTable.addAllocSpace(constDef.getIdent() + "@" + lev, constDef.getArrSize());
            }
            if (word.getCategoryCode().equals("ASSIGN")) {
                getWord();
                _constInitVal(constDef);
            } else {
                writeMidCode("decl " + constDef.getType() + " " +
                        constDef.getIdent() + "@" + constDef.getLev() + "\n");
            }
        }
        // writeMidCode(constDef.toString());
        writeParser("<ConstDef>\n");
        return constDef;
    }

    private void _ident() throws IOException {
        if (word.getCategoryCode().equals("IDENFR")) {
            getWord();
        }
        writeParser("<Ident>\n");                  // 叶结点
    }

    private PrimaryExp _constExp() throws IOException {
        PrimaryExp constExp = _addExp();
        writeParser("<ConstExp>\n");
        return constExp;
    }

    private void _constInitVal(ConstDef constDef) throws IOException {
        if (word.getCategoryCode().equals("LBRACE")) {
            getWord();
            if (!word.getCategoryCode().equals("RBRACE")) {
                _constInitVal(constDef);
                while (word.getCategoryCode().equals("COMMA")) {
                    getWord();
                    _constInitVal(constDef);
                }
            }
            if (word.getCategoryCode().equals("RBRACE")) {
                getWord();
            }
        } else if (isExp()) {
            int id1 = this.id1, id2 = this.id2;
            writeMidCode(constDef.addConstInitVal(_constExp()));
            this.id1 = id1;
            this.id2 = id2;
        }
        writeParser("<ConstInitVal>\n");
    }

    private void _varDecl() throws IOException {
        VarDecl varDecl = new VarDecl();
        String type;
        if (word.getCategoryCode().equals("INTTK")) {
            varDecl.setType("int");
            type = "int";
            getWord();
            varDecl.addVarDef(_varDef(type));
            while (word.getCategoryCode().equals("COMMA")) {
                getWord();
                varDecl.addVarDef(_varDef(type));
            }
            if (word.getCategoryCode().equals("SEMICN")) {
                getWord();
            } else {
                writeError(lineIJK, "i");
            }
            /*writeMidCode(varDecl.toString());*/
        }
        writeParser("<VarDecl>\n");
    }

    private VarDef _varDef(String type) throws IOException {
        VarDef varDef = new VarDef();
        curTable.addSymbolRow(varDef);
        varDef.setLev(lev);
        varDef.setType(type);
        if (word.getCategoryCode().equals("IDENFR")) {
            varDef.setIdent(word.getName());
            checkB(word.getName(), word.getLine());
            getWord();
            while (word.getCategoryCode().equals("LBRACK")) {
                getWord();
                int id1 = this.id1, id2 = this.id2;
                varDef.addConstExp(_constExp());
                this.id1 = id1;
                this.id2 = id2;
                if (word.getCategoryCode().equals("RBRACK")) {
                    getWord();
                } else {
                    writeError(lineIJK, "k");
                }
            }
            if (varDef.isArr() || isGlobal) {
                curAllocTable.addAllocSpace(varDef.getIdent() + "@" + lev, varDef.getArrSize());
            }
            if (word.getCategoryCode().equals("ASSIGN")) {
                getWord();
                _initVal(varDef);
            } else {
                writeMidCode("decl " + varDef.getType() + " " +
                        varDef.getIdent() + "@" + varDef.getLev() + "\n");
            }
            // writeMidCode(varDef.toString());
            writeParser("<VarDef>\n");
        }
        return varDef;
    }

    private void _initVal(VarDef varDef) throws IOException {
        if (isExp()) {
            int id1 = this.id1, id2 = this.id2;
            writeMidCode(varDef.addInitVal(_exp()));
            this.id1 = id1;
            this.id2 = id2;
        } else if (word.getCategoryCode().equals("LBRACE")) {
            getWord();
            if (!word.getCategoryCode().equals("RBRACE")) {
                _initVal(varDef);
                while (word.getCategoryCode().equals("COMMA")) {
                    getWord();
                    _initVal(varDef);
                }
            }
            if (word.getCategoryCode().equals("RBRACE")) {
                getWord();
            }
        }
        writeParser("<InitVal>\n");
    }

    private PrimaryExp _exp() throws IOException {
        PrimaryExp exp = _addExp();
        writeParser("<Exp>\n");
        return exp;
    }

    private PrimaryExp _addExp() throws IOException {
        PrimaryExp addExp1 = _mulExp();
        writeParser("<AddExp>\n");
        while (word.getCategoryCode().equals("PLUS") ||
                word.getCategoryCode().equals("MINU")) {
            String op = word.getName();
            getWord();
            PrimaryExp addExp2 = _mulExp();
            addExp1 = binaryOp(op, addExp1, addExp2);
            writeParser("<AddExp>\n");
        }
        return addExp1;
    }

    private PrimaryExp _mulExp() throws IOException {
        PrimaryExp mulExp1 = _unaryExp();
        writeParser("<MulExp>\n");
        while (word.getCategoryCode().equals("MULT") ||
                word.getCategoryCode().equals("DIV") ||
                word.getCategoryCode().equals("MOD")) {
            String op = word.getName();
            getWord();
            PrimaryExp mulExp2 = _unaryExp();
            mulExp1 = binaryOp(op, mulExp1, mulExp2);
            writeParser("<MulExp>\n");
        }
        return mulExp1;
    }

    private PrimaryExp _unaryExp() throws IOException {
        if (word.getCategoryCode().equals("PLUS") ||
                word.getCategoryCode().equals("MINU") ||
                word.getCategoryCode().equals("NOT")) {
            String op = word.getName();
            _unaryOp();
            PrimaryExp unaryExp = _unaryExp();
            if (unaryExp instanceof Number) {
                writeParser("<UnaryExp>\n");
                return unaryOp(op, ((Number) unaryExp).getNum());
            } else if (unaryExp instanceof Lval) {
                writeParser("<UnaryExp>\n");
                return unaryOp(op, ((Lval) unaryExp));
            }
        } else if (word.getCategoryCode().equals("IDENFR")) {
            String ident = word.getName();
            lineC = word.getLine();
            lineDE = word.getLine();
            ArrayList<PrimaryExp> params = new ArrayList<>();
            if (lexer.view2()) {
                getWord();
                if (word.getCategoryCode().equals("LPARENT")) {
                    getWord();
                    if (isExp()) {
                        isCall = true;
                        params = _funcRParams();
                        isCall = false;
                    }
                    if (word.getCategoryCode().equals("RPARENT")) {
                        getWord();
                    } else {
                        writeError(lineIJK, "j");
                    }
                }
                SymbolRow sr = curTable.searchTable(ident);
                checkC(sr, lineC);
                if (sr instanceof FuncDef) {
                    checkDE((FuncDef) sr, params, lineDE);
                    Lval lval = new Lval();
                    if (!sr.getType().equals("void")) {
                        lval.setLev(0);
                        lval.setRegId(id1++);
                        writeMidCode(writeCall(ident + "@" + sr.getLev(), params, lval));
                    } else {
                        lval.setType("void");
                        writeMidCode(writeCall(ident + "@" + sr.getLev(), params, null));
                    }
                    writeParser("<UnaryExp>\n");
                    return lval;
                } else {
                    System.out.println("_unaryExp error");
                    writeParser("<UnaryExp>\n");
                    return null;
                }
            } else {
                PrimaryExp primaryExp = _primaryExp();
                writeParser("<UnaryExp>\n");
                return primaryExp;
            }
        } else if (word.getCategoryCode().equals("LPARENT") ||
                word.getCategoryCode().equals("INTCON")) {
            PrimaryExp primaryExp = _primaryExp();
            writeParser("<UnaryExp>\n");
            return primaryExp;
        }
        writeParser("<UnaryExp>\n");
        return null;
    }

    private PrimaryExp _primaryExp() throws IOException {
        PrimaryExp primaryExp = null;
        if (word.getCategoryCode().equals("LPARENT")) {
            getWord();
            primaryExp = _exp();
            if (word.getCategoryCode().equals("RPARENT")) {
                getWord();
            } else {
                writeError(lineIJK, "j");
            }
        } else if (word.getCategoryCode().equals("IDENFR")) {
            Lval lval = _lVal();
            SymbolRow sr = curTable.searchTable(lval.getIdent());
            if (sr != null) {
                lval.setLev(sr.getLev());
            }
            checkC(sr, lineC);
            ArrayList<PrimaryExp> exps2 = null;
            if (sr instanceof VarDef) {
                PrimaryExp value;
                if (lval.getConstExpsSize() > 0) {
                    lval.setIndex(((VarDef) sr).getIndex(lval.getConstExps()));
                }
                if (lval.getConstExpsSize() < ((VarDef) sr).getConstExpsSize()) {
                    int dimension = ((VarDef) sr).getConstExpsSize() - lval.getConstExpsSize();
                    lval.setType("array_" + dimension);
                    lval.setAddr(true);
                    if (isCall) {
                        ((VarDef) sr).setNullValue();
                    }
                    if (lval.getConstExpsSize() == 0) {
                        lval.setIndex(0);
                    }
                } else {
                    value = ((VarDef) sr).getValue(lval.getConstExps());
                    // lev > 0 排除全局
                    if (!isCond && !isLoop && sr.getLev() > 0 && value instanceof Number) {
                        writeParser("<PrimaryExp>\n");
                        return value;
                    }
                }
                exps2 = ((VarDef) sr).getConstExps();
            } else if (sr instanceof ConstDef) {
                PrimaryExp value;
                if (lval.getConstExpsSize() > 0) {
                    lval.setIndex(((ConstDef) sr).getIndex(lval.getConstExps()));
                }
                if (lval.getConstExpsSize() < ((ConstDef) sr).getConstExpsSize()) {
                    int dimension = ((ConstDef) sr).getConstExpsSize() - lval.getConstExpsSize();
                    lval.setType("array_" + dimension);
                    lval.setAddr(true);
                    if (lval.getConstExpsSize() == 0) {
                        lval.setIndex(0);
                    }
                } else {
                    value = ((ConstDef) sr).getValue(lval.getConstExps());
                    if (value instanceof Number) {
                        writeParser("<PrimaryExp>\n");
                        return value;
                    }
                }
                exps2 = ((ConstDef) sr).getConstExps();
            } else if (sr instanceof FuncFParam) {
                if (lval.getConstExpsSize() > 0) {
                    lval.setIndex(((FuncFParam) sr).getIndex(lval.getConstExps()));
                }
                if (lval.getConstExpsSize() < ((FuncFParam) sr).getConstExpsSize()) {
                    int dimension = ((FuncFParam) sr).getConstExpsSize() - lval.getConstExpsSize();
                    lval.setType("array_" + dimension);
                    lval.setAddr(true);
                    if (lval.getConstExpsSize() == 0) {
                        lval.setIndex(0);
                    }
                }
                exps2 = ((FuncFParam) sr).getConstExps();
            }
            if (lval.isVarExps()) {
                if (sr instanceof ConstDef) {
                    if (curAllocTable.searchArr(lval.getIdent())) {
                        curAllocTable.addConstArr(lval.getIdent());
                    } else if (globalAllocTable.searchArr(lval.getIdent())) {
                        globalAllocTable.addConstArr(lval.getIdent());
                    }
                }
                writeMidCode("# " + lval.getIdent() + ", " + lval.getConstExps() + "\n");
                ArrayList<PrimaryExp> exps1 = lval.getConstExps();
                PrimaryExp temp1 = null;
                int id = this.id1;
                for (int i = 0; i < exps2.size() - 1; i++) {
                    if (i == 0) {
                        temp1 = binaryOp("*", exps1.get(i), exps2.get(i + 1));
                        temp1 = binaryOp("+", temp1, new Number(0));
                    } else {
                        PrimaryExp temp2 = binaryOp("*", exps1.get(i), exps2.get(i + 1));
                        temp1 = binaryOp("+", temp1, temp2);
                    }
                }
                if (exps1.size() == exps2.size()) {
                    if (temp1 == null) {
                        temp1 = new Number(0);
                    }
                    temp1 = binaryOp("+", temp1, exps1.get(exps1.size() - 1));
                }
                temp1 = binaryOp("*", temp1, new Number(4));
                String newIdent = "%" + (id2++);
                if (lval.isAddr()) {
                    writeMidCode("la " + newIdent + "@0 " + lval.toString() + " " + temp1 + "\n");
                } else {
                    writeMidCode("lw " + newIdent + "@0 " + lval.toString() + " " + temp1 + "\n");
                }
                lval.setIdent(newIdent);
                lval.setLev(0);
                this.id1 = id;
            }
            writeParser("<PrimaryExp>\n");
            return lval;
        } else if (word.getCategoryCode().equals("INTCON")) {
            primaryExp = _number();
        }
        writeParser("<PrimaryExp>\n");
        return primaryExp;
    }

    private Number _number() throws IOException {
        Number number = new Number();
        if (word.getCategoryCode().equals("INTCON")) {  //_intConst
            number.setNum(Integer.parseInt(word.getName()));
            getWord();
        }
        writeParser("<Number>\n");
        return number;
    }

    private void _intConst() throws IOException {
        if (word.getCategoryCode().equals("INTCON")) {
            getWord();
        }
        writeParser("<IntConst>\n");
    }

    private void _unaryOp() throws IOException {
        if (word.getCategoryCode().equals("PLUS") ||
                word.getCategoryCode().equals("MINU") ||
                word.getCategoryCode().equals("NOT")) {
            getWord();
        }
        writeParser("<UnaryOp>\n");    // 叶结点
    }

    private void _mainFuncDef() throws IOException {
        FuncDef mainFuncDef = new FuncDef();
        mainFuncDef.setLev(lev);
        curTable.addSymbolRow(mainFuncDef);
        if (word.getCategoryCode().equals("INTTK")) {
            mainFuncDef.setType("int");
            isReturn = true;
            getWord();
            if (word.getCategoryCode().equals("MAINTK")) {
                mainFuncDef.setIdent(word.getName());
                curAllocTable.setFuncName(word.getName() + "@" + lev);
                getWord();
                if (word.getCategoryCode().equals("LPARENT")) {
                    changeChildTable();
                    getWord();
                    if (word.getCategoryCode().equals("RPARENT")) {
                        getWord();
                    } else {
                        writeError(lineIJK, "j");
                    }
                    writeMidCode(mainFuncDef.toString());
                    _block(0, this.indexCond, 0, this.indexLoop);
                    checkF(lineF);
                    checkG(lineG);
                    changeParentTable();
                }
            }
        }
        writeParser("<MainFuncDef>\n");
    }

    private void _funcDef() throws IOException {
        FuncDef funcDef = new FuncDef();
        funcDef.setLev(lev);
        curTable.addSymbolRow(funcDef);
        _funcType(funcDef);
        if (word.getCategoryCode().equals("IDENFR")) {
            funcDef.setIdent(word.getName());
            checkB(word.getName(), word.getLine());
            curAllocTable.setFuncName(word.getName() + "@" + lev);
            getWord();
            if (word.getCategoryCode().equals("LPARENT")) {
                changeChildTable();
                getWord();
                if (word.getCategoryCode().equals("INTTK")) {
                    _funcFParams(funcDef);
                }
                if (word.getCategoryCode().equals("RPARENT")) {
                    getWord();
                } else {
                    writeError(lineIJK, "j");
                }
                writeMidCode(funcDef.toString());
                _block(0, this.indexCond, 0, this.indexLoop);
                checkF(lineF);
                checkG(lineG);
                changeParentTable();
                funcDef.setParamsLev(lev);
            }
        }
        for (FuncFParam funcFParam : funcDef.getFuncFParams()) {
            curTable.addSymbolRow(funcFParam);
        }
        writeParser("<FuncDef>\n");
    }

    private void _funcType(FuncDef funcDef) throws IOException {
        if (word.getCategoryCode().equals("VOIDTK") ||
                word.getCategoryCode().equals("INTTK")) {
            funcDef.setType(word.getName());
            isReturn = !word.getCategoryCode().equals("VOIDTK");
            getWord();
        }
        writeParser("<FuncType>\n");
    }

    private void _funcFParams(FuncDef funcDef) throws IOException {
        funcDef.addFuncFParam(_funcFParam());
        while (word.getCategoryCode().equals("COMMA")) {
            getWord();
            funcDef.addFuncFParam(_funcFParam());
        }
        writeParser("<FuncFParams>\n");
    }

    private FuncFParam _funcFParam() throws IOException {
        FuncFParam funcFParam = new FuncFParam();
        funcFParam.setLev(lev);
        curTable.addSymbolRow(funcFParam);
        if (word.getCategoryCode().equals("INTTK")) {
            funcFParam.setType("int");
            getWord();
            if (word.getCategoryCode().equals("IDENFR")) {
                funcFParam.setIdent(word.getName());
                checkB(word.getName(), word.getLine());
                getWord();
                if (word.getCategoryCode().equals("LBRACK")) {
                    getWord();
                    if (word.getCategoryCode().equals("RBRACK")) {
                        funcFParam.addConstExp(new Number(0));
                        getWord();
                    } else {
                        writeError(lineIJK, "k");
                    }
                    while (word.getCategoryCode().equals("LBRACK")) {
                        getWord();
                        int id1 = this.id1, id2 = this.id2;
                        funcFParam.addConstExp(_constExp());
                        this.id1 = id1;
                        this.id2 = id2;
                        if (word.getCategoryCode().equals("RBRACK")) {
                            getWord();
                        } else {
                            writeError(lineIJK, "k");
                        }
                    }
                    funcFParam.setType("array_" + funcFParam.getConstExpsSize());
                }
            }
        }
        writeParser("<FuncFParam>\n");
        return funcFParam;
    }

    private ArrayList<PrimaryExp> _funcRParams() throws IOException {
        ArrayList<PrimaryExp> results = new ArrayList<>();
        results.add(_exp());
        while (word.getCategoryCode().equals("COMMA")) {
            getWord();
            results.add(_exp());
        }
        writeParser("<FuncRParams>\n");
        return results;
    }

    private void _block(int condCount, int indexCond, int loopCount, int indexLoop) throws IOException {
        if (word.getCategoryCode().equals("LBRACE")) {
            getWord();
            while (word.getCategoryCode().equals("CONSTTK") ||
                    word.getCategoryCode().equals("INTTK") || isStmt()) {
                if (word.getCategoryCode().equals("CONSTTK")) {
                    _constDecl();
                } else if (word.getCategoryCode().equals("INTTK")) {
                    _varDecl();
                } else {
                    _stmt(condCount, indexCond, 0, loopCount, indexLoop);
                }
            }
            if (word.getCategoryCode().equals("RBRACE")) {
                lineG = word.getLine();
                getWord();
            }
        }
        writeParser("<Block>\n");
    }

    private void _stmt(int condCount, int indexCond1, int indexCond2,
                       int loopCount, int indexLoop) throws IOException {
        if (word.getCategoryCode().equals("IDENFR")) {
            if (lexer.searchEQ()) {
                int id1 = this.id1, id2 = this.id2;
                Lval lval = _lVal();
                SymbolRow sr = curTable.searchTable(lval.getIdent());
                if (sr != null) {
                    lval.setLev(sr.getLev());
                }
                checkC(sr, lineC);
                ArrayList<PrimaryExp> exps2 = null;
                if (sr instanceof VarDef) {
                    if (lval.getConstExpsSize() != 0) {
                        lval.setIndex(((VarDef) sr).getIndex(lval.getConstExps()));
                        lval.setAddr(true);
                    }
                    exps2 = ((VarDef) sr).getConstExps();
                } else if (sr instanceof ConstDef) {
                    writeError(lineH, "h");
                    /*if (lval.getConstExpsSize() != 0) {
                        lval.setIndex(((ConstDef) sr).getIndex(lval.getConstExps()));
                        lval.setAddr(true);
                    }*/
                    exps2 = ((ConstDef) sr).getConstExps();
                } else if (sr instanceof FuncFParam) {
                    if (lval.getConstExpsSize() != 0) {
                        lval.setIndex(((FuncFParam) sr).getIndex(lval.getConstExps()));
                        lval.setAddr(true);
                    }
                    exps2 = ((FuncFParam) sr).getConstExps();
                }
                if (lval.isVarExps()) {
                    writeMidCode("# " + lval.getIdent() + ", " + lval.getConstExps() + "\n");
                    ArrayList<PrimaryExp> exps1 = lval.getConstExps();
                    PrimaryExp temp1 = null;
                    for (int i = 0; i < exps2.size() - 1; i++) {
                        if (i == 0) {
                            temp1 = binaryOp("*", exps1.get(i), exps2.get(i + 1));
                            temp1 = binaryOp("+", temp1, new Number(0));
                        } else {
                            PrimaryExp temp2 = binaryOp("*", exps1.get(i), exps2.get(i + 1));
                            temp1 = binaryOp("+", temp1, temp2);
                        }
                    }
                    if (exps1.size() == exps2.size()) {
                        if (temp1 == null) {
                            temp1 = new Number(0);
                        }
                        temp1 = binaryOp("+", temp1, exps1.get(exps1.size() - 1));
                    }
                    temp1 = binaryOp("*", temp1, new Number(4));
                    String newIdent = "%" + (this.id2++);
                    writeMidCode("la " + newIdent + "@0 " + lval.toString() + " " + temp1 + "\n");
                    lval.setIdent(newIdent);
                    lval.setLev(0);
                    lval.setIndex(0);
                }
                this.id1 = id1;
                if (word.getCategoryCode().equals("ASSIGN")) {
                    PrimaryExp value;
                    getWord();
                    if (word.getCategoryCode().equals("GETINTTK")) {
                        writeMidCode(lval.toString() + " = getint()\n");
                        value = lval;
                        getWord();
                        if (word.getCategoryCode().equals("LPARENT")) {
                            getWord();
                            if (word.getCategoryCode().equals("RPARENT")) {
                                getWord();
                            } else {
                                writeError(lineIJK, "j");
                            }
                            if (word.getCategoryCode().equals("SEMICN")) {  // Lval = getint();
                                getWord();
                            } else {
                                writeError(lineIJK, "i");
                            }
                        }
                    } else {    // Lval = Exp;
                        value = _exp();
                        writeMidCode(lval.toString() + " = " + value.toString() + "\n");
                        if (word.getCategoryCode().equals("SEMICN")) {
                            getWord();
                        } else {
                            writeError(lineIJK, "i");
                        }
                    }
                    if (sr instanceof VarDef) { // 将值放进所查找到的symbolRow
                        if (lval.isVarExps() || isCond || isLoop) {
                            ((VarDef) sr).setNullValue();
                        } else {
                            ((VarDef) sr).setValue(lval.getConstExps(), value);
                        }
                    }
                }
                this.id1 = id1;
                this.id2 = id2;
            } else {    // Exp;
                int id1 = this.id1, id2 = this.id2;
                _exp();
                this.id1 = id1;
                this.id2 = id2;
                if (word.getCategoryCode().equals("SEMICN")) {
                    getWord();
                } else {
                    writeError(lineIJK, "i");
                }
            }
        } else if (isExp()) {   // Exp;
            int id1 = this.id1, id2 = this.id2;
            _exp();
            this.id1 = id1;
            this.id2 = id2;
            // writeMidCode(exp.toString() + "\n");
            if (word.getCategoryCode().equals("SEMICN")) {
                getWord();
            } else {
                writeError(lineIJK, "i");
            }
        } else if (word.getCategoryCode().equals("LBRACE")) {   // Block
            changeChildTable();
            _block(condCount, indexCond1, loopCount, indexLoop);
            changeParentTable();
        } else if (word.getCategoryCode().equals("SEMICN")) {   //;
            getWord();
        } else if (word.getCategoryCode().equals("IFTK")) {
            int tempIndexCond1 = indexCond1;
            condCount++;
            if (indexCond2 == 0) {
                tempIndexCond1 = ++this.indexCond;
            }
            getWord();
            if (word.getCategoryCode().equals("LPARENT")) {
                getWord();
                isCond = false;
                _cond(tempIndexCond1, indexCond2);
                writeMidCode("if_" + tempIndexCond1 + "_" + indexCond2 + ":\n");
                isCond = true;
                if (word.getCategoryCode().equals("RPARENT")) {
                    getWord();
                } else {
                    writeError(lineIJK, "j");
                }
                _stmt(condCount, tempIndexCond1, indexCond2, loopCount, indexLoop);
                writeMidCode("jump j if_" + tempIndexCond1 + "_end" + "\n");
                writeMidCode("if_" + tempIndexCond1 + "_" + (indexCond2 + 1) + ":\n");
                if (word.getCategoryCode().equals("ELSETK")) {
                    getWord();
                    _stmt(condCount, tempIndexCond1, indexCond2 + 2, loopCount, indexLoop);
                }
                if (indexCond2 == 0) {
                    writeMidCode("if_" + tempIndexCond1 + "_end" + ":\n");
                }
            }
            condCount--;
            if (condCount == 0) {
                isCond = false;
            }
        } else if (word.getCategoryCode().equals("WHILETK")) {
            int tempIndexLoop = ++this.indexLoop;
            loopCount++;
            getWord();
            if (word.getCategoryCode().equals("LPARENT")) {
                isLoop = true;
                writeMidCode("while_" + tempIndexLoop + ":\n");
                getWord();
                _cond(tempIndexLoop, -1);
                writeMidCode("while_" + tempIndexLoop + "_start:\n");
                if (word.getCategoryCode().equals("RPARENT")) {
                    getWord();
                } else {
                    writeError(lineIJK, "j");
                }
                _stmt(condCount, indexCond1, indexCond2, loopCount, tempIndexLoop);
                writeMidCode("jump j while_" + tempIndexLoop + "\n");
                writeMidCode("while_" + tempIndexLoop + "_end" + ":\n");
            }
            loopCount--;
            if (loopCount == 0) {
                isLoop = false;
            }
        } else if (word.getCategoryCode().equals("BREAKTK")) {
            checkM(word.getLine());
            writeMidCode("jump j while_" + indexLoop + "_end" + "\n");
            getWord();
            if (word.getCategoryCode().equals("SEMICN")) {
                getWord();
            } else {
                writeError(lineIJK, "i");
            }
        } else if (word.getCategoryCode().equals("CONTINUETK")) {
            checkM(word.getLine());
            writeMidCode("jump j while_" + indexLoop + "\n");
            getWord();
            if (word.getCategoryCode().equals("SEMICN")) {
                getWord();
            } else {
                writeError(lineIJK, "i");
            }
        } else if (word.getCategoryCode().equals("RETURNTK")) {
            lineF = word.getLine();
            getWord();
            if (isExp()) {
                int id1 = this.id1, id2 = this.id2;
                PrimaryExp exp = _exp();
                this.id1 = id1;
                this.id2 = id2;
                writeMidCode("ret " + exp.toString() + "\n");
                hasReturnValue = true;
            } else {
                writeMidCode("ret\n");
            }
            if (word.getCategoryCode().equals("SEMICN")) {
                getWord();
            } else {
                writeError(lineIJK, "i");
            }
        } else if (word.getCategoryCode().equals("PRINTFTK")) {
            String str = null;
            ArrayList<PrimaryExp> exps = new ArrayList<>();
            lineL = word.getLine();
            getWord();
            if (word.getCategoryCode().equals("LPARENT")) {
                getWord();
                if (word.getCategoryCode().equals("STRCON")) {
                    str = word.getName();
                    checkA(str, word.getLine());
                    ArrayList<String> strings = new ArrayList<>();
                    int count = getPrint(str, strings), i = 0;
                    getWord();
                    while (word.getCategoryCode().equals("COMMA")) {
                        getWord();
                        int id1 = this.id1, id2 = this.id2;
                        PrimaryExp exp = _exp();
                        this.id1 = id1;
                        this.id2 = id2;
                        exps.add(exp);
                        if (i < strings.size() && !strings.get(i).equals("%d")) {
                            writeMidCode("printf \"" + strings.get(i) + "\"\n");
                            i++;
                        }
                        if (i < strings.size() && strings.get(i).equals("%d")) {
                            writeMidCode("printf " + exp.toString() + "\n");
                            i++;
                        }
                    }
                    if (i < strings.size() && !strings.get(i).equals("%d")) {
                        writeMidCode("printf \"" + strings.get(i) + "\"\n");
                    }
                    if (count != exps.size()) {
                        writeError(lineL, "l");
                    }
                    if (word.getCategoryCode().equals("RPARENT")) {
                        getWord();
                    } else {
                        writeError(lineIJK, "j");
                    }
                    if (word.getCategoryCode().equals("SEMICN")) {
                        getWord();
                    } else {
                        writeError(lineIJK, "i");
                    }
                }
            }
        }
        writeParser("<Stmt>\n");
    }

    private Lval _lVal() throws IOException {
        Lval lval = new Lval();
        if (word.getCategoryCode().equals("IDENFR")) {
            lval.setIdent(word.getName());
            lineC = word.getLine();
            lineH = word.getLine();
            getWord();
            while (word.getCategoryCode().equals("LBRACK")) {
                getWord();
                PrimaryExp exp = _exp();
                lval.addConstExp(exp);
                if (word.getCategoryCode().equals("RBRACK")) {
                    getWord();
                } else {
                    writeError(lineIJK, "k");
                }
            }
        }
        writeParser("<LVal>\n");
        return lval;
    }

    private void _cond(int index1, int index2) throws IOException {
        int id1 = this.id1, id2 = this.id2;
        _lOrExp(index1, index2);
        this.id1 = id1;
        this.id2 = id2;
        writeParser("<Cond>\n");
    }

    private void _lOrExp(int index1, int index2) throws IOException {
        int count = 0;
        String jumpEnd;
        if (index2 == -1) {
            jumpEnd = "while_" + index1 + "_end";
        } else {
            jumpEnd = "if_" + index1 + "_" + (index2 + 1);
        }
        _lAndExp(index1, index2, count);
        count++;
        writeParser("<LOrExp>\n");
        while (word.getCategoryCode().equals("OR")) {
            getWord();
            _lAndExp(index1, index2, count);
            count++;
            writeParser("<LOrExp>\n");
        }
        writeMidCode("jump j " + jumpEnd + "\n");
    }

    private void _lAndExp(int index1, int index2, int index3) throws IOException {
        int count = 0;
        String jump, jumpStart;
        if (index2 == -1) {
            jump = "cond_while_" + index1 + "_" + index3;
            jumpStart = "while_" + index1 + "_start";
        } else {
            jump = "cond_if_" + index1 + "_" + index2 + "_" + index3;
            jumpStart = "if_" + index1 + "_" + index2;
        }
        PrimaryExp lAndExp1 = _eqExp();
        count++;
        writeParser("<LAndExp>\n");
        PrimaryExp tempExp = lAndExp1;
        while (word.getCategoryCode().equals("AND")) {
            writeMidCode("cmp " + tempExp + " 0 beq " + jump + "\n");
            getWord();
            PrimaryExp lAndExp2 = _eqExp();
            count++;
            tempExp = lAndExp2;
            writeParser("<LAndExp>\n");
        }
        writeMidCode("cmp " + tempExp + " 0 bne " + jumpStart + "\n");
        if (count > 1) {
            writeMidCode(jump + ":\n");
        }
    }

    private PrimaryExp _eqExp() throws IOException {
        PrimaryExp eqExp1 = _relExp();
        writeParser("<EqExp>\n");
        while (word.getCategoryCode().equals("EQL") ||
                word.getCategoryCode().equals("NEQ")) {
            String op = word.getName();
            getWord();
            PrimaryExp eqExp2 = _relExp();
            eqExp1 = binaryOp(op, eqExp1, eqExp2);
            writeParser("<EqExp>\n");
        }
        return eqExp1;
    }

    private PrimaryExp _relExp() throws IOException {
        PrimaryExp relExp1 = _addExp();
        writeParser("<RelExp>\n");
        while (word.getCategoryCode().equals("LSS") ||
                word.getCategoryCode().equals("GRE") ||
                word.getCategoryCode().equals("LEQ") ||
                word.getCategoryCode().equals("GEQ")) {
            String op = word.getName();
            getWord();
            PrimaryExp relExp2 = _addExp();
            relExp1 = binaryOp(op, relExp1, relExp2);
            writeParser("<RelExp>\n");
        }
        return relExp1;
    }

    private void _formatString() throws IOException {
        if (word.getCategoryCode().equals("STRCON")) {
            getWord();
        }
        writeParser("<FormatString>\n");
    }

    private boolean isExp() {
        return word.getCategoryCode().equals("LPARENT") ||
                word.getCategoryCode().equals("IDENFR") ||
                word.getCategoryCode().equals("INTCON") ||
                word.getCategoryCode().equals("PLUS") ||
                word.getCategoryCode().equals("MINU") ||
                word.getCategoryCode().equals("NOT");
    }

    private boolean isStmt() {
        return isExp() || word.getCategoryCode().equals("LBRACE") ||
                word.getCategoryCode().equals("SEMICN") ||
                word.getCategoryCode().equals("IFTK") ||
                word.getCategoryCode().equals("WHILETK") ||
                word.getCategoryCode().equals("BREAKTK") ||
                word.getCategoryCode().equals("CONTINUETK") ||
                word.getCategoryCode().equals("RETURNTK") ||
                word.getCategoryCode().equals("PRINTFTK");
    }

    private PrimaryExp unaryOp(String op, int num) {
        switch (op) {
            case "+":
                return new Number(num);
            case "-":
                return new Number(-num);
            case "!":
                return new Number(num == 0 ? 1 : 0);
            default:
                return new Number(0);
        }
    }

    private PrimaryExp unaryOp(String op, Lval var) throws IOException {
        if (op.equals("+")) {
            return var;
        }
        Lval lval;
        if (var.getRegId() != -1) {
            lval = var;
        } else {
            lval = new Lval();
            lval.setRegId(id1++);
            lval.setLev(0);
        }
        writeMidCode(lval + " = " + op + " " + var.toString() + "\n");
        return lval;
    }

    private PrimaryExp binaryOp(String op, PrimaryExp exp1, PrimaryExp exp2) throws IOException {
        if (exp1 instanceof Number && exp2 instanceof Number) {
            return binaryOp(op, ((Number) exp1).getNum(), ((Number) exp2).getNum());
        } else {
            Lval lval;
            if (exp1 instanceof Lval) {
                if (((Lval) exp1).getRegId() != -1) {
                    lval = (Lval) exp1;
                } else {
                    lval = new Lval();
                    lval.setRegId(id1++);
                    lval.setLev(0);
                }
            } else {
                lval = new Lval();
                lval.setRegId(id1++);
                lval.setLev(0);
            }
            writeMidCode(lval.toString() + " = ");
            writeMidCode(exp1 + " " + op + " " + exp2 + "\n");
            // freeReg((Lval) var2);
            return lval;
        }
    }

    private PrimaryExp binaryOp(String op, int num1, int num2) {
        switch (op) {
            case "+":
                return new Number(num1 + num2);
            case "-":
                return new Number(num1 - num2);
            case "*":
                return new Number(num1 * num2);
            case "/":
                return new Number(num1 / num2);
            case "%":
                return new Number(num1 % num2);
            case "<":
                return new Number(num1 < num2 ? 1 : 0);
            case ">":
                return new Number(num1 > num2 ? 1 : 0);
            case "<=":
                return new Number(num1 <= num2 ? 1 : 0);
            case ">=":
                return new Number(num1 >= num2 ? 1 : 0);
            case "==":
                return new Number(num1 == num2 ? 1 : 0);
            case "!=":
                return new Number(num1 != num2 ? 1 : 0);
            default:
                System.out.println("cal error");
                return new Number(0);
        }
    }

    private void changeChildTable() {
        SymbolTable childTable = new SymbolTable();
        curTable.addChildTable(childTable);
        childTable.setParentTable(curTable);
        curTable = childTable;
        lev++;
    }

    private void changeParentTable() {
        curTable = curTable.getParentTable();
        lev--;
    }

    private int getPrint(String str, ArrayList<String> strings) {
        String s = str.substring(1, str.length() - 1);
        StringBuilder string = new StringBuilder();
        int count = 0;
        for (int i = 0; i < s.length(); ) {
            if (s.charAt(i) == '%') {
                if (string.length() > 0) {
                    strings.add(string.toString());
                    this.strings.add(string.toString());
                    string = new StringBuilder();
                }
                i++;
                if (i < s.length() && s.charAt(i) == 'd') {
                    strings.add("%d");
                    count++;
                    i++;
                }
            } else {
                string.append(s.charAt(i));
                i++;
            }
        }
        if (string.length() > 0) {
            strings.add(string.toString());
            this.strings.add(string.toString());
        }
        return count;
    }

    private String writeCall(String ident, ArrayList<PrimaryExp> params, Lval lval) {
        StringBuilder sb = new StringBuilder();
        sb.append("call " + ident);
        for (int i = 0; i < params.size(); i++) {
            sb.append(" " + params.get(i).toString());
        }
        sb.append("\n");
        if (lval != null) {
            sb.append("RET " + lval.toString() + "\n");
        }
        return sb.toString();
    }

    private void checkA(String str, int line) throws IOException {
        String string = str.substring(1, str.length() - 1);
        for (int i = 0; i < string.length(); i++) {
            int ascii = string.charAt(i);
            if (ascii == 37) {
                if (i + 1 >= string.length() || string.charAt(i + 1) != 100) {
                    writeError(line, "a");
                    break;
                }
            } else if (ascii == 92) {
                if (i + 1 >= string.length() || string.charAt(i + 1) != 110) {
                    writeError(line, "a");
                    break;
                }
            } else if (!(ascii == 32 || ascii == 33 || (ascii >= 40 && ascii <= 126))) {
                writeError(line, "a");
                break;
            }
        }
    }

    private void checkB(String name, int line) throws IOException {
        if (curTable.checkB(name)) {
            writeError(line, "b");
        }
    }

    private void checkC(SymbolRow sr, int line) throws IOException {
        if (sr == null) {
            writeError(line, "c");
        }
    }

    private void checkDE(FuncDef funcDef, ArrayList<PrimaryExp> rParams, int line) throws IOException {
        ArrayList<FuncFParam> fParams = funcDef.getFuncFParams();
        if (fParams.size() != rParams.size()) {
            writeError(line, "d");
            return;
        }
        for (int i = 0; i < fParams.size(); i++) {
            if (!fParams.get(i).getType().equals(rParams.get(i).getType())) {
                writeError(line, "e");
                return;
            }
        }
    }

    private void checkF(int line) throws IOException {
        if (!isReturn && hasReturnValue) {
            writeError(line, "f");
        }
    }

    private void checkG(int line) throws IOException {
        if (isReturn && !hasReturnValue) {
            writeError(line, "g");
        }
    }

    private void checkM(int line) throws IOException {
        if (!isLoop) {
            writeError(line, "m");
        }
    }

    private void getWord() throws IOException {
        writeLexer(word);
        lineIJK = word.getLine();
        word = lexer.getWord();
    }

    private void writeLexer(Word word) throws IOException {
        if (word != null) {
            Switch.lexerWrite(word);
            Switch.parserWrite(word.toString());
        }
    }

    private void writeParser(String word) throws IOException {
        Switch.parserWrite(word);
    }

    private void writeMidCode(String str) throws IOException {
        Switch.midCodeWrite(str);
        // System.out.print(str);
    }

    private void writeError(int line, String categoryCode) throws IOException {
        Switch.errorWrite(line + " " + categoryCode + "\n");
    }
}
