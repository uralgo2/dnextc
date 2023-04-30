module ast.node;

import std.algorithm : map;
import std.array : replicate;
import std.string : join;
import std.format;

enum NodeType {
    Program,

    Statement,
    ReturnStatement,
    ExpressionStatement,
    ImportStatement,
    ExportStatement,
    UseStatement,
    AliasStatement,
    ForStatement,
    WhileStatement,
    ForInStatement,
    BranchStatement,

    IfBranch,
    ElseIfBranch,
    ElseBranch,

    Expression,
    BinaryExpression,
    AssigmentExpression,
    CallExpression,
    AnonymousFunctionExpression,

    StringLiteralExpression,
    IntegerLiteralExpression,
    FloatLiteralExpression,
    IdExpression,

    DotExpression,
    ArrayLiteralExpression,
    StructLiteralExpression,

    Declaration,
    FunctionDeclaration,
    ClassDeclaration,
    StructDeclaration,

    DecoratedDeclaration,

    Decorator,

}

private string PAD = "++";

class Node {
    protected NodeType m_type;
    protected string m_name;
    protected Node[] m_children;

    public this(NodeType type, string name, Node[] children) {
        this.m_type = type;
        this.m_name = name;
        this.m_children = children;
    }

    public bool isNode(NodeType type) {
        return this.m_type == type;
    }

    public Node[] children() {
        return this.m_children;
    }

    public NodeType type() {
        return this.m_type;
    }

    public string name() {
        return this.m_name;
    }

    public override string toString() const @safe {
        return this.toString(1);
    }

    public string toString(int depth) const @safe {
        auto padding = replicate(PAD, depth);
        auto body = this.m_children.map!(
            (child) => "\n" ~ padding ~ child.toString(depth + 1)).join();

        return format("%s(%s)%s", this.m_name, this.m_type, body);
    }
}
