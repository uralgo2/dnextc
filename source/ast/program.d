module ast.program;

import ast;

class Program : Node {
    public this(Node[] children){
        super(NodeType.Program, "Program", children);
    }
}