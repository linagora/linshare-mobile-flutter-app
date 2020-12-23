import 'package:domain/domain.dart';
import 'package:data/src/network/config/endpoint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('endpoint extension tests', () {
    test('Service path build with path parameters', () {
      final servicePath = ServicePath(r'/autocomplete/$query/$query2')
        .withPathParameters([
          PathParameter('query', 'user1@lin'),
          PathParameter('query2', 'user2@lin'),
        ]);

      expect(servicePath.path, '/autocomplete/user1@lin/user2@lin');
    });
  });
}
