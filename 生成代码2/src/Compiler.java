import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

public class Compiler {
    public static void main(String[] args) throws IOException {
        String input1 = getInput("testfile.txt");
        // System.out.println(input);
        Lexer lexer = new Lexer(input1);
        Parser parser = new Parser(lexer);

        String input2 = getInput("midCode.txt");
        GenMips genMips = new GenMips(input2, parser.getAllocTables(), parser.getStrings());
    }

    public static String getInput(String fileName) throws IOException {
        File f = new File(fileName);
        FileInputStream fis = new FileInputStream(f);
        Long length = f.length();
        byte[] content = new byte[length.intValue()];
        fis.read(content);
        fis.close();
        String input = new String(content);
        return input;
    }
}
