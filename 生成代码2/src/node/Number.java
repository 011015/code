package node;

public class Number implements PrimaryExp {
    private String type = "int";
    private int num;

    public Number() {

    }

    public Number(int num) {
        this.num = num;
    }

    public int getNum() {
        return num;
    }

    public void setNum(int num) {
        this.num = num;
    }

    public int mul(PrimaryExp num) {
        if (num instanceof Number) {
            return this.num * ((Number) num).getNum();
        } else {
            System.out.println("Number error");
            return 0;
        }
    }

    @Override
    public String toString() {
        return String.valueOf(num);
    }

    @Override
    public String getType() {
        return type;
    }

    @Override
    public void setType(String type) {
        this.type = type;
    }
}
