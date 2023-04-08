import 'package:scheme_repl/environment.dart';
import 'package:test/test.dart';
import 'dart:math' as math;

void main() {
  group('eval', () {
    test('evaluating a variable', () {
      expect(eval('pi'), equals(math.pi));
    });

    test('evaluating a constant number', () {
      expect(eval(42), equals(42));
    });

    test('evaluating a unary operation', () {
      expect(eval(['sin', math.pi / 2]), equals(1));
    });

    test('evaluating a binary operation', () {
      expect(eval(['+', 2, 3]), equals(5));
    });

    test('evaluating a list operation', () {
      expect(eval(['list', 1, 2, 3]), equals([1, 2, 3]));
    });

    test('evaluating a conditional', () {
      expect(
        eval(['if', true, 1, 0]),
        equals(1),
      );
      expect(
        eval(['if', false, 1, 0]),
        equals(0),
      );
    });

    test('evaluating a definition', () {
      final env = {...standardEnv};
      eval(['define', 'x', 42], env);
      expect(env['x'], equals(42));
    });

    test('evaluating a lambda', () {
      final square = eval([
        'lambda',
        ['x'],
        ['*', 'x', 'x']
      ]);
      expect(square([2]), equals(4));
      expect(square([3]), equals(9));
    });

    test('evaluating a procedure call', () {
      final env = {
        ...standardEnv,
        'square': eval([
          'lambda',
          ['x'],
          ['*', 'x', 'x']
        ])
      };
      expect(eval(['square', 2], env), equals(4));
      expect(eval(['square', 3], env), equals(9));
    });
  });
}
