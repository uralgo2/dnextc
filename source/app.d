import std.stdio;
import lexer;
import ast;

string[] operators = [
	"++", "+", "-", "--",
	"**", "*", "/", "%",
	"%%", "~", "!", "^",
	"&", "|", "||", "&&",
	"==", "=", ">=", "<=",
	">", "<", "+=", "-=",
	"**=", "*=", "/=", "%=",
	"%%=", "&=", "^=", "|=",
	"||=", "&&=", "."
];

string[] specials = [
	"[", "]", "{", "}",
	"(", ")", ":", ";",
	"=>", "->"
];

void parseArgs(string[] args) {
	auto input = "";

	for (uint i = 0; i < args.length; ++i) {
		input ~= args[i] ~ (i == args.length - 1 ? "" : " ");
	}

	Lexer lexer = new Lexer(input, operators, specials);

	auto token = lexer.nextToken();
	while (!token.isToken(TokenType.EndOfFile)) {
		writeln(token);
		token = lexer.nextToken();
	}
}

void main(string[] args) {

	BinaryExpression binExpr = new BinaryExpression(new IntegerLiteralExpression(0),
		Token(TokenPosition(0, 0, "source/app.d"), TokenType.Operator, "**"),
		new FloatLiteralExpression(1000)
	);

	Statement statement1 = new ExpressionStatement(binExpr);
	Statement statement2 = statement1;

	Program program = new Program([statement1, statement2]);

	writeln(program);

	while (true) {
		auto input = readln();

		Lexer lexer = new Lexer(input, operators, specials);

		auto token = lexer.nextToken();
		while (!token.isToken(TokenType.EndOfFile)) {
			write(token);
			
			if(token.isToken(TokenType.Integer)){
				writeln(" = ", token.value!long);
			}
			else if(token.isToken(TokenType.Float)){
				writeln(" = ", token.value!double);
			}
			else {
				writeln();
			}

			token = lexer.nextToken();
		}
	}
}
