import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

public class Switch {
    private static boolean lexer = false;
    private static boolean parser = false;
    private static boolean error = false;
    private static boolean midCode = false;
    private static boolean mips = false;
    public static BufferedWriter bw1;
    public static BufferedWriter bw2;
    public static BufferedWriter bw3;
    public static BufferedWriter bw4;
    public static BufferedWriter bw5;

    public static void openLexer() throws IOException {
        lexer = true;
        bw1 = new BufferedWriter(new FileWriter("output.txt"));
    }

    public static void openParser() throws IOException {
        parser = true;
        bw2 = new BufferedWriter(new FileWriter("output.txt"));
    }

    public static void openError() throws IOException {
        error = true;
        bw3 = new BufferedWriter(new FileWriter("error.txt"));
    }

    public static void openMidCode() throws IOException {
        midCode = true;
        bw4 = new BufferedWriter(new FileWriter("midCode.txt"));
    }

    public static void openMips() throws IOException {
        mips = true;
        bw5 = new BufferedWriter(new FileWriter("mips.txt"));
    }

    public static void lexerWrite(Word word) throws IOException {
        if (lexer) {
            bw1.write(word.toString());
        }
    }

    public static void parserWrite(String word) throws IOException {
        if (parser) {
            bw2.write(word);  // write to file
        }
    }

    public static void errorWrite(String str) throws IOException {
        if (error) {
            bw3.write(str);
        }
    }

    public static void midCodeWrite(String str) throws IOException {
        if (midCode) {
            bw4.write(str);
        }
    }

    public static void mipsWrite(String str) throws IOException {
        if (mips) {
            bw5.write(str);
        }
    }

    public static void closeLexer() throws IOException {
        lexer = false;
        bw1.close();
    }

    public static void closeParser() throws IOException {
        parser = false;
        bw2.close();
    }

    public static void closeError() throws IOException {
        error = false;
        bw3.close();
    }

    public static void closeMidCode() throws IOException {
        midCode = false;
        bw4.close();
    }

    public static void closeMips() throws IOException {
        mips = false;
        bw5.close();
    }
}
