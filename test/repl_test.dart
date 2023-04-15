import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  <String, String>{
    '(if (= 1 1) 1 0)': '1.0',
    '(begin (define circle-area (lambda (r) (* pi (* r r)))) (circle-area 10))':
        '314.1592653589793',
    '(begin (define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1)))))) (fact 10))':
        '3628800.0',
    '(begin (define fib (lambda (n) (if (< n 2) 1 (+ (fib (- n 1)) (fib (- n 2)))))) (define range (lambda (a b) (if (= a b) (quote ()) (cons a (range (+ a 1) b))))) (map fib (range 0 10)))':
        '[1.0, 1.0, 2.0, 3.0, 5.0, 8.0, 13.0, 21.0, 34.0, 55.0]',
  }.forEach((input, output) {
    test('$input - $output', () async {
      final process = await TestProcess.start('dart', ['bin/scheme_repl.dart']);
      process.stdin.writeln(input);
      final actual = await process.stdout.next;
      await process.kill();
      expect(actual, output);
    });
  });
}
