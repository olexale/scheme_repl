import 'dart:math' as math;

final Map<String, dynamic> standardEnv = {
  ..._strictParamsFuncs,
  ..._multipleParamsFuncs
};

final Map<String, dynamic> _strictParamsFuncs = {
  'pi': math.pi,
  'sin': math.sin,
  'cos': math.cos,
  'tan': math.tan,
  'asin': math.asin,
  'acos': math.acos,
  'atan': math.atan,
  'sqrt': math.sqrt,
  'random': (num x) => math.Random().nextDouble() * x,
  '>': (a, b) => a > b,
  '<': (a, b) => a < b,
  '>=': (a, b) => a >= b,
  '<=': (a, b) => a <= b,
  '=': (a, b) => a == b,
  'abs': (num x) => x.abs(),
  'append': (a, b) => a + b,
  'apply': (Function proc, List args) => Function.apply(proc, args),
  'car': (List x) => x.first,
  'cdr': (List x) => x.sublist(1),
  'cons': (x, List y) => y..insert(0, x),
  'eq?': (a, b) => identical(a, b),
  'expt': math.pow,
  'equal?': (a, b) => a == b,
  'length': (List x) => x.length,
  'map': (dynamic Function(dynamic) f, List<dynamic> x) => x.map(f).toList(),
  'not': (bool x) => !x,
  'null?': (x) => x == null,
  'number?': (dynamic x) => x is num,
  'print': print,
  'procedure?': (x) => x is Function,
  'round': (num x) => x.round(),
  'symbol?': (x) => x is String,
};

final Map<String, dynamic> _multipleParamsFuncs = {
  'begin': (List x) => x.last,
  'list': (List<dynamic> x) => List.from(x),
  '+': (List x) => x.reduce((a, b) => a + b),
  '-': (List x) => x.reduce((a, b) => a - b),
  '*': (List x) => x.reduce((a, b) => a * b),
  '/': (List x) => x.reduce((a, b) => a / b),
  'max': (List x) => x.cast<num>().reduce((a, b) => math.max(a, b)),
  'min': (List x) => x.cast<num>().reduce((a, b) => math.min(a, b)),
};

dynamic eval(dynamic x, [Map<String, dynamic>? env]) {
  env ??= standardEnv;

  if (x is String) {
    return env[x];
  }
  if (x is num || x is bool) {
    return x;
  }
  if (x is List) {
    if (x[0].toString() == 'if') {
      // conditional
      final test = x[1];
      final conseq = x[2];
      final alt = x[3];
      final exp = eval(test, env) ? conseq : alt;
      return eval(exp, env);
    }
    if (x[0].toString() == 'define') {
      // definition
      final symbol = x[1].toString();
      final exp = x[2];
      env[symbol] = eval(exp, env);
      return null;
    }

    if (x[0].toString() == 'lambda') {
      return (List arguments) {
        final localScope = <String, dynamic>{
          ...Map.fromIterables(x[1].cast<String>(), arguments),
          ...?env,
        };
        return eval(x[2], localScope);
      };
    }

    // procedure call
    var proc = eval(x[0], env);
    var args = x.sublist(1).map((arg) => eval(arg, env)).toList();

    return Function.apply(
      proc,
      // if function is either an exceptional or a custom lambda - wrap args
      _multipleParamsFuncs.containsKey(x[0].toString()) ||
              (proc is Function &&
                  !_strictParamsFuncs.containsKey(x[0].toString()))
          ? [args]
          : args,
    );
  }
  throw Exception('Unknown expression type: $x');
}
