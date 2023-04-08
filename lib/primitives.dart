dynamic parse(String program) => parseTokens(tokenize(program));

List<String> tokenize(String program) => program
    .replaceAll('(', ' ( ')
    .replaceAll(')', ' ) ')
    .split(' ')
    .where((token) => token.isNotEmpty)
    .toList();

dynamic parseTokens(List<String> tokens) {
  if (tokens.isEmpty) {
    throw Exception('Unexpected EOF');
  }
  final token = tokens.removeAt(0);
  if (token == '(') {
    final elements = <dynamic>[];
    while (tokens.first != ')') {
      elements.add(parseTokens(tokens));
      if (tokens.isEmpty) {
        throw Exception('Unexpected EOF');
      }
    }
    tokens.removeAt(0); // remove ')'
    return elements;
  } else if (token == ')') {
    throw Exception('Unexpected ")"');
  } else {
    return _atom(token);
  }
}

dynamic _atom(String token) {
  // parse doubles
  final d = double.tryParse(token);
  if (d != null) {
    return d;
  }
  // parse booleans
  if (token == '#t') {
    return true;
  }
  if (token == '#f') {
    return false;
  }
  // // parse strings
  // if (token.startsWith("'") && token.endsWith("'")) {
  //   return token.substring(1, token.length - 1);
  // }
  return token;
}
