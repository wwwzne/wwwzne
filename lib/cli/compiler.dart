import 'dart:io';

import 'tools.dart';
import 'package:args/command_runner.dart';

///解释器
enum TokenType {
  /*提示符:非法*/ illegal,
  /*提示符:结尾*/ eof,
  /*标识符:putong */ ident,
  /*字面量:整型*/ int,
  /*字面量:字符串*/ string,
  /*运算符:=*/ assign,
  /*运算符:+*/ plus,
  /*运算符:-*/ minus,
  /*运算符:!*/ bang,
  /*运算符:**/ asterisk,
  /*运算符:÷*/ slash,
  /*运算符:<*/ lt,
  /*运算符:>*/ gt,
  /*运算符:==*/ eq,
  /*运算符:!=*/ noteq,
  /*分隔符:,*/ comma,
  /*分隔符:;*/ semicolon,
  /*分隔符:(*/ lparen,
  /*分隔符:)*/ rparen,
  /*分隔符:{*/ lbrace,
  /*分隔符:}*/ rbrace,
  /*分隔符:[*/ lbracket,
  /*分隔符:]*/ rbracket,
  /*关键字:函数*/ function,
  /*关键字:声明*/ let,
  /*关键词:true*/ tRue,
  /*关键词:false*/ fAlse,
  /*关键词:if*/ iF,
  /*关键词:else*/ eLse,
  /*关键词:return*/ rEturn,
}

typedef TokenNode = (TokenType, String);

class Lexer {
  String input;
  int position = 0;
  int readPosition = 0;
  String? get ch =>
      input.isNotEmpty && position < input.length ? input[position] : null;

  Lexer(this.input) {
    readChar();
  }
  void readChar() {
    position = readPosition++;
  }

  TokenNode nextToken() {
    skipWhitespace();
    TokenNode? token;
    switch (ch) {
      case "=":
        if (peekChar() == "=") {
          readChar();
          token = (TokenType.eq, "==");
        } else {
          token = (TokenType.assign, ch!);
        }
        break;
      case ";":
        token = (TokenType.semicolon, ch!);
        break;
      case "(":
        token = (TokenType.lparen, ch!);
        break;
      case ")":
        token = (TokenType.rparen, ch!);
        break;
      case ",":
        token = (TokenType.comma, ch!);
        break;
      case "+":
        token = (TokenType.plus, ch!);
        break;
      case "-":
        token = (TokenType.minus, ch!);
        break;
      case "!":
        if (peekChar() == "=") {
          readChar();
          token = (TokenType.noteq, "!=");
        } else {
          token = (TokenType.bang, ch!);
        }
        break;
      case "/":
        token = (TokenType.slash, ch!);
        break;
      case "*":
        token = (TokenType.asterisk, ch!);
        break;
      case "<":
        token = (TokenType.lt, ch!);
        break;
      case ">":
        token = (TokenType.gt, ch!);
        break;
      case "{":
        token = (TokenType.lbrace, ch!);
        break;
      case "}":
        token = (TokenType.rbrace, ch!);
        break;
      case "[":
        token = (TokenType.lbracket, ch!);
      case "]":
        token = (TokenType.rbracket, ch!);
      case '"':
        token = (TokenType.string, readString());
      case null:
        token = (TokenType.eof, '');
        break;
      default:
        if (Tools.isLetter(ch!)) {
          final String ii = readIdentifier();
          Map<String, TokenType> jj = {
            'fn': TokenType.function,
            'let': TokenType.let,
            'true': TokenType.tRue,
            'false': TokenType.fAlse,
            "if": TokenType.iF,
            "else": TokenType.eLse,
            "return": TokenType.rEturn,
          };
          if (jj.containsKey(ii)) {
            token = (jj[ii]!, ii);
          } else {
            token = (TokenType.ident, ii);
          }
          return token;
        } else if (Tools.isDigit(ch!)) {
          return (TokenType.int, readNumber());
        } else {
          token = (TokenType.illegal, ch!);
        }
    }
    readChar();
    return token;
  }

  String readIdentifier() {
    int start = position;
    while (Tools.isLetter(ch)) {
      readChar();
    }
    return input.substring(start, position);
  }

  String readNumber() {
    int start = position;
    while (Tools.isDigit(ch)) {
      readChar();
    }
    return input.substring(start, position);
  }

  String readString() {
    int start = position + 1;
    while (true) {
      readChar();
      if (ch == '"') {
        break;
      }
    }
    return input.substring(start, position);
  }

  void skipWhitespace() {
    while (ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r') {
      readChar();
    }
  }

  String peekChar() {
    if (readPosition >= input.length) {
      return "";
    } else {
      return input[readPosition];
    }
  }

  @override
  String toString() {
    List<TokenNode> res = [];
    for (
      var t = nextToken();
      t.$1 != TokenType.eof;
      res.add(t), t = nextToken()
    ) {}
    return (res..add((TokenType.eof, ""))).toString();
  }
}

enum OperatorPrecedence {
  /*最低优先级*/ lowest,
  /*==,!=*/ equals,
  /*>,<*/ lessgreater,
  /*+*/ sum,
  /* * */ product,
  /*-或!*/ prefix,
  /*函数*/ call,
  /*索引取值符*/ id,
}

const Map<OperatorPrecedence, int> operatorPrecedenceRank = {
  OperatorPrecedence.lowest: 1,
  OperatorPrecedence.equals: 2,
  OperatorPrecedence.lessgreater: 3,
  OperatorPrecedence.sum: 4,
  OperatorPrecedence.product: 5,
  OperatorPrecedence.prefix: 6,
  OperatorPrecedence.call: 7,
  OperatorPrecedence.id: 8,
};

const operatorPrecedenceMap = {
  TokenType.eq: OperatorPrecedence.equals,
  TokenType.noteq: OperatorPrecedence.equals,
  TokenType.lt: OperatorPrecedence.lessgreater,
  TokenType.gt: OperatorPrecedence.lessgreater,
  TokenType.plus: OperatorPrecedence.sum,
  TokenType.minus: OperatorPrecedence.sum,
  TokenType.slash: OperatorPrecedence.product,
  TokenType.asterisk: OperatorPrecedence.product,
  TokenType.lbracket: OperatorPrecedence.id,
};

sealed class AST {
  String tokenLiteral() => '';
}

class Program extends AST {
  List<AstStatement> statements = [];

  @override
  String tokenLiteral() {
    if (statements.isEmpty) {
      return statements[0].tokenLiteral();
    } else {
      return '';
    }
  }

  @override
  String toString() {
    String out = '';
    for (final i in statements) {
      out += i.toString();
    }
    return out;
  }
}

sealed class AstStatement extends AST {} //ast主体节点

sealed class AstExpression extends AST {} //ast辅助节点

class LetStatement extends AstStatement {
  TokenNode token;
  IdentifierExpression name;
  AstExpression value;

  LetStatement(this.token, this.name, this.value);

  @override
  String tokenLiteral() {
    return token.$2;
  }

  @override
  String toString() {
    String out = "${token.$2} ${name.toString()} = ";
    out += value.toString();
    return "$out;";
  }
}

class ReturnStatement extends AstStatement {
  TokenNode token;
  AstExpression returnValue;
  ReturnStatement(this.token, this.returnValue);

  @override
  String tokenLiteral() {
    return token.$2;
  }

  @override
  String toString() {
    return "${token.$2} ${returnValue.toString()};";
  }
}

class BlockStatement extends AstStatement {
  List<AstStatement> statements = [];
  TokenNode token;
  BlockStatement(this.token);

  @override
  String tokenLiteral() {
    return token.$2;
  }

  @override
  String toString() {
    String out = '';
    for (AST i in statements) {
      out += i.toString();
    }
    return out;
  }
}

class ExpressionStatement extends AstStatement {
  TokenNode token;
  AstExpression expression;
  ExpressionStatement(this.token, this.expression);

  @override
  String tokenLiteral() {
    return token.$2;
  }

  @override
  String toString() {
    return expression.toString();
  }
}

class IdentifierExpression extends AstExpression {
  TokenNode token;
  String value;
  IdentifierExpression(this.token, this.value);

  @override
  String tokenLiteral() {
    return token.$2;
  }

  @override
  String toString() {
    return value;
  }
}

class IntegerLiteralExpression extends AstExpression {
  TokenNode token;
  int value;
  IntegerLiteralExpression(this.token, this.value);

  @override
  String tokenLiteral() {
    return token.$2;
  }

  @override
  String toString() {
    return token.$2;
  }
}

class BooleanLiteralExpression extends AstExpression {
  TokenNode token;
  bool value;

  BooleanLiteralExpression(this.token) : value = token.$2 == 'true';

  @override
  String tokenLiteral() {
    return token.$2;
  }

  @override
  String toString() {
    return token.$2;
  }
}

class StringLiteralExpression extends AstExpression {
  TokenNode token;
  String value;

  StringLiteralExpression(this.token, this.value);

  @override
  String tokenLiteral() {
    return token.$2;
  }

  @override
  String toString() {
    return token.$2;
  }
}

class PrefixExpression extends AstExpression {
  TokenNode token;
  String operator;
  AstExpression right;
  PrefixExpression(this.token, this.operator, this.right);

  @override
  String tokenLiteral() {
    return token.$2;
  }

  @override
  String toString() {
    return "($operator${right.toString()})";
  }
}

class InfixExpression extends AstExpression {
  TokenNode token;
  AstExpression left;
  String operator;
  AstExpression right;
  InfixExpression(this.token, this.left, this.operator, this.right);

  @override
  String tokenLiteral() {
    return token.$2;
  }

  @override
  String toString() {
    return "(${left.toString()}$operator${right.toString()})";
  }
}

class IfExpression extends AstExpression {
  TokenNode token;
  AstExpression condition;
  AstStatement consequence;
  AstStatement? alternative;
  IfExpression(this.token, this.condition, this.consequence, this.alternative);

  @override
  String tokenLiteral() {
    return token.$2;
  }

  @override
  String toString() {
    String out = 'if${condition.toString()}{${consequence.toString()}}';
    if (alternative != null) {
      out += "else{${alternative.toString()}}";
    }
    return out;
  }
}

class FunctionLiteralExpression extends AstExpression {
  TokenNode token;
  List<IdentifierExpression> parameters;
  BlockStatement body;
  FunctionLiteralExpression(this.token, this.parameters, this.body);

  @override
  String tokenLiteral() {
    return token.$2;
  }

  @override
  String toString() {
    var params = parameters.map((i) => i.toString());
    return "${tokenLiteral()}(${params.join(',')})${body.toString()}";
  }
}

class CallExpression extends AstExpression {
  TokenNode token;
  IdentifierExpression function;
  List<AstExpression> arguments;
  CallExpression(this.token, this.function, this.arguments);

  @override
  String tokenLiteral() {
    return token.$2;
  }

  @override
  String toString() {
    var args = arguments.map((i) => i.toString());
    return "${function.toString()}(${args.join(',')})";
  }
}

class ArrayLiteralExpression extends AstExpression {
  TokenNode token;
  List<AstExpression> elements;

  ArrayLiteralExpression(this.token, this.elements);

  @override
  String tokenLiteral() {
    return token.$2;
  }

  @override
  String toString() {
    List<String> elementsStr = [];
    for (AstExpression i in elements) {
      elementsStr.add(i.toString());
    }
    return "[${elementsStr.join(',')}]";
  }
}

class IndexExpression extends AstExpression {
  TokenNode token;
  AstExpression left;
  AstExpression index;

  IndexExpression(this.token, this.left, this.index);

  @override
  String tokenLiteral() {
    return token.$2;
  }

  @override
  String toString() {
    return "${left.toString()}[${index.toString()}]";
  }
}

class Parser {
  Lexer lexer;
  late TokenNode curToken;
  late TokenNode peekToken;
  Map<TokenType, Function> prefixParseFns = {};
  Map<TokenType, Function> infixParseFns = {};
  List<String> errors = [];
  Parser(this.lexer) {
    registerPrefix(TokenType.ident, parseIdentifier);
    registerPrefix(TokenType.int, parseIntegerLiteral);
    registerPrefix(TokenType.bang, parsePrefixExpression);
    registerPrefix(TokenType.minus, parsePrefixExpression);
    registerPrefix(TokenType.tRue, parseBooleanLiteral);
    registerPrefix(TokenType.fAlse, parseBooleanLiteral);
    registerPrefix(TokenType.lparen, parseGroupedExpression);
    registerPrefix(TokenType.iF, parseIfExpression);
    registerPrefix(TokenType.function, parseFunctionLiteral);
    registerPrefix(TokenType.string, parseString);
    registerPrefix(TokenType.lbracket, parseArrayLiteral);

    registerInfix(TokenType.plus, parseInfixExpression);
    registerInfix(TokenType.minus, parseInfixExpression);
    registerInfix(TokenType.slash, parseInfixExpression);
    registerInfix(TokenType.asterisk, parseInfixExpression);
    registerInfix(TokenType.eq, parseInfixExpression);
    registerInfix(TokenType.noteq, parseInfixExpression);
    registerInfix(TokenType.lt, parseInfixExpression);
    registerInfix(TokenType.gt, parseInfixExpression);
    registerInfix(TokenType.lparen, parseCallExpression);
    registerInfix(TokenType.lbracket, parseIndexExpression);

    curToken = lexer.nextToken();
    peekToken = lexer.nextToken();
  }
  void nextToken() {
    curToken = peekToken;
    peekToken = lexer.nextToken();
  }

  Program parseProgram() {
    final program = Program();
    while (!curTokenIs(TokenType.eof)) {
      program.statements.add(parseStatement());
      nextToken();
    }
    return program;
  }

  AstStatement parseStatement() {
    switch (curToken.$1) {
      case TokenType.let:
        return parseLetStatement();
      case TokenType.rEturn:
        return parseReturnStatement();
      default:
        return parseExpressionStatement();
    }
  }

  LetStatement parseLetStatement() {
    TokenNode token = curToken;
    if (!expectPeek(TokenType.ident)) {
      errors.add("声明语句后无标识符");
      throw FormatException(errors.last);
    }
    final name = IdentifierExpression(curToken, curToken.$2);
    if (!expectPeek(TokenType.assign)) {
      errors.add("声明语句后无等于符号");
      throw FormatException(errors.last);
    }
    nextToken();
    AstExpression value = parseExpression(OperatorPrecedence.lowest);
    if (peekTokenIs(TokenType.semicolon)) {
      nextToken();
    }
    return LetStatement(token, name, value);
  }

  ReturnStatement parseReturnStatement() {
    TokenNode token = curToken;
    nextToken();
    AstExpression returnValue = parseExpression(OperatorPrecedence.lowest);
    if (peekTokenIs(TokenType.semicolon)) {
      nextToken();
    }
    return ReturnStatement(token, returnValue);
  }

  ExpressionStatement parseExpressionStatement() {
    TokenNode token = curToken;
    final expression = parseExpression(OperatorPrecedence.lowest);
    if (peekTokenIs(TokenType.semicolon)) {
      nextToken();
    }
    return ExpressionStatement(token, expression);
  }

  AstExpression parseExpression(OperatorPrecedence precedence) {
    Function? prefixFn = prefixParseFns[curToken.$1];
    if (prefixFn == null) {
      noPrefixParseFnError(curToken.$1);
      throw FormatException("表达式含有特殊符号无法按前缀表达式解析");
    }
    var leftExp = prefixFn();

    while (!peekTokenIs(TokenType.semicolon) &&
        operatorPrecedenceRank[precedence]! <
            operatorPrecedenceRank[peekPrecedence()]!) {
      Function? infixFn = infixParseFns[peekToken.$1];
      if (infixFn == null) {
        return leftExp;
      }
      nextToken();
      leftExp = infixFn(leftExp);
    }

    return leftExp;
  }

  IdentifierExpression parseIdentifier() {
    return IdentifierExpression(curToken, curToken.$2);
  }

  BooleanLiteralExpression parseBooleanLiteral() {
    return BooleanLiteralExpression(curToken);
  }

  IntegerLiteralExpression? parseIntegerLiteral() {
    int? value = int.tryParse(curToken.$2);
    if (value == null) {
      // errors.add("无法将${curToken.$2}表达式无法解析为整型");
      throw FormatException("无法将${curToken.$2}表达式无法解析为整型");
    }
    return IntegerLiteralExpression(curToken, value);
  }

  PrefixExpression parsePrefixExpression() {
    TokenNode token = curToken;
    nextToken();
    return PrefixExpression(
      token,
      token.$2,
      parseExpression(OperatorPrecedence.prefix),
    );
  }

  InfixExpression parseInfixExpression(AstExpression left) {
    TokenNode token = curToken;
    OperatorPrecedence precedence = curPrecedence();
    nextToken();
    return InfixExpression(token, left, token.$2, parseExpression(precedence));
  }

  AstExpression parseGroupedExpression() {
    nextToken();
    final expression = parseExpression(OperatorPrecedence.lowest);
    if (!expectPeek(TokenType.rparen)) {
      throw FormatException("分组表达式缺少结尾右括号");
    }
    return expression;
  }

  IfExpression parseIfExpression() {
    TokenNode token = curToken;
    if (!expectPeek(TokenType.lparen)) {
      throw FormatException("条件语句（if）缺少指定条件的左括号分隔符");
    }
    nextToken();
    AstExpression condition = parseExpression(OperatorPrecedence.lowest);
    if (!expectPeek(TokenType.rparen)) {
      throw FormatException("条件语句（if）缺少指定条件的右括号分隔符");
    }

    if (!expectPeek(TokenType.lbrace)) {
      throw FormatException("条件语句（if）缺少指定结果的右大括号分隔符");
    }
    BlockStatement consequence = parseBlockStatement();
    BlockStatement? alternative;
    if (peekTokenIs(TokenType.eLse)) {
      nextToken();
      if (!expectPeek(TokenType.lbrace)) {
        throw FormatException("条件语句（if）缺少指定结果的右大括号分隔符");
      }
      alternative = parseBlockStatement();
    }
    return IfExpression(token, condition, consequence, alternative);
  }

  BlockStatement parseBlockStatement() {
    BlockStatement block = BlockStatement(curToken);
    nextToken();
    while (!curTokenIs(TokenType.rbrace) && !curTokenIs(TokenType.eof)) {
      AstStatement statement = parseStatement();
      block.statements.add(statement);
      nextToken();
    }
    return block;
  }

  FunctionLiteralExpression parseFunctionLiteral() {
    TokenNode token = curToken;
    if (!expectPeek(TokenType.lparen)) {
      throw FormatException("函数指定参数缺少左括号");
    }
    List<IdentifierExpression> parameters = parseFunctionParameters();
    if (!expectPeek(TokenType.lbrace)) {
      throw FormatException("函数内部作用域缺少左括号");
    }
    return FunctionLiteralExpression(token, parameters, parseBlockStatement());
  }

  StringLiteralExpression parseString() {
    return StringLiteralExpression(curToken, curToken.$2);
  }

  ArrayLiteralExpression parseArrayLiteral() {
    TokenNode token = curToken;
    return ArrayLiteralExpression(
      token,
      parseExpressionList(TokenType.rbracket),
    );
  }

  List<AstExpression> parseExpressionList(TokenType end) {
    List<AstExpression> list = [];
    if (peekTokenIs(end)) {
      nextToken();
      return list;
    }
    nextToken();
    list.add(parseExpression(OperatorPrecedence.lowest));
    while (peekTokenIs(TokenType.comma)) {
      nextToken();
      nextToken();
      list.add(parseExpression(OperatorPrecedence.lowest));
    }
    if (!expectPeek(end)) {
      throw FormatException("缺少结尾符$end");
    }
    return list;
  }

  List<IdentifierExpression> parseFunctionParameters() {
    List<IdentifierExpression> identifiers = [];
    if (peekTokenIs(TokenType.rparen)) {
      nextToken();
      return identifiers;
    }
    nextToken();
    identifiers.add(IdentifierExpression(curToken, curToken.$2));
    while (peekTokenIs(TokenType.comma)) {
      nextToken();
      nextToken();
      identifiers.add(IdentifierExpression(curToken, curToken.$2));
    }
    if (!expectPeek(TokenType.rparen)) {
      throw Exception("缺少右括号 ')'");
    }
    return identifiers;
  }

  CallExpression parseCallExpression(IdentifierExpression functionExpression) {
    TokenNode token = curToken;
    return CallExpression(
      token,
      functionExpression,
      parseExpressionList(TokenType.rparen),
    );
  }

  IndexExpression parseIndexExpression(AstExpression left) {
    TokenNode token = curToken;
    nextToken();
    AstExpression index = parseExpression(OperatorPrecedence.lowest);
    if (!expectPeek(TokenType.rbracket)) {
      throw FormatException("索引取值无结束符");
    }
    return IndexExpression(token, left, index);
  }

  bool curTokenIs(TokenType tokentype) {
    // if (curToken == null) return false;
    return curToken.$1 == tokentype;
  }

  bool peekTokenIs(TokenType tokentype) {
    // if (peekToken == null) return false;
    return peekToken.$1 == tokentype;
  }

  bool expectPeek(TokenType tokentype) {
    if (peekTokenIs(tokentype)) {
      nextToken();
      return true;
    } else {
      peekError(tokentype);
      return false;
    }
  }

  List<String> getErrors() {
    return errors;
  }

  void registerPrefix(TokenType tokentype, Function fn) {
    prefixParseFns[tokentype] = fn;
  }

  void registerInfix(TokenType tokentype, Function fn) {
    infixParseFns[tokentype] = fn;
  }

  void peekError(TokenType tokentype) {
    errors.add("期望下一个符号是$tokentype，结果却是${peekToken.$1}");
  }

  void noPrefixParseFnError(TokenType tokentype) {
    errors.add("未找到$tokentype的前缀解析函数");
  }

  OperatorPrecedence peekPrecedence() {
    final p = operatorPrecedenceMap[peekToken.$1];
    if (p == null) {
      return OperatorPrecedence.lowest;
    }
    return p;
  }

  OperatorPrecedence curPrecedence() {
    final p = operatorPrecedenceMap[curToken.$1];
    if (p == null) {
      return OperatorPrecedence.lowest;
    }
    return p;
  }

  @override
  String toString() {
    return parseProgram().toString();
  }
}

enum WzObjectType {
  iNt,
  bOol,
  nUll,
  returnValue,
  function,
  string,
  builtin,
  array,
}

sealed class WzObject {
  WzObjectType type() => WzObjectType.nUll;

  String inspect() => '';
}

class WzInt extends WzObject {
  int value;
  WzInt(this.value);

  @override
  WzObjectType type() => WzObjectType.iNt;

  @override
  String inspect() => value.toString();
}

class WzBool extends WzObject {
  bool value;
  WzBool(this.value);

  @override
  WzObjectType type() => WzObjectType.bOol;

  @override
  String inspect() => value.toString();
}

class WzNull extends WzObject {
  @override
  WzObjectType type() => WzObjectType.nUll;

  @override
  String inspect() => 'null';
}

class WzReturnValue extends WzObject {
  WzObject value;

  WzReturnValue(this.value);
  @override
  WzObjectType type() => WzObjectType.returnValue;

  @override
  String inspect() => value.toString();
}

class WzFunction extends WzObject {
  List<IdentifierExpression> parameters;
  BlockStatement body;
  WzEnvironment env;

  WzFunction(this.parameters, this.body, this.env);

  @override
  WzObjectType type() => WzObjectType.returnValue;

  @override
  String inspect() {
    List<String> params = [];
    for (IdentifierExpression i in parameters) {
      params.add(i.toString());
    }
    return "fn(${params.join(',')}){${body.toString()}}";
  }
}

class WzString extends WzObject {
  String value;

  WzString(this.value);

  @override
  WzObjectType type() => WzObjectType.string;

  @override
  String inspect() => value.toString();
}

class WzBuiltin extends WzObject {
  Function fn;
  WzBuiltin(this.fn);

  @override
  WzObjectType type() => WzObjectType.builtin;

  @override
  String inspect() => '内置函数';
}

class WzArray extends WzObject {
  List<WzObject> elements;
  WzArray(this.elements);

  @override
  WzObjectType type() => WzObjectType.array;

  @override
  String inspect() {
    List<String> elementsStr = [];
    for (WzObject i in elements) {
      elementsStr.add(i.inspect());
    }
    return "[${elementsStr.join(',')}]";
  }
}

WzObject evalBlockStatement(List<AstStatement> statements, WzEnvironment env) {
  WzObject result = WzNull();
  for (AstStatement i in statements) {
    result = eval(i, env);
    if (result != nULL && result is WzReturnValue) {
      return result;
    }
  }
  return result;
}

final tRUE = WzBool(true);
final fALSE = WzBool(false);
final nULL = WzNull();

WzBool nativeBoolObject(bool i) {
  return i ? tRUE : fALSE;
}

WzObject evalPrefixExpression(String op, WzObject ri) {
  switch (op) {
    case "!":
      return evalBangOperatorExpression(ri);
    case "-":
      return evalMinuxOperatorExpression(ri);
    default:
      throw FormatException("未知前缀操作符");
  }
}

WzObject evalMinuxOperatorExpression(WzObject ri) {
  if (ri is WzInt) {
    return WzInt(-ri.value);
  }
  throw FormatException("取负操作无法作用于非整型");
}

WzBool evalBangOperatorExpression(WzObject ri) {
  switch (ri) {
    case WzInt():
      return ri.value == 0 ? tRUE : fALSE;
    case WzBool():
      return ri.value ? fALSE : tRUE;
    case WzNull():
      return tRUE;
    default:
      return fALSE;
  }
}

WzObject evalInfixExpression(String op, WzObject le, WzObject ri) {
  if (le is WzInt && ri is WzInt) {
    switch (op) {
      case "+":
        return WzInt(le.value + ri.value);
      case "-":
        return WzInt(le.value - ri.value);
      case "*":
        return WzInt(le.value * ri.value);
      case "/":
        return WzInt(le.value * ri.value);
      case ">":
        return nativeBoolObject(le.value > ri.value);
      case "<":
        return nativeBoolObject(le.value < ri.value);
      case "==":
        return nativeBoolObject(le.value == ri.value);
      case "!=":
        return nativeBoolObject(le.value != ri.value);
      default:
        throw FormatException("无法求值$le$op$ri");
    }
  } else if (le is WzString && ri is WzString) {
    if (op != '+') {
      throw FormatException("无法求值${le.type()}$op${ri.type()}");
    }
    return WzString(le.value + ri.value);
  } else if (op == '==') {
    return nativeBoolObject((le as WzBool).value == (ri as WzBool).value);
  } else if (op == '!=') {
    return nativeBoolObject((le as WzBool).value != (ri as WzBool).value);
  } else if (le.type() != ri.type()) {
    throw FormatException("无法强转$le$op$ri");
  } else {
    throw FormatException("无法求值$le$op$ri");
  }
}

bool isTruthy(WzObject obj) {
  if (obj is WzInt && obj.value != 0) {
    return true;
  }
  switch (obj) {
    case WzBool():
      return obj.value;
    default:
      return false;
  }
}

WzObject evalIfExpression(IfExpression node, WzEnvironment env) {
  final condition = eval(node.condition, env);
  if (isTruthy(condition)) {
    return eval(node.consequence, env);
  } else if (node.alternative != null) {
    return eval(node.alternative!, env);
  } else {
    return nULL;
  }
}

WzObject evalProgram(List<AstStatement> statements, WzEnvironment env) {
  WzObject result = WzNull();
  for (AstStatement i in statements) {
    result = eval(i, env);
    if (result is WzReturnValue) {
      return result.value;
    }
  }
  return result;
}

WzObject evalIdentifier(IdentifierExpression node, WzEnvironment env) {
  dynamic val = env.get(node.value);
  if (val != null) {
    return val;
  }
  final builtin = builtins[node.value];
  if (builtin != null) {
    return builtin;
  }
  throw FormatException("标识符${node.value}未定义");
}

List<WzObject> evalExpression(
  List<AstExpression> expressions,
  WzEnvironment env,
) {
  List<WzObject> result = [];
  for (AstExpression i in expressions) {
    result.add(eval(i, env));
  }
  return result;
}

WzObject evalIndexExpression(WzObject left, WzObject index) {
  if (left is WzArray && index is WzInt) {
    return evalArrayIndexExpression(left, index);
  } else {
    throw FormatException("${left.type()}不支持索引取值");
  }
}

WzObject evalArrayIndexExpression(WzArray array, WzInt index) {
  if (index.value < 0 || index.value > array.elements.length) {
    return nULL;
  }
  return array.elements[index.value];
}

WzEnvironment extendFunctionEnv(WzFunction fn, List<WzObject> args) {
  WzEnvironment env = WzEnvironment(fn.env);
  for (int paramIdx = 0; paramIdx < fn.parameters.length; paramIdx++) {
    env.set(fn.parameters[paramIdx].value, args[paramIdx]);
  }
  return env;
}

WzObject unwrapReturnValue(WzObject obj) {
  if (obj is WzReturnValue) {
    return obj.value;
  }
  return obj;
}

WzObject applyFunction(WzObject fn, List<WzObject> args) {
  if (fn is WzFunction) {
    WzEnvironment extendedEnv = extendFunctionEnv(fn, args);
    WzObject evaluated = eval(fn.body, extendedEnv);
    return unwrapReturnValue(evaluated);
  } else if (fn is WzBuiltin) {
    return Function.apply(fn.fn, args);
  } else {
    throw FormatException("${fn.type()}不是一个函数");
  }
}

class WzEnvironment {
  Map<String, dynamic> store = {};
  WzEnvironment? outer;

  WzEnvironment([this.outer]);

  dynamic get(String name) {
    dynamic obj = store[name];
    if (obj == null && outer != null) {
      return outer!.get(name);
    }
    return obj;
  }

  dynamic set(String name, dynamic val) {
    store[name] = val;
    return val;
  }
}

WzObject eval(AST node, [WzEnvironment? env]) {
  env ??= WzEnvironment();
  if (node is Program) {
    return evalProgram(node.statements, env);
  } else if (node is ExpressionStatement) {
    return eval(node.expression, env);
  } else if (node is IntegerLiteralExpression) {
    return WzInt(node.value);
  } else if (node is BooleanLiteralExpression) {
    return nativeBoolObject(node.value);
  } else if (node is StringLiteralExpression) {
    return WzString(node.value);
  } else if (node is PrefixExpression) {
    return evalPrefixExpression(node.operator, eval(node.right, env));
  } else if (node is InfixExpression) {
    return evalInfixExpression(
      node.operator,
      eval(node.left, env),
      eval(node.right, env),
    );
  } else if (node is BlockStatement) {
    return evalBlockStatement(node.statements, env);
  } else if (node is IfExpression) {
    return evalIfExpression(node, env);
  } else if (node is ReturnStatement) {
    return WzReturnValue(eval(node.returnValue, env));
  } else if (node is LetStatement) {
    WzObject val = eval(node.value, env);
    env.set(node.name.value, val);
    return val;
  } else if (node is IdentifierExpression) {
    return evalIdentifier(node, env);
  } else if (node is FunctionLiteralExpression) {
    return WzFunction(node.parameters, node.body, env);
  } else if (node is CallExpression) {
    WzObject functionObj = eval(node.function, env);
    List<WzObject> args = evalExpression(node.arguments, env);
    return applyFunction(functionObj, args);
  } else if (node is ArrayLiteralExpression) {
    return WzArray(evalExpression(node.elements, env));
  } else if (node is IndexExpression) {
    return evalIndexExpression(eval(node.left, env), eval(node.index, env));
  }
  return nULL;
}

final builtins = {
  "len": WzBuiltin((List args) {
    if (args.length != 1) {
      throw FormatException("参数个数为${args.length}但只能为1");
    }
    if (args[0] is WzString) {
      return WzInt(args[0].value.length);
    } else {
      throw FormatException("len函数不支持操作于${args[0].type()}");
    }
  }),
};

///Read-Lex-Print-Loop 读取-词法分析-打印-循环
class Rlpl extends Command {
  @override
  String get name => 'rlpl';
  @override
  String get description => 'wz语言RLPL模式';
  @override
  void run() {
    print('Dart RLPL (输入 exit 退出)');
    while (true) {
      stdout.write('>>> ');
      String? input = stdin.readLineSync();
      if (input == null || input.trim() == 'exit') break;
      try {
        final lexer = Lexer(input);
        TokenNode token = lexer.nextToken();
        while (token.$1 != TokenType.eof) {
          print(token);
          token = lexer.nextToken();
        }
      } catch (e) {
        print('错误: $e');
      }
    }
  }
}

///Read-Par-Print-Loop 读取-语法分析-打印-循环
class Rppl extends Command {
  @override
  String get name => 'rppl';
  @override
  String get description => 'wz语言RPPL模式';
  @override
  void run() {
    print('Dart RPPL (输入 exit 退出)');
    while (true) {
      stdout.write('>>> ');
      String? input = stdin.readLineSync();
      if (input == null || input.trim() == 'exit') break;
      try {
        final lexer = Lexer(input);
        TokenNode token = lexer.nextToken();

        while (token.$1 != TokenType.eof) {
          print(token);
          token = lexer.nextToken();
        }
      } catch (e) {
        print('错误: $e');
      }
    }
  }
}

///Read-Evaluate-Print-Loop 读取-语法分析-打印-循环
class Repl extends Command {
  @override
  String get name => 'repl';
  @override
  String get description => 'wz语言REPL模式';
  @override
  void run() {
    print('WZ REPL (输入 exit 退出)');
    while (true) {
      stdout.write('>>> ');
      String? input = stdin.readLineSync();
      if (input == null || input.trim() == 'exit') break;
      try {
        final lexer = Lexer(input);
        final parser = Parser(lexer);

        print(eval(parser.parseProgram()));
        // TokenNode token = lexer.nextToken();

        // while (token.$1 != TokenType.eof) {
        // print(token);
        // token = lexer.nextToken();
        // }
      } catch (e) {
        print('错误: $e');
      }
    }
  }
}
