// Qalculyn - Mathematical Expression Engine
// Implements a safe tokenizer, parser (Pratt parser), and evaluator.
// Never uses eval() or executes user input as Dart code.

import 'dart:math' as math;

/// Token types for the expression parser
enum TokenType {
  number,
  plus,
  minus,
  multiply,
  divide,
  modulo,
  power,
  leftParen,
  rightParen,
  percent,
  factorial,
  comma,
  function_,
  constant,
  eof,
}

/// Represents a single token in the expression
class Token {
  final TokenType type;
  final String value;
  final int position;

  const Token(this.type, this.value, this.position);

  @override
  String toString() => 'Token($type, "$value", pos:$position)';
}

/// Result of a calculation - either a value or an error
class CalcResult {
  final double? value;
  final String? error;
  final String? formattedExpression;

  const CalcResult.success(this.value, {this.formattedExpression}) : error = null;
  const CalcResult.failure(this.error, {this.formattedExpression}) : value = null;

  bool get isSuccess => value != null && error == null;
  bool get isError => error != null;

  @override
  String toString() => isSuccess ? 'CalcResult($value)' : 'CalcResult(error: $error)';
}

/// Angle mode for trigonometric calculations
enum AngleMode { degrees, radians }

/// Tokenizer: converts expression string into tokens
class Tokenizer {
  final String input;
  int _pos = 0;

  Tokenizer(this.input);

  static const _functions = {
    'sin', 'cos', 'tan', 'asin', 'acos', 'atan',
    'sinh', 'cosh', 'tanh', 'asinh', 'acosh', 'atanh',
    'log', 'ln', 'log2', 'log10', 'exp', 'sqrt', 'cbrt', 'abs',
    'floor', 'ceil', 'round',
    'nPr', 'nCr',
  };

  static const _constants = {'pi', 'π', 'e', 'τ'};

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (_pos < input.length) {
      _skipWhitespace();
      if (_pos >= input.length) break;

      final c = input[_pos];

      if (_isDigit(c) || (c == '.' && _pos + 1 < input.length && _isDigit(input[_pos + 1]))) {
        tokens.add(_readNumber());
      } else if (_isLetter(c)) {
        tokens.add(_readIdentifier());
      } else {
        switch (c) {
          case '+':
            tokens.add(Token(TokenType.plus, '+', _pos++));
          case '-':
            tokens.add(Token(TokenType.minus, '-', _pos++));
          case '*':
          case '×':
            tokens.add(Token(TokenType.multiply, '×', _pos++));
          case '/':
          case '÷':
            tokens.add(Token(TokenType.divide, '÷', _pos++));
          case '%':
            tokens.add(Token(TokenType.percent, '%', _pos++));
          case '^':
            tokens.add(Token(TokenType.power, '^', _pos++));
          case '(':
            tokens.add(Token(TokenType.leftParen, '(', _pos++));
          case ')':
            tokens.add(Token(TokenType.rightParen, ')', _pos++));
          case '!':
            tokens.add(Token(TokenType.factorial, '!', _pos++));
          case ',':
            tokens.add(Token(TokenType.comma, ',', _pos++));
          default:
            throw FormatException('Unexpected character: "$c"', input, _pos);
        }
      }
    }
    tokens.add(Token(TokenType.eof, '', _pos));
    return tokens;
  }

  void _skipWhitespace() {
    while (_pos < input.length && input[_pos] == ' ') {
      _pos++;
    }
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isLetter(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) ||
        (code >= 97 && code <= 122) ||
        c == 'π' ||
        c == 'τ';
  }

  Token _readNumber() {
    final start = _pos;
    bool hasDot = false;
    bool hasE = false;

    while (_pos < input.length) {
      final c = input[_pos];
      if (_isDigit(c)) {
        _pos++;
      } else if (c == '.' && !hasDot && !hasE) {
        hasDot = true;
        _pos++;
      } else if ((c == 'e' || c == 'E') && !hasE) {
        // Check it's scientific notation, not 'exp' function
        if (_pos + 1 < input.length) {
          final next = input[_pos + 1];
          if (_isDigit(next) || next == '+' || next == '-') {
            hasE = true;
            _pos++;
            if (_pos < input.length && (input[_pos] == '+' || input[_pos] == '-')) {
              _pos++;
            }
            continue;
          }
        }
        break;
      } else {
        break;
      }
    }

    return Token(TokenType.number, input.substring(start, _pos), start);
  }

  Token _readIdentifier() {
    final start = _pos;
    // Handle special single-char constants
    if (input[_pos] == 'π' || input[_pos] == 'τ') {
      _pos++;
      final id = input.substring(start, _pos);
      return Token(TokenType.constant, id, start);
    }

    while (_pos < input.length && (_isLetter(input[_pos]) || _isDigit(input[_pos]))) {
      _pos++;
    }

    final id = input.substring(start, _pos);

    if (id == 'mod') {
      return Token(TokenType.modulo, id, start);
    } else if (_constants.contains(id)) {
      return Token(TokenType.constant, id, start);
    } else if (_functions.contains(id)) {
      return Token(TokenType.function_, id, start);
    } else {
      throw FormatException('Unknown identifier: "$id"', input, start);
    }
  }
}

/// Pratt Parser and Evaluator for mathematical expressions
class ExpressionParser {
  final List<Token> tokens;
  final AngleMode angleMode;
  final double? memoryValue;
  int _pos = 0;

  ExpressionParser(this.tokens, {this.angleMode = AngleMode.degrees, this.memoryValue});

  Token get _current => tokens[_pos];
  Token get _previous => tokens[_pos - 1];

  Token _advance() {
    if (_current.type != TokenType.eof) _pos++;
    return _previous;
  }

  bool _match(TokenType type) {
    if (_current.type == type) {
      _advance();
      return true;
    }
    return false;
  }

  Token _consume(TokenType type, String message) {
    if (_current.type == type) return _advance();
    throw FormatException(message);
  }

  /// Parse and evaluate the full expression
  double parse() {
    if (tokens.length == 1 && tokens[0].type == TokenType.eof) {
      throw const FormatException('Empty expression');
    }
    final result = _parseExpression(0);
    if (_current.type != TokenType.eof) {
      throw const FormatException('Incomplete or invalid calculation');
    }
    return result;
  }

  /// Pratt parser - parse expression with given minimum binding power
  double _parseExpression(int minBp) {
    var left = _parsePrefixExpression();

    while (true) {
      final op = _current;
      final bp = _infixBindingPower(op.type);
      if (bp == null || bp.$1 < minBp) break;

      _advance();
      left = _evalInfix(op, left, bp.$2);
    }

    // Handle postfix operators
    while (true) {
      if (_current.type == TokenType.factorial) {
        _advance();
        left = _factorial(left);
      } else if (_current.type == TokenType.percent) {
        _advance();
        left = left / 100.0;
      } else {
        break;
      }
    }

    return left;
  }

  /// Get binding power for infix operators (left bp, right bp)
  (int, int)? _infixBindingPower(TokenType type) {
    return switch (type) {
      TokenType.plus || TokenType.minus => (1, 2),
      TokenType.multiply || TokenType.divide || TokenType.modulo => (3, 4),
      TokenType.power => (6, 5), // Right-associative
      _ => null,
    };
  }

  /// Parse prefix expressions (numbers, unary ops, parens, functions)
  double _parsePrefixExpression() {
    final token = _current;

    switch (token.type) {
      case TokenType.number:
        _advance();
        return double.parse(token.value);

      case TokenType.constant:
        _advance();
        return switch (token.value) {
          'pi' || 'π' => math.pi,
          'e' => math.e,
          'τ' => 2 * math.pi,
          _ => throw FormatException('Unknown constant: ${token.value}'),
        };

      case TokenType.minus:
        _advance();
        return -_parseExpression(5); // Unary minus has high precedence

      case TokenType.plus:
        _advance();
        return _parseExpression(5); // Unary plus

      case TokenType.leftParen:
        _advance();
        final value = _parseExpression(0);
        _consume(TokenType.rightParen, 'Expected closing parenthesis');
        return value;

      case TokenType.function_:
        return _parseFunction();

      default:
        throw const FormatException('Incomplete calculation');
    }
  }

  /// Evaluate an infix operation
  double _evalInfix(Token op, double left, int rightBp) {
    final right = _parseExpression(rightBp);

    return switch (op.type) {
      TokenType.plus => left + right,
      TokenType.minus => left - right,
      TokenType.multiply => left * right,
      TokenType.divide => () {
          if (right == 0) throw FormatException('Division by zero');
          return left / right;
        }(),
      TokenType.modulo => () {
          if (right == 0) throw FormatException('Division by zero');
          return left % right;
        }(),
      TokenType.power => math.pow(left, right).toDouble(),
      _ => throw FormatException('Unknown operator: ${op.value}'),
    };
  }

  /// Parse a function call
  double _parseFunction() {
    final name = _advance().value;
    _consume(TokenType.leftParen, 'Expected "(" after function name');

    final args = <double>[];
    if (_current.type != TokenType.rightParen) {
      args.add(_parseExpression(0));
      while (_match(TokenType.comma)) {
        args.add(_parseExpression(0));
      }
    }

    _consume(TokenType.rightParen, 'Expected ")" after function arguments');

    return _evalFunction(name, args);
  }

  double _toRadians(double value) {
    return angleMode == AngleMode.degrees ? value * math.pi / 180.0 : value;
  }

  double _fromRadians(double value) {
    return angleMode == AngleMode.degrees ? value * 180.0 / math.pi : value;
  }

  /// Evaluate a function with given arguments
  double _evalFunction(String name, List<double> args) {
    if (args.isEmpty && name != 'nPr' && name != 'nCr') {
      throw FormatException('Function $name requires at least 1 argument');
    }

    final double a = args.isNotEmpty ? args[0] : 0.0;

    switch (name) {
      // Trigonometric
      case 'sin':
        return _cleanTrigResult(math.sin(_toRadians(a)));
      case 'cos':
        return _cleanTrigResult(math.cos(_toRadians(a)));
      case 'tan':
        final rad = _toRadians(a);
        final cosVal = math.cos(rad);
        if (cosVal.abs() < 1e-15) throw FormatException('Undefined: tan at this angle');
        return _cleanTrigResult(math.sin(rad) / cosVal);

      // Inverse trigonometric
      case 'asin':
        if (a < -1 || a > 1) throw FormatException('asin domain error: value must be between -1 and 1');
        return _fromRadians(math.asin(a));
      case 'acos':
        if (a < -1 || a > 1) throw FormatException('acos domain error: value must be between -1 and 1');
        return _fromRadians(math.acos(a));
      case 'atan':
        return _fromRadians(math.atan(a));

      // Hyperbolic
      case 'sinh':
        if (a > 710) return double.infinity;
        if (a < -710) return -double.infinity;
        return (math.exp(a) - math.exp(-a)) / 2;
      case 'cosh':
        if (a.abs() > 710) return double.infinity;
        return (math.exp(a) + math.exp(-a)) / 2;
      case 'tanh':
        if (a > 20) return 1.0;
        if (a < -20) return -1.0;
        return (math.exp(a) - math.exp(-a)) / (math.exp(a) + math.exp(-a));
      case 'asinh':
        return math.log(a + math.sqrt(a * a + 1));
      case 'acosh':
        if (a < 1) throw FormatException('acosh domain error: value must be >= 1');
        return math.log(a + math.sqrt(a * a - 1));
      case 'atanh':
        if (a <= -1 || a >= 1) throw FormatException('atanh domain error: value must be between -1 and 1');
        return 0.5 * math.log((1 + a) / (1 - a));

      // Logarithmic
      case 'log':
        if (a <= 0) throw FormatException('Logarithm domain error: value must be positive');
        if (args.length > 1) {
          final base = args[1];
          if (base <= 0 || (base - 1.0).abs() < 1e-12) {
            throw FormatException('Logarithm base must be positive and not equal to 1');
          }
          return math.log(a) / math.log(base);
        }
        return math.log(a) / math.ln10;
      case 'log10':
        if (a <= 0) throw FormatException('Logarithm domain error: value must be positive');
        return math.log(a) / math.ln10;
      case 'log2':
        if (a <= 0) throw FormatException('Logarithm domain error: value must be positive');
        return math.log(a) / math.ln2;
      case 'ln':
        if (a <= 0) throw FormatException('Logarithm domain error: value must be positive');
        return math.log(a);

      // Exponential
      case 'exp':
        return math.exp(a);

      // Roots
      case 'sqrt':
        if (a < 0) throw FormatException('Square root domain error: value must be non-negative');
        return math.sqrt(a);
      case 'cbrt':
        return (a < 0 ? -math.pow(-a, 1.0 / 3.0) : math.pow(a, 1.0 / 3.0)).toDouble();

      // Other
      case 'abs':
        return a.abs();
      case 'floor':
        return a.floorToDouble();
      case 'ceil':
        return a.ceilToDouble();
      case 'round':
        return a.roundToDouble();

      // Combinatorics
      case 'nPr':
        if (args.length != 2) throw FormatException('nPr requires 2 arguments');
        return _permutation(args[0], args[1]);
      case 'nCr':
        if (args.length != 2) throw FormatException('nCr requires 2 arguments');
        return _combination(args[0], args[1]);

      default:
        throw FormatException('Unknown function: $name');
    }
  }

  /// Clean up tiny floating point errors in trig results
  double _cleanTrigResult(double value) {
    if (value.abs() < 1e-15) return 0.0;
    if ((value - 1).abs() < 1e-15) return 1.0;
    if ((value + 1).abs() < 1e-15) return -1.0;
    return value;
  }

  /// Calculate factorial
  double _factorial(double value) {
    if (value.isNaN || value.isInfinite) throw FormatException('Factorial requires a finite number');
    if (value < 0) throw FormatException('Factorial is not defined for negative numbers');
    if (value != value.truncateToDouble()) {
      throw FormatException('Factorial is only defined for non-negative integers');
    }
    if (value > 170) throw FormatException('Factorial overflow: value too large');

    final n = value.toInt();
    if (n == 0 || n == 1) return 1.0;

    double result = 1.0;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  /// Calculate permutation P(n,r)
  double _permutation(double n, double r) {
    if (n.isNaN || n.isInfinite || r.isNaN || r.isInfinite) {
      throw FormatException('nPr requires finite numbers');
    }
    if (n < 0 || r < 0) throw FormatException('nPr requires non-negative integers');
    if (n != n.truncateToDouble() || r != r.truncateToDouble()) {
      throw FormatException('nPr requires integers');
    }
    if (r > n) throw FormatException('nPr requires r ≤ n');
    if (n > 170) throw FormatException('Value too large for nPr');

    double result = 1;
    for (int i = n.toInt(); i > (n - r).toInt(); i--) {
      result *= i;
    }
    return result;
  }

  /// Calculate combination C(n,r)
  double _combination(double n, double r) {
    if (n.isNaN || n.isInfinite || r.isNaN || r.isInfinite) {
      throw FormatException('nCr requires finite numbers');
    }
    if (n < 0 || r < 0) throw FormatException('nCr requires non-negative integers');
    if (n != n.truncateToDouble() || r != r.truncateToDouble()) {
      throw FormatException('nCr requires integers');
    }
    if (r > n) throw FormatException('nCr requires r ≤ n');
    if (n > 170) throw FormatException('Value too large for nCr');

    final ni = n.toInt();
    var ri = r.toInt();
    if (ri > ni - ri) ri = ni - ri; // Optimization: C(n,r) = C(n,n-r)

    double result = 1;
    for (int i = 0; i < ri; i++) {
      result *= (ni - i);
      result /= (i + 1);
    }
    return result;
  }
}

/// High-level calculator engine
class CalculatorEngine {
  AngleMode angleMode;
  double? memoryValue;

  CalculatorEngine({this.angleMode = AngleMode.degrees, this.memoryValue});

  /// Evaluate an expression string and return a CalcResult
  CalcResult evaluate(String expression) {
    if (expression.trim().isEmpty) {
      return const CalcResult.failure('Empty expression');
    }

    try {
      // Preprocess the expression
      final processed = _preprocess(expression);
      final tokenizer = Tokenizer(processed);
      final tokens = tokenizer.tokenize();
      final parser = ExpressionParser(
        tokens,
        angleMode: angleMode,
        memoryValue: memoryValue,
      );
      final result = parser.parse();

      // Validate result
      if (result.isNaN) {
        return const CalcResult.failure('Result is undefined');
      }
      if (result.isInfinite) {
        return CalcResult.failure(result > 0 ? 'Result is too large' : 'Result is too small');
      }

      return CalcResult.success(result, formattedExpression: expression);
    } on FormatException catch (e) {
      String msg = e.message;
      if (msg.contains('token') || msg.contains('got') || msg.contains('TokenType')) {
        msg = 'Incomplete calculation';
      }
      return CalcResult.failure(msg, formattedExpression: expression);
    } catch (e) {
      return CalcResult.failure('Calculation error', formattedExpression: expression);
    }
  }

  /// Preprocess expression to handle contextual percentage
  /// Rules:
  /// - "200 + 10%" => "200 + (200 * 10 / 100)" = 220
  /// - "200 - 10%" => "200 - (200 * 10 / 100)" = 180
  /// - "200 × 10%" => "200 × (10 / 100)" = 20
  /// - "200 ÷ 10%" => "200 ÷ (10 / 100)" = 2000
  /// - Standalone "10%" => "10 / 100" = 0.1
  String _preprocess(String expr) {
    // Replace display characters with parser-compatible ones
    var processed = expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-');

    // Handle contextual percentage:
    // Pattern: number_or_paren +/- number%
    // We need to handle this before tokenizing
    processed = _processContextualPercent(processed);

    return processed;
  }

  String _processContextualPercent(String expr) {
    // Process percentage patterns iteratively
    final percentRegex = RegExp(r'(\d+\.?\d*)\s*%');
    var result = expr;

    while (true) {
      final match = percentRegex.firstMatch(result);
      if (match == null) break;

      final percentValue = match.group(1)!;
      final percentStart = match.start;
      final percentEnd = match.end;

      // Look backwards to find the operator and base value
      final before = result.substring(0, percentStart).trimRight();

      if (before.isEmpty) {
        // Standalone percentage: N% => (N/100)
        result = result.replaceRange(percentStart, percentEnd, '($percentValue/100)');
        continue;
      }

      final lastChar = before[before.length - 1];

      if (lastChar == '+' || lastChar == '-') {
        final opPos = before.length - 1;
        var parenDepth = 0;
        var baseStart = 0;

        for (var i = opPos - 1; i >= 0; i--) {
          final ch = before[i];
          if (ch == ')') {
            parenDepth++;
          } else if (ch == '(') {
            if (parenDepth == 0) {
              baseStart = i + 1;
              break;
            }
            parenDepth--;
          } else if (ch == ',' && parenDepth == 0) {
            baseStart = i + 1;
            break;
          }
        }

        final baseExpr = before.substring(baseStart, opPos).trim();
        if (baseExpr.isNotEmpty) {
          // Contextual: base +/- percent% => base +/- ((base) * percent / 100)
          final replacement = '(($baseExpr)*$percentValue/100)';
          result = result.replaceRange(percentStart, percentEnd, replacement);
          continue;
        }
      }

      // For * and /, or non-contextual, convert to /100
      result = result.replaceRange(percentStart, percentEnd, '($percentValue/100)');
    }

    return result;
  }

  // Memory operations
  void memoryClear() => memoryValue = null;
  void memoryRecall() {} // Returns memoryValue
  void memoryAdd(double value) => memoryValue = (memoryValue ?? 0) + value;
  void memorySubtract(double value) => memoryValue = (memoryValue ?? 0) - value;
  void memoryStore(double value) => memoryValue = value;
}
