module ast.statement;

import ast;

class Statement : Node {
    public this(NodeType type, string name, Node[] children){
        super(type, name ~ "Statement", children);
    }
}

class ExpressionStatement : Statement {
    protected Expression m_expression;


    public this(Expression expr){
        super(NodeType.ExpressionStatement, "Expression", [expr]);

        this.m_expression = expr;
    }
}