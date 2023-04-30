module ast.expression;

import ast;
import lexer.token;

class Expression : Node {
    public this(NodeType type, string name, Node[] children){
        super(type, name ~ "Expression", children);
    }
}

class BinaryExpression : Expression {
    protected Expression m_leftHandExpression, m_rightHandExpression;
    protected Token m_operator;

    public this(Expression lhs, Token operator, Expression rhs){
        super(NodeType.BinaryExpression, "Binary", [lhs, rhs]);

        this.m_leftHandExpression = lhs;
        this.m_rightHandExpression = rhs;
        this.m_operator = operator;
    }
}

class IntegerLiteralExpression : Expression {
    protected long m_value;

    public this(long value){
        super(NodeType.IntegerLiteralExpression, "IntegerLiteral", []);

        this.m_value = value;
    }

    public auto value(){
        return this.m_value;
    }
}

class FloatLiteralExpression : Expression {
    protected double m_value;

    public this(double value){
        super(NodeType.FloatLiteralExpression, "FloatLiteral", []);

        this.m_value = value;
    }

    public auto value(){
        return this.m_value;
    }
}
