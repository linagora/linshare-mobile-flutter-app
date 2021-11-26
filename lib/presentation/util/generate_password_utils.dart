import 'dart:math';

class GeneratePasswordUtils {
  String get generateSaaSPassword {
    final generator = Random.secure();
    var pass = <int>[];
    pass.add(generator.nextInt(26) + 65);
    pass.add(generator.nextInt(26) + 97);
    pass.add(generator.nextInt(10) + 48);
    pass.add(generator.nextInt(6) + 59);

    final cycles = generator.nextInt(10) + 10;

    for (var i = 0; i < cycles; i++) {
      pass.add(generator.nextInt(26) + (i % 2 == 0 ? 97 : 65));
    }
    final len = pass.length;
    for (var i = 0; i < len; i++) {
      final to = generator.nextInt(len);
      final from = generator.nextInt(len) + 1;
      final t = pass[to];
      pass[to] = pass[len - from];
      pass[len - from] = t;
    }

    return String.fromCharCodes(pass);
  }
}
