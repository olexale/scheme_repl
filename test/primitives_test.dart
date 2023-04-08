import 'package:scheme_repl/primitives.dart';
import 'package:test/test.dart';

void main() {
  group('tokenize', () {
    test('empty string', () {
      expect(tokenize(''), []);
    });

    test('single token without parentheses', () {
      expect(tokenize('hello'), ['hello']);
    });

    test('multiple tokens without parentheses', () {
      expect(tokenize('hello world'), ['hello', 'world']);
    });

    test('single token with parentheses', () {
      expect(tokenize('(hello)'), ['(', 'hello', ')']);
    });

    test('nested parentheses', () {
      expect(
          tokenize('(hello (world))'), ['(', 'hello', '(', 'world', ')', ')']);
    });

    test('multiple tokens with parentheses', () {
      expect(tokenize('(hello) world (how are you)'),
          ['(', 'hello', ')', 'world', '(', 'how', 'are', 'you', ')']);
    });

    test('tokens with extra spaces', () {
      expect(tokenize('  hello   world  '), ['hello', 'world']);
    });
  });

  group('parseTokens', () {
    test('empty token list', () {
      expect(() => parseTokens([]), throwsA(isA<Exception>()));
    });

    test('symbol', () {
      expect(parseTokens(['x']), Symbol('x'));
    });

    test('integer atom', () {
      expect(parseTokens(['42']), 42.0);
    });

    test('double atom', () {
      expect(parseTokens(['3.14']), 3.14);
    });
    test('boolean atom', () {
      expect(parseTokens(['#t']), true);
      expect(parseTokens(['#f']), false);
    });
    test('string atom', () {
      expect(parseTokens(['"hello"']), 'hello');
    });

    test('simple list', () {
      expect(
        parseTokens(['(', '"hello"', '"world"', ')']),
        ['hello', 'world'],
      );
    });

    test('nested list', () {
      expect(
        parseTokens(['(', 'hello', '(', '"world"', '42', ')', ')']),
        [
          Symbol('hello'),
          ['world', 42]
        ],
      );
    });

    test('unexpected closing parenthesis', () {
      expect(() => parseTokens([')']), throwsA(isA<Exception>()));
    });

    test('unclosed list', () {
      expect(() => parseTokens(['(', 'hello', 'world']),
          throwsA(isA<Exception>()));
    });
  });
}
