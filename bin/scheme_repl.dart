import 'dart:convert';
import 'dart:io';

import 'package:scheme_repl/environment.dart';
import 'package:scheme_repl/primitives.dart';

void main(List<String> arguments) {
  // Listen for Ctrl+C
  ProcessSignal.sigint.watch().listen((_) => exit(0));

  // stdout.write("> ");
  stdin.transform(utf8.decoder).listen(
    (program) {
      try {
        print(eval(parse(program), standardEnv));
      } catch (e) {
        print(e.toString());
      }
      // stdout.write("> ");
    },
    onDone: () => exit(0),
    onError: (_) => exit(1),
  );
}
