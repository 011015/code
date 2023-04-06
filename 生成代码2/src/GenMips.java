import node.AllocTable;
import node.Number;

import java.io.IOException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class GenMips {
    private final String input;
    private final ArrayList<AllocTable> arrTables;
    private HashMap<String, String> gloArrTable = new HashMap<>();
    private final HashSet<String> strings;
    private final HashMap<String, String> searchStr = new HashMap<>();  // <string, strName>
    private final HashMap<String, HashMap<String, String>> searchArr = new HashMap<>(); //<funcIdent, <arrIdent, arrName>>
    private final HashMap<String, String> searchFunc = new HashMap<>(); // <funcIdent, funcName>
    private final HashMap<String, String> useIdRegs = new HashMap<>();    // <id, regName>
    private HashMap<String, String> arrTable = new HashMap<>();   // <id, regName>
    private final HashMap<String, Boolean> freeRegs = new HashMap<>();    // <regName, use>
    private final HashMap<String, Integer> pushStack = new HashMap<>();  // <id,stack_index>
    private final String REGEX = "(([0-9a-zA-z_\\$\\%]+)@([0-9]+))((&|~)(.*))?";
    private int useRegCount = 0;
    private int regTotal;
    private int curStack = 0;
    private int indexStr = 0;
    private int indexArr = 0;

    public GenMips(String input, ArrayList<AllocTable> allocTables, HashSet<String> strings) throws IOException {
        this.input = input;
        this.arrTables = allocTables;
        this.strings = strings;
        initReg();
        Switch.openMips();
        generate();
        Switch.closeMips();
    }

    public void initReg() {
        for (int i = 0; i <= 9; i++) {  // t:0~9
            freeRegs.put("$t" + i, false);
        }
        for (int i = 0; i <= 7; i++) {  // s:0~7
            freeRegs.put("$s" + i, false);
        }
        regTotal = freeRegs.size();
        useRegCount = 0;
    }

    private String getNewReg() {
        for (Map.Entry<String, Boolean> entry : freeRegs.entrySet()) {
            if (!entry.getValue()) {
                entry.setValue(true);
                useRegCount++;
                return entry.getKey();
            }
        }
        // System.out.println("reg overflow");
        return "error";
    }

    private boolean regIsFull() {
        if (regTotal <= useRegCount) {
            // System.out.println("reg:" + regTotal + ",use:" + useRegCount);
            return true;
        }
        // System.out.println("reg:" + regTotal + ",use:" + useRegCount);
        return false;
    }

    private void freeReg(String regName) {
        freeRegs.put(regName, false);
        useRegCount--;
    }

    public void generate() throws IOException {
        dealData();
        dealText();
    }

    public void dealData() throws IOException {
        writeMips(".data\n");
        for (AllocTable allocTable : arrTables) {
            HashMap<String, String> arrTable = new HashMap<>();
            for (Map.Entry<String, Integer> stat : allocTable.getAllocSpaces().entrySet()) {
                if (allocTable.isConstArr(stat.getKey())) {
                    continue;
                }
                String ident = stat.getKey();
                writeMips("# " + ident + "\n");
                String arrName = "arr_" + indexArr;
                writeMips(arrName + ": .space " + stat.getValue() + "\n");
                arrTable.put(ident, arrName);
                indexArr++;
            }
            if (allocTable.getFuncName().equals("@global")) {
                gloArrTable = arrTable;
            } else {
                searchArr.put(allocTable.getFuncName(), arrTable);
            }
        }
        for (String str : strings) {
            String strName = "str_" + indexStr;
            writeMips(strName + ": .asciiz \"" + str + "\"\n");
            searchStr.put(str, strName);
            indexStr++;
        }
    }

    public void dealText() throws IOException {
        writeMips(".text\n");
        String[] funcs = input.split("return\n");
        for (int i = 0; i < funcs.length; i++) {
            dealFunc(funcs[i]);
            if (i == 0) {
                writeMips("jal func_main_0\n");
                syscall(10);
            }
        }
    }

    public void dealFunc(String input) throws IOException {
        String[] inputs = input.split("\n");
        int paraIndex = 0;
        for (String stat : inputs) {
            System.out.print("# " + stat + "\n");
            writeMips("# " + stat + "\n");
            String[] in = stat.split(" ");
            if (Pattern.matches(".+@\\d+.*getint\\(\\)$", stat)) {
                dealGetInt(in);
            } else if (Pattern.matches(".+@\\d+.*=.*", stat)) {
                dealAssign(in);
            } else if (Pattern.matches("^lw(.*)", stat)) {
                dealLw(in);
            } else if (Pattern.matches("^la(.*)", stat)) {
                dealLa(in);
            } else if (Pattern.matches("^printf(.*)", stat)) {
                dealPrintf(stat);
            } else if (Pattern.matches("^decl(.*)", stat)) {
                dealDecl(in);
            } else if (Pattern.matches("^proc(.*)", stat)) {
                dealProc(in);
            } else if (Pattern.matches("^para(.*)", stat)) {
                dealPara(in, paraIndex);
                paraIndex++;
            } else if (Pattern.matches("^call(.*)", stat)) {
                dealCall(in);
            } else if (Pattern.matches("^ret(.*)", stat)) {
                dealRet(in);
            } else if (Pattern.matches("^RET(.*)", stat)) {
                dealRET(in);
            } else if (Pattern.matches("^cmp(.*)", stat)) {
                dealCmp(in);
            } else if (Pattern.matches("^jump(.*)", stat)) {
                dealJump(in);
            } else if (Pattern.matches("(.*):$", stat)) {
                dealLabel(in);
            } else {
                System.out.println("error:" + stat);
            }
        }
        /*System.out.println("-----");
        for (Map.Entry<String, String> entry : useIdRegs.entrySet()) {
            System.out.println(entry.getKey() + "," + entry.getValue());
        }*/
        useIdRegs.clear();
        // System.out.println("regcount:" + useRegCount);
        initReg();
        pushStack.clear();
        curStack = 0;
    }

    public void syscall(int op) throws IOException {
        writeMips("li $v0, " + op + "\n");
        writeMips("syscall\n");
    }

    public void dealGetInt(String[] in) throws IOException {    // <ident@lev(&~)index = getint()> save
        syscall(5);
        String reg, arrName;
        int stackIndex;
        if ((stackIndex = searchDecStack(in[0])) != 0) {
            if (in[0].contains("&")) {
                int index = getIndex(in[0]);
                reg = "$a0";
                writeMips(lwMips(reg, stackIndex, "$sp"));
                writeMips(swMips("$v0", index * 4, reg));
            } else {
                writeMips(swMips("$v0", stackIndex, "$sp"));
            }
        } else if ((reg = searchDecReg(in[0])) != null) {  // 查找变量
            if (in[0].contains("&")) {
                int index = getIndex(in[0]);
                writeMips(swMips("$v0", index * 4, reg));
            } else {
                writeMips(moveMips(reg, "$v0"));
            }
        } else if ((arrName = searchDecArr(in[0])) != null) {   // 查找数组
            int index = getIndex(in[0]);
            reg = "$a0";
            getArrAddr(arrName, reg);
            writeMips(swMips("$v0", index * 4, reg));
        } else {
            System.out.println("getint error");
        }
    }

    public void dealAssign(String[] in) throws IOException {    // rval load, lval save
        if (in.length == 3) {   // <ident@lev~index = ident@lev~index>
            String reg2 = null;
            if (isNum(in[2])) {
                if (in[2].equals("0")) {
                    reg2 = "$0";
                } else {
                    reg2 = "$a1";
                    assignNum(reg2, in[2]);
                }
            } else {
                String arrName;
                int stackIndex;
                if ((stackIndex = searchDecStack(in[2])) != 0) {
                    reg2 = "$a1";
                    writeMips(lwMips(reg2, stackIndex, "$sp"));
                    if (in[2].contains("~")) {
                        int index = getIndex(in[2]);
                        writeMips(lwMips(reg2, index * 4, reg2));
                    }
                } else if ((reg2 = searchDecReg(in[2])) != null) {
                    if (in[2].contains("~")) {
                        int index = getIndex(in[2]);
                        writeMips(lwMips("$a1", index * 4, reg2));
                        reg2 = "$a1";
                    }
                } else if ((arrName = searchDecArr(in[2])) != null) {
                    int index = getIndex(in[2]);
                    if (index >= 0) {
                        reg2 = "$a1";
                        getArrEle(arrName, reg2, index);
                    }
                } else {
                    System.out.println("assign error0");
                }
            }
            dealLval(in[0], reg2);
        } else if (in.length == 4) {    // <ident@lev~index = op ident@lev~index>
            String reg2 = null;
            String op = in[2];
            if (isNum(in[3])) {
                reg2 = "$a1";
                writeMips(calMips(op, reg2, in[3]));
            } else {
                String arrName;
                int stackIndex;
                if ((stackIndex = searchDecStack(in[3])) != 0) {
                    reg2 = "$a1";
                    writeMips(lwMips(reg2, stackIndex, "$sp"));
                    if (in[3].contains("~")) {
                        int index = getIndex(in[3]);
                        writeMips(lwMips(reg2, index * 4, reg2));
                    }
                    writeMips(calMips(op, reg2, reg2));
                } else if ((reg2 = searchDecReg(in[3])) != null) {
                    if (in[3].contains("~")) {
                        int index = getIndex(in[3]);
                        writeMips(lwMips("$a1", index * 4, reg2));
                        reg2 = "$a1";
                    }
                    writeMips(calMips(op, "$a1", reg2));
                    reg2 = "$a1";
                } else if ((arrName = searchDecArr(in[3])) != null) {
                    int index = getIndex(in[3]);
                    if (index >= 0) {
                        reg2 = "$a1";
                        getArrEle(arrName, reg2, index);
                    }
                    writeMips(calMips(op, reg2, reg2));
                } else {
                    System.out.println("assign error1");
                }
            }
            dealLval(in[0], reg2);
        } else if (in.length == 5) {    // <ident@lev~index = ident@lev~index op ident@lev~index>
            String reg2 = null, reg3 = null;
            if (isNum(in[2])) {
                if (in[2].equals("0")) {
                    reg2 = "$0";
                } else {
                    reg2 = "$a1";
                    assignNum(reg2, in[2]);
                }
            } else {
                String arrName;
                int stackIndex;
                if ((stackIndex = searchDecStack(in[2])) != 0) {
                    reg2 = "$a1";
                    writeMips(lwMips(reg2, stackIndex, "$sp"));
                    if (in[2].contains("~")) {
                        int index = getIndex(in[2]);
                        writeMips(lwMips(reg2, index * 4, reg2));
                    }
                } else if ((reg2 = searchDecReg(in[2])) != null) {
                    if (in[2].contains("~")) {
                        int index = getIndex(in[2]);
                        writeMips(lwMips("$a1", index * 4, reg2));
                        reg2 = "$a1";
                    }
                } else if ((arrName = searchDecArr(in[2])) != null) {
                    int index = getIndex(in[2]);
                    reg2 = "$a1";
                    if (index >= 0) {
                        getArrEle(arrName, reg2, index);
                    }
                } else {
                    System.out.println("assign error2:" + in[2]);
                }
            }
            String op = in[3];

            if (isNum(in[4])) {
                writeMips(calMips(op, "$a2", reg2, in[4]));
                reg2 = "$a2";
            } else {
                String arrName;
                int stackIndex;
                if ((stackIndex = searchDecStack(in[4])) != 0) {
                    reg3 = "$a2";
                    writeMips(lwMips(reg3, stackIndex, "$sp"));
                    if (in[4].contains("~")) {
                        int index = getIndex(in[4]);
                        writeMips(lwMips(reg3, index * 4, reg3));
                    }
                    writeMips(calMips(op, "$a3", reg2, reg3));
                    reg2 = "$a3";
                } else if ((reg3 = searchDecReg(in[4])) != null) {
                    if (in[4].contains("~")) {
                        int index = getIndex(in[4]);
                        writeMips(lwMips("$a3", index * 4, reg3));
                        reg3 = "$a3";
                    }
                    writeMips(calMips(op, "$a2", reg2, reg3));
                    reg2 = "$a2";
                } else if ((arrName = searchDecArr(in[4])) != null) {
                    int index = getIndex(in[4]);
                    if (index >= 0) {
                        reg3 = "$a2";
                        getArrEle(arrName, reg3, index);
                    }
                    writeMips(calMips(op, "$a3", reg2, reg3));
                    reg2 = "$a3";
                } else {
                    System.out.println("assign error3:" + in[4]);
                }
            }
            dealLval(in[0], reg2);
        }
    }

    public void dealLw(String[] in) throws IOException {    // <lw reg:ident@lev arrName index:ident@lev>
        String reg1, reg2, reg3, arrName;
        int stackIndex;
        int index = -1;
        if ((reg1 = searchDecReg(in[1])) != null) {
        } else if ((stackIndex = searchDecStack(in[1])) != 0) {
            reg1 = "$a0";
            writeMips(lwMips(reg1, stackIndex, "$sp"));
        } else if (regIsFull()) {
            reg1 = "$a0";
            curStack -= 4;
            pushStack.put(in[1], curStack);
            index = curStack;
        } else {
            reg1 = getNewReg();
            useIdRegs.put(in[1], reg1);
        }
        if ((reg3 = searchDecReg(in[3])) != null) {
        } else if ((stackIndex = searchDecStack(in[3])) != 0) {
            reg3 = "$a1";
            writeMips(lwMips(reg3, stackIndex, "$sp"));
        } else {
            System.out.println("lw error");
        }
        if (index != -1) {
            if ((arrName = searchDecArr(in[2])) != null) {
                writeMips(lwMips(reg1, arrName, reg3));
                writeMips(swMips(reg1, index, "$sp"));
            } else if ((reg2 = searchDecReg(in[2])) != null) {
                String tempReg = "$a2";
                writeMips(calMips("+", tempReg, reg2, reg3));
                writeMips(lwMips(reg1, 0, tempReg));
                writeMips(swMips(reg1, index, "$sp"));
            }
        } else {
            if ((arrName = searchDecArr(in[2])) != null) {
                writeMips(lwMips(reg1, arrName, reg3));
            } else if ((reg2 = searchDecReg(in[2])) != null) {
                String tempReg = "$a2";
                writeMips(calMips("+", tempReg, reg2, reg3));
                writeMips(lwMips(reg1, 0, tempReg));
            } else {
                System.out.println("lw error");
            }
        }
    }

    public void dealLa(String[] in) throws IOException {    // <la reg:ident@lev arrName index:ident@lev>
        String reg1, reg2, reg3, arrName;
        int stackIndex;
        int index = -1;
        if ((reg1 = searchDecReg(in[1])) != null) {
        } else if ((stackIndex = searchDecStack(in[1])) != 0) {
            reg1 = "$a0";
            writeMips(lwMips(reg1, stackIndex, "$sp"));
        } else if (regIsFull()) {
            reg1 = "$a0";
            curStack -= 4;
            pushStack.put(in[1], curStack);
            index = curStack;
        } else {
            reg1 = getNewReg();
            useIdRegs.put(in[1], reg1);
            System.out.println("la error0");
        }
        if ((reg3 = searchDecReg(in[3])) != null) {
        } else if ((stackIndex = searchDecStack(in[3])) != 0) {
            reg3 = "$a1";
            writeMips(lwMips(reg3, stackIndex, "$sp"));
        } else {
            System.out.println("la error1");
        }
        if (index != -1) {
            if ((arrName = searchDecArr(in[2])) != null) {
                reg2 = "$a2";
                getArrAddr(arrName, reg2);
                writeMips(calMips("+", reg1, reg2, reg3));
                writeMips(swMips(reg1, index, "$sp"));
            } else if ((reg2 = searchDecReg(in[2])) != null) {
                writeMips(calMips("+", reg1, reg2, reg3));
                writeMips(swMips(reg1, index, "$sp"));
            } else {
                System.out.println("la error2");
            }
        } else {
            if ((arrName = searchDecArr(in[2])) != null) {
                reg2 = "$a2";
                getArrAddr(arrName, reg2);
                writeMips(calMips("+", reg1, reg2, reg3));
            } else if ((reg2 = searchDecReg(in[2])) != null) {
                writeMips(calMips("+", reg1, reg2, reg3));
            } else if ((stackIndex = searchDecStack(in[2])) != 0) {
                reg2 = "$a2";
                writeMips(lwMips(reg2, stackIndex, "$sp"));
                writeMips(calMips("+", reg1, reg2, reg3));
            } else {
                System.out.println("la error3");
            }
        }
    }

    public void dealLval(String in1, String reg2) throws IOException {  // <ident@lev~index> save
        String reg1, arrName;
        int stackIndex;
        if ((stackIndex = searchDecStack(in1)) != 0) {
            reg1 = "$a0";
            if (in1.contains("&")) {
                int index = getIndex(in1);
                writeMips(lwMips(reg1, stackIndex, "$sp"));
                writeMips(swMips(reg2, index * 4, reg1));
            } else {
                writeMips(swMips(reg2, stackIndex, "$sp"));
            }
        } else if ((arrName = searchDecArr(in1)) != null) {
            int index = getIndex(in1);
            reg1 = "$a0";
            getArrAddr(arrName, reg1);
            writeMips(swMips(reg2, index * 4, reg1));
        } else if ((reg1 = searchDecReg(in1)) != null) {
            if (in1.contains("&")) {
                int index = getIndex(in1);
                writeMips(swMips(reg2, index * 4, reg1));
            } else {
                writeMips(moveMips(reg1, reg2));
            }
        } else if (regIsFull()) {
            curStack -= 4;
            pushStack.put(in1, curStack);
            writeMips(swMips(reg2, curStack, "$sp"));
        } else {
            reg1 = getNewReg();
            useIdRegs.put(in1, reg1);
            writeMips(moveMips(reg1, reg2));
        }
    }

    public void dealPrintf(String stat) throws IOException {    // load
        ArrayList<String> in = new ArrayList<>();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < stat.length(); i++) {
            if (stat.charAt(i) == ' ') {
                in.add(sb.toString());
                sb = new StringBuilder();
            } else if (stat.charAt(i) == '\"') {
                int j;
                for (j = i + 1; j < stat.length() && stat.charAt(j) != '\"'; j++) {
                    sb.append(stat.charAt(j));
                }
                in.add(sb.toString());
                sb = new StringBuilder();
                i = j;
            } else {
                sb.append(stat.charAt(i));
            }
        }
        if (sb.length() > 0) {
            in.add(sb.toString());
        }
        if (searchStr.containsKey(in.get(1))) {   // <printf "123">
            writeMips("la $a0, " + searchStr.get(in.get(1)) + "\n");
            syscall(4);
        } else if (isNum(in.get(1))) {    // <printf 2>
            writeMips(addiMips("$a0", "$0", in.get(1)));
            syscall(1);
        } else {
            String reg, arrName;
            int stackIndex;
            if ((stackIndex = searchDecStack(in.get(1))) != 0) {
                reg = "$a0";
                writeMips(lwMips(reg, stackIndex, "$sp"));
                if (in.get(1).contains("~")) {
                    int index = getIndex(in.get(1));
                    writeMips(lwMips(reg, index * 4, reg));
                }
                syscall(1);
            } else if ((reg = searchDecReg(in.get(1))) != null) {
                if (in.get(1).contains("~")) {
                    int index = getIndex(in.get(1));
                    writeMips(lwMips("$a0", index * 4, reg));
                } else {
                    writeMips(moveMips("$a0", reg));
                }
                syscall(1);
            } else if ((arrName = searchDecArr(in.get(1))) != null) {
                int index = getIndex(in.get(1));
                reg = "$a0";
                getArrEle(arrName, reg, index);
                syscall(1);
            } else {
                System.out.println("printf error");
            }
        }
    }

    public void dealDecl(String[] in) throws IOException {   // <decl type ident@lev vals...> save
        if (in[1].equals("const") && (searchDecArr(in[2]) == null)) {
            return;
        }
        String reg1, reg2, arrName;
        int stackIndex;
        if (in.length == 4) {    // 赋初值
            if (isNum(in[3])) {
                if (in[3].equals("0")) {
                    reg2 = "$0";
                } else {
                    reg2 = "$a1";
                    writeMips(addiMips(reg2, "$0", in[3]));
                }
            } else if ((stackIndex = searchDecStack(in[3])) != 0) {
                reg2 = "$a1";
                writeMips(lwMips(reg2, stackIndex, "$sp"));
                if (in[3].contains("~")) {
                    int index = getIndex(in[3]);
                    writeMips(lwMips(reg2, index * 4, reg2));
                }
            } else if ((reg2 = searchDecReg(in[3])) != null) {
                if (in[3].contains("~")) {
                    int index = getIndex(in[3]);
                    writeMips(lwMips("$a1", index * 4, reg2));
                    reg2 = "$a1";
                }
            } else if ((arrName = searchDecArr(in[3])) != null) {
                int index = getIndex(in[3]);
                reg2 = "$a1";
                getArrEle(arrName, reg2, index);
            } else {
                System.out.println("decl error");
            }
            if ((arrName = searchDecArr(in[2])) != null) {
                int index = getIndex(in[2]);
                reg1 = "$a2";
                getArrAddr(arrName, reg1);
                writeMips(swMips(reg2, index * 4, reg1));
            } else {
                curStack -= 4;
                pushStack.put(in[2], curStack);
                writeMips(swMips(reg2, curStack, "$sp"));
            }
        } else if (in.length == 3) {    // 声明
            if (searchDecArr(in[2]) == null) {
                curStack -= 4;
                pushStack.put(in[2], curStack);
            }
        } else {
            System.out.println("decl error");
        }
    }

    public void dealProc(String[] in) throws IOException {  // <proc type ident@lev count>
        arrTable = searchArr.get(in[2]);
        String funcName = getFuncName(in[2]);
        writeMips(funcName + ":\n");
        searchFunc.put(in[2], funcName);
    }

    public void dealPara(String[] in, int paraIndex) throws IOException {   // <para type ident@lev val> load
        if (useRegCount > 5) {
            pushStack.put(in[3], paraIndex * 4);
        } else {
            String reg = getNewReg();
            useIdRegs.put(in[3], reg);
            writeMips(lwMips(reg, paraIndex * 4, "$sp"));
        }
    }

    public void dealCall(String[] in) throws IOException {  // <call ident@lev vals...>
        ArrayList<String> params = new ArrayList<>();
        for (int i = 2; i < in.length; i++) {
            params.add(in[i]);
        }
        HashSet<String> varReg = new HashSet<>();
        HashMap<String, Integer> parReg = new HashMap<>();
        for (Map.Entry<String, String> entry : useIdRegs.entrySet()) {
            // System.out.println("allReg:" + entry.getKey() + ", " + entry.getValue());
            if (!params.contains(entry.getKey())) {
                writeMips("# " + entry.getKey() + "\n");
                varReg.add(entry.getValue());
            }
        }
        if (curStack != 0) {    // var save stack area
            writeMips("addi $sp, $sp, " + curStack + "\n");
        }
        int regSize = varReg.size() * 4 + 4;
        writeMips("addi $sp, $sp, " + -regSize + "\n");    // save local var
        int index = 0;
        for (String r : varReg) {
            writeMips(swMips(r, index * 4, "$sp"));
            index++;
        }
        writeMips(swMips("$ra", index * 4, "$sp"));

        int paramSize = params.size() * 4;
        if (paramSize > 0) {
            writeMips("addi $sp, $sp, " + -paramSize + "\n");    // save params
        }
        index = 0;
        String reg;
        for (String param : params) {
            if (isNum(param)) {
                if (param.equals("0")) {
                    reg = "$0";
                } else {
                    reg = "$a0";
                    writeMips(addiMips(reg, "$0", param));
                }
                writeMips(swMips(reg, index * 4, "$sp"));
            } else {
                String arrName;
                int stackIndex;
                if ((stackIndex = searchDecStack(param)) != 0) {
                    reg = "$a0";
                    writeMips(lwMips(reg, stackIndex + paramSize + regSize - curStack, "$sp"));
                    if (param.contains("~")) {
                        int arrIndex = getIndex(param);
                        writeMips(lwMips("$a0", arrIndex * 4, reg));
                        reg = "$a0";
                    } else if (param.contains("&")) {
                        int arrIndex = getIndex(param);
                        writeMips(addiMips("$a0", reg, arrIndex * 4));
                        reg = "$a0";
                    }
                    writeMips(swMips(reg, index * 4, "$sp"));
                } else if ((reg = searchDecReg(param)) != null) {
                    parReg.put(reg, index * 4);
                    if (param.contains("~")) {
                        int arrIndex = getIndex(param);
                        writeMips(lwMips("$a0", arrIndex * 4, reg));
                        reg = "$a0";
                    } else if (param.contains("&")) {
                        int arrIndex = getIndex(param);
                        writeMips(addiMips("$a0", reg, arrIndex * 4));
                        reg = "$a0";
                    }
                    writeMips(swMips(reg, index * 4, "$sp"));
                } else if ((arrName = searchDecArr(param)) != null) {
                    int arrIndex = getIndex(param);
                    if (param.contains("&")) {
                        reg = "$a0";
                        getArrAddr(arrName, reg, arrIndex);
                    } else {
                        reg = "$a0";
                        getArrEle(arrName, reg, arrIndex);
                    }
                    writeMips(swMips(reg, index * 4, "$sp"));
                } else {
                    System.out.println("call error");
                }
            }
            index++;
        }

        Pattern pattern = Pattern.compile(REGEX); //ident:1,name:2,lev:3,op:5,index:6
        Matcher matcher = pattern.matcher(in[1]);
        if (matcher.find()) {
            String ident = matcher.group(1);
            if (searchFunc.containsKey(ident)) {
                writeMips("jal " + searchFunc.get(ident) + "\n");
            } else {
                System.out.println("funcName error");
            }
        } else {
            System.out.println("matcher error");
        }

        if (paramSize > 0) {
            for (Map.Entry<String, Integer> entry : parReg.entrySet()) {    // load params
                writeMips(lwMips(entry.getKey(), entry.getValue(), "$sp"));
            }
            writeMips("addi $sp, $sp, " + paramSize + "\n");
        }

        index = 0;
        for (String r : varReg) {  // load local var
            writeMips(lwMips(r, index * 4, "$sp"));
            index++;
        }
        writeMips(lwMips("$ra", index * 4, "$sp"));
        writeMips("addi $sp, $sp, " + regSize + "\n");
        if (curStack != 0) {    // var save stack area
            writeMips("addi $sp, $sp, " + -curStack + "\n");
        }
    }

    public void dealRet(String[] in) throws IOException {   // <ret ident@lev~index> load
        if (in.length == 2) {
            if (isNum(in[1])) {
                assignNum("$v1", in[1]);
            } else {
                String reg, arrName;
                int stackIndex;
                if ((stackIndex = searchDecStack(in[1])) != 0) {
                    reg = "$v1";
                    writeMips(lwMips(reg, stackIndex, "$sp"));
                    if (in[1].contains("~")) {
                        int index = getIndex(in[1]);
                        writeMips(lwMips(reg, index * 4, reg));
                    }
                } else if ((reg = searchDecReg(in[1])) != null) {
                    if (in[1].contains("~")) {
                        int index = getIndex(in[1]);
                        writeMips(lwMips("$v1", index * 4, reg));
                    } else {
                        writeMips(moveMips("$v1", reg));
                    }
                } else if ((arrName = searchDecArr(in[1])) != null) {
                    int index = getIndex(in[1]);
                    reg = "$a2";
                    getArrAddr(arrName, reg);
                    writeMips(lwMips("$v1", index * 4, reg));
                } else {
                    System.out.println("ret error");
                }
            }
        }
        writeMips("jr $ra\n");
    }

    public void dealRET(String[] in) throws IOException {  // <RET ident@lev~index> save
        String reg;
        int stackIndex;
        if ((reg = searchDecReg(in[1])) != null) {
            if (in[1].contains("&")) {
                int index = getIndex(in[1]);
                writeMips(swMips("$v1", index * 4, reg));
            } else {
                writeMips(moveMips(reg, "$v1"));
            }
        } else if ((stackIndex = searchDecStack(in[1])) != 0) {
            if (in[1].contains("&")) {
                int index = getIndex(in[1]);
                reg = "$a0";
                writeMips(lwMips(reg, stackIndex, "$sp"));
                writeMips(swMips("$v1", index * 4, reg));
            } else {
                writeMips(swMips("$v1", stackIndex, "$sp"));
            }
        } else if (regIsFull()) {
            curStack -= 4;
            pushStack.put(in[1], curStack);
            writeMips(swMips("$v1", curStack, "$sp"));
        } else {
            reg = getNewReg();
            useIdRegs.put(in[1], reg);
            writeMips(moveMips(reg, "$v1"));
        }
    }

    public void dealCmp(String[] in) throws IOException {  // <cmp ident@lev~index ident@lev~index op label>
        if (in.length == 5) {
            String reg1 = null, reg2 = null, reg3 = null;
            if (isNum(in[1])) {
                if (in[1].equals("0")) {
                    reg1 = "$0";
                } else {
                    reg1 = "$a1";
                    assignNum(reg1, in[1]);
                }
            } else {
                String arrName;
                int stackIndex;
                if ((stackIndex = searchDecStack(in[1])) != 0) {
                    reg1 = "$a1";
                    writeMips(lwMips(reg1, stackIndex, "$sp"));
                    if (in[1].contains("~")) {
                        int index = getIndex(in[1]);
                        writeMips(lwMips(reg1, index * 4, reg1));
                    }
                } else if ((reg1 = searchDecReg(in[1])) != null) {
                    if (in[1].contains("~")) {
                        int index = getIndex(in[1]);
                        writeMips(lwMips("$a1", index * 4, reg1));
                        reg1 = "$a1";
                    }
                } else if ((arrName = searchDecArr(in[1])) != null) {
                    int index = getIndex(in[1]);
                    reg1 = "$a1";
                    getArrEle(arrName, reg1, index);
                } else {
                    System.out.println("cmp error");
                }
            }
            if (isNum(in[2])) {
                if (in[2].equals("0")) {
                    reg2 = "$0";
                } else {
                    assignNum("$a2", in[2]);
                    reg2 = "$a2";
                }
            } else {
                String arrName;
                int stackIndex;
                if ((stackIndex = searchDecStack(in[2])) != 0) {
                    reg2 = "$a2";
                    writeMips(lwMips(reg2, stackIndex, "$sp"));
                    if (in[2].contains("~")) {
                        int index = getIndex(in[2]);
                        writeMips(lwMips(reg2, index * 4, reg2));
                    }
                } else if ((reg2 = searchDecReg(in[2])) != null) {
                    if (in[2].contains("~")) {
                        int index = getIndex(in[2]);
                        writeMips(lwMips("$a2", index * 4, reg2));
                        reg2 = "$a2";
                    }
                } else if ((arrName = searchDecArr(in[2])) != null) {
                    int index = getIndex(in[2]);
                    reg2 = "$a2";
                    getArrEle(arrName, reg2, index);
                } else {
                    System.out.println("cmp error");
                }
            }
            writeMips(in[3] + " " + reg1 + ", " + reg2 + ", " + in[4] + "\n");
        }
    }

    public void dealJump(String[] in) throws IOException {  // <jump op label>
        writeMips(in[1] + " " + in[2] + "\n");
    }

    public void dealLabel(String[] in) throws IOException { // <label:>
        writeMips(in[0] + "\n");
    }

    public String addiMips(String reg1, String reg2, int num) {
        return "addi " + reg1 + ", " + reg2 + ", " + num + "\n";
    }

    public String addiMips(String reg1, String reg2, String num) {
        return "addi " + reg1 + ", " + reg2 + ", " + num + "\n";
    }

    public String swMips(String reg1, int index, String reg2) {
        return "sw " + reg1 + ", " + index + "(" + reg2 + ")\n";
    }

    public String swMips(String reg1, String arrName, String reg2) {
        return "sw " + reg1 + ", " + arrName + "(" + reg2 + ")\n";
    }

    public String lwMips(String reg1, int index, String reg2) {
        return "lw " + reg1 + ", " + index + "(" + reg2 + ")\n";
    }

    public String lwMips(String reg1, String arrName, String reg2) {
        return "lw " + reg1 + ", " + arrName + "(" + reg2 + ")\n";
    }

    public String moveMips(String reg1, String reg2) {
        return "move " + reg1 + ", " + reg2 + "\n";
    }

    public void getArrAddr(String arrName, String regName) throws IOException {
        writeMips("la " + regName + ", " + arrName + "\n");
    }

    public void getArrAddr(String arrName, String regName, int index) throws IOException {
        writeMips("la " + regName + ", " + arrName + "\n");
        if (index > 0) {
            writeMips("addi " + regName + ", " + regName + ", " + index * 4 + "\n");
        }
    }

    public void getArrEle(String arrName, String regName, int index) throws IOException {
        writeMips("la " + regName + ", " + arrName + "\n");
        writeMips(lwMips(regName, index * 4, regName));
    }

    public void assignNum(String reg1, String num) throws IOException {
        String reg2 = "$0";
        writeMips(addiMips(reg1, reg2, num));
    }

    public int searchDecStack(String in) {
        Pattern pattern = Pattern.compile(REGEX); //ident:1,name:2,lev:3,op:5,index:6
        Matcher matcher = pattern.matcher(in);
        if (matcher.find()) {
            String ident = matcher.group(1);
            if (pushStack.containsKey(ident)) {
                return pushStack.get(ident);
            }
        } else {
            System.out.println("matcher error1:" + in);
        }
        return 0;
    }

    public String searchDecReg(String in) throws IOException {
        Pattern pattern = Pattern.compile(REGEX); //ident:1,name:2,lev:3,op:5,index:6
        Matcher matcher = pattern.matcher(in);
        if (matcher.find()) {
            String ident = matcher.group(1);
            if (useIdRegs.containsKey(ident)) {
                return useIdRegs.get(ident);
            }
        } else {
            System.out.println("matcher error2:" + in);
        }
        return null;
    }

    public String searchDecArr(String in) {
        Pattern pattern = Pattern.compile(REGEX); //ident:1,name:2,lev:3,op:5,index:6
        Matcher matcher = pattern.matcher(in);
        if (matcher.find()) {
            String ident = matcher.group(1);
            if (arrTable.containsKey(ident)) {
                return arrTable.get(ident);
            } else if (gloArrTable.containsKey(ident)) {
                return gloArrTable.get(ident);
            }
        }
        return null;
    }

    public String getFuncName(String in) {
        String[] ident = in.split("@");
        return "func_" + ident[0] + "_" + ident[1];
    }

    public int getIndex(String in) {    //ident@lev(~|&)index
        if (in.contains("~")) {
            String[] ident = in.split("~");
            return Integer.parseInt(ident[1]);
        } else if (in.contains("&")) {
            String[] ident = in.split("&");
            return Integer.parseInt(ident[1]);
        } else {
            return 0;
        }
    }

    public String calMips(String op, String reg1, String reg2) {
        switch (op) {
            case "-":
                return "neg " + reg1 + ", " + reg2 + "\n";
            case "!":
                return "seq " + reg1 + ", " + reg2 + ", $0" + "\n";
            default:
                return "error";
        }
    }

    public String calMips(String op, String reg1, String reg2, String reg3) {
        StringBuilder sb = new StringBuilder();
        switch (op) {
            case "+":
                return "add " + reg1 + ", " + reg2 + ", " + reg3 + "\n";
            case "-":
                return "sub " + reg1 + ", " + reg2 + ", " + reg3 + "\n";
            case "*":
                if (isNum(reg3) && exp2(reg3)) {
                    if (reg3.equals("1")) {
                        return "add " + reg1 + ", " + reg2 + ", " + "0" + "\n";
                    } else if (reg3.equals("0")) {
                        return "add " + reg1 + ", " + "$0" + ", " + "0" + "\n";
                    } else {
                        int num = getPow(reg3);
                        return "sll " + reg1 + ", " + reg2 + ", " + num + "\n";
                    }
                } else {
                    return "mul " + reg1 + ", " + reg2 + ", " + reg3 + "\n";
                }
            case "/":
                if (isNum(reg3) && exp2(reg3)) {
                    if (reg3.equals("1")) {
                        return "add " + reg1 + ", " + reg2 + ", " + "0" + "\n";
                    } else {
                        int num = getPow(reg3);
                        return "sra " + reg1 + ", " + reg2 + ", " + num + "\n";
                    }
                } else {
                    return "div " + reg1 + ", " + reg2 + ", " + reg3 + "\n";
                }
            case "%":
                sb.append("div " + reg1 + ", " + reg2 + ", " + reg3 + "\n");
                sb.append("mfhi " + reg1 + "\n");
                return sb.toString();
            case "<":
                if (isNum(reg3)) {
                    if (Integer.parseInt(reg3) > 32767) {
                        sb.append("li " + reg1 + ", " + reg3 + "\n");
                        sb.append("slt " + reg1 + ", " + reg1 + ", " + reg2 + "\n");
                        return sb.toString();
                    } else {
                        return "slti " + reg1 + ", " + reg2 + ", " + reg3 + "\n";
                    }
                } else {
                    return "slt " + reg1 + ", " + reg2 + ", " + reg3 + "\n";
                }
            case ">":
                return "sgt " + reg1 + ", " + reg2 + ", " + reg3 + "\n";
            case "<=":
                return "sle " + reg1 + ", " + reg2 + ", " + reg3 + "\n";
            case ">=":
                return "sge " + reg1 + ", " + reg2 + ", " + reg3 + "\n";
            case "==":
                return "seq " + reg1 + ", " + reg2 + ", " + reg3 + "\n";
            case "!=":
                return "sne " + reg1 + ", " + reg2 + ", " + reg3 + "\n";
            default:
                return "error";
        }
    }

    public boolean isNum(String in) {
        return in != null && in.matches("-?\\d+");
    }

    public boolean exp2(String in) {
        int num = Integer.parseInt(in);
        return (num & (num - 1)) == 0;
    }

    public int getPow(String in) {
        int num = Integer.parseInt(in);
        int count = 0;
        while (num > 1) {
            num = num / 2;
            count++;
        }
        return count;
    }

    private void writeMips(String str) throws IOException {
        Switch.mipsWrite(str);
        // System.out.print(str);
    }
}
