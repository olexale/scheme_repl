import 'package:scheme_repl/environment.dart';
import 'package:test/test.dart';
import 'dart:math' as math;
import 'package:scheme_repl/primitives.dart';

void main() {
  group('eval', () {
    test('evaluating a variable', () {
      expect(eval(Symbol('pi'), standardEnv), equals(math.pi));
    });

    test('evaluating a constant number', () {
      expect(eval(42, standardEnv), equals(42));
    });

    test('evaluating a unary operation', () {
      expect(eval([Symbol('sin'), math.pi / 2], standardEnv), equals(1));
    });

    test('evaluating a binary operation', () {
      expect(eval([Symbol('+'), 2, 3], standardEnv), equals(5));
    });

    test('evaluating a list operation', () {
      expect(eval([Symbol('list'), 1, 2, 3], standardEnv), equals([1, 2, 3]));
    });

    test('evaluating a conditional', () {
      expect(
        eval([Symbol('if'), true, 1, 0], standardEnv),
        equals(1),
      );
      expect(
        eval([Symbol('if'), false, 1, 0], standardEnv),
        equals(0),
      );
    });

    test('evaluating a definition', () {
      final env = {...standardEnv};
      eval([Symbol('define'), 'x', 42], env);
      expect(env[Symbol('x')], equals(42));
    });
    test('evalating quotation', () {
      final actual = eval([
        Symbol('quote'),
        [1, 2, 3]
      ], standardEnv);
      expect(actual, equals([1, 2, 3]));
    });

    test('evaluating a lambda', () {
      final square = eval([
        Symbol('lambda'),
        [Symbol('x')],
        [Symbol('*'), Symbol('x'), Symbol('x')]
      ], standardEnv);
      expect(square([2]), equals(4));
      expect(square([3]), equals(9));
    });

    test('evaluating a procedure call', () {
      final env = <Symbol, dynamic>{
        ...standardEnv,
        Symbol('square'): eval([
          Symbol('lambda'),
          [Symbol('x')],
          [Symbol('*'), Symbol('x'), Symbol('x')]
        ], standardEnv)
      };
      expect(eval([Symbol('square'), 2], env), equals(4));
      expect(eval([Symbol('square'), 3], env), equals(9));
    });
  });
}
