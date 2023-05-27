import 'dart:math' as math;
import 'package:scheme_repl/primitives.dart';

final Map<Symbol, dynamic> standardEnv = {
  ..._strictParamsFuncs,
  ..._multipleParamsFuncs
};

final Map<Symbol, dynamic> _strictParamsFuncs = {
  Symbol('pi'): math.pi,
  Symbol('sin'): math.sin,
  Symbol('cos'): math.cos,
  Symbol('tan'): math.tan,
  Symbol('asin'): math.asin,
  Symbol('acos'): math.acos,
  Symbol('atan'): math.atan,
  Symbol('sqrt'): math.sqrt,
  Symbol('random'): (num x) => math.Random().nextDouble() * x,
  Symbol('>'): (a, b) => a > b,
  Symbol('<'): (a, b) => a < b,
  Symbol('>='): (a, b) => a >= b,
  Symbol('<='): (a, b) => a <= b,
  Symbol('='): (a, b) => a == b,
  Symbol('abs'): (num x) => x.abs(),
  Symbol('append'): (a, b) => a + b,
  Symbol('apply'): (Function proc, List args) => Function.apply(proc, args),
  Symbol('car'): (List x) => x.first,
  Symbol('cdr'): (List x) => x.sublist(1),
  Symbol('cons'): (x, List y) => [x, ...y],
  Symbol('eq?'): (a, b) => a == b,
  Symbol('expt'): math.pow,
  Symbol('equal?'): (a, b) => a == b,
  Symbol('length'): (List x) => x.length,
  Symbol('not'): (bool x) => !x,
  Symbol('null?'): (x) => x == null,
  Symbol('number?'): (dynamic x) => x is num,
  Symbol('print'): print,
  Symbol('procedure?'): (x) => x is Function,
  Symbol('round'): (num x) => x.round(),
  Symbol('symbol?'): (x) => x is Symbol,
};

final Map<Symbol, dynamic> _multipleParamsFuncs = {
  Symbol('begin'): (List x) => x.last,
  Symbol('list'): (List<dynamic> x) => List.from(x),
  Symbol('+'): (List x) => x.reduce((a, b) => a + b),
  Symbol('-'): (List x) => x.reduce((a, b) => a - b),
  Symbol('*'): (List x) => x.reduce((a, b) => a * b),
  Symbol('/'): (List x) => x.reduce((a, b) => a / b),
  Symbol('max'): (List x) => x.cast<num>().reduce((a, b) => math.max(a, b)),
  Symbol('min'): (List x) => x.cast<num>().reduce((a, b) => math.min(a, b)),
};

dynamic eval(dynamic x, Map<Symbol, dynamic> env) {
  if (x is Symbol) {
    return env[x];
  }
  if (x is num || x is bool || x is String) {
    return x;
  }
  if (x is List) {
    return switch (x[0].toString()) {
      'if' => _handleIf(x, env),
      'define' => _handleDefine(x, env),
      'quote' => x[1],
      'lambda' => _handleLambda(x, env),
      'map' => _handleMap(x, env),
      _ => _handleProcudure(x, env),
    };
  }
  throw Exception('Unknown expression type: $x');
}

dynamic _handleIf(List x, Map<Symbol, dynamic> env) {
  final test = x[1];
  final conseq = x[2];
  final alt = x[3];
  final exp = eval(test, env) ? conseq : alt;
  return eval(exp, env);
}

dynamic _handleDefine(List x, Map<Symbol, dynamic> env) {
  final symbol = x[1].toString();
  final exp = x[2];
  env[Symbol(symbol)] = eval(exp, env);
  return null;
}

dynamic _handleLambda(List x, Map<Symbol, dynamic> env) {
  return (List arguments) {
    final localScope = <Symbol, dynamic>{
      ...Map.fromIterables(x[1].cast<Symbol>(), arguments),
      ...env,
    };
    return eval(x[2], localScope);
  };
}

dynamic _handleMap(List x, Map<Symbol, dynamic> env) {
  final args = eval(x[2], env);
  return args.map((p) => eval([x[1], p], env)).toList();
}

dynamic _handleProcudure(List x, Map<Symbol, dynamic> env) {
  var proc = eval(x[0], env);
  var args = x.sublist(1).map((arg) => eval(arg, env)).toList();

  return Function.apply(
    proc,
    // if function is either an exceptional or a custom lambda - wrap args
    _multipleParamsFuncs.containsKey(x[0]) ||
            (proc is Function && !_strictParamsFuncs.containsKey(x[0]))
        ? [args]
        : args,
  );
}
