import 'package:data/data.dart';
import 'package:data/src/local/config/received_share_table.dart';
import 'package:data/src/local/model/received_share_cache.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:testshared/fixture/received_share_fixture.dart';
import 'document_database_manager_test.mocks.dart';

@GenerateMocks([DatabaseClient])
void main() {
  late MockDatabaseClient mockDatabaseClient;
  late ReceivedShareDatabaseManager receivedShareDatabaseManager;
  late DateTime now;
  late String todayDate;
  setUp(() {
    mockDatabaseClient = MockDatabaseClient();
    receivedShareDatabaseManager =
        ReceivedShareDatabaseManager(mockDatabaseClient);
    now = DateTime.now();
    todayDate = DateTime(now.year, now.month, now.day, now.hour, now.minute)
        .toIso8601String();
  });

  group('getListDataForRecipient', () {
    test(
        'getListDataForRecipient returns filtered and mapped data for a specific recipient',
        () async {
      when(mockDatabaseClient.getListDataWithCondition(
        ReceivedShareTable.TABLE_NAME,
        '${ReceivedShareTable.MAIL_RECIPIENT} !="" AND ${ReceivedShareTable.MAIL_RECIPIENT} = ? AND ${ReceivedShareTable.EXPIRATION_DATE} >= ?',
        [RECIPIENT_1.mail, todayDate],
      )).thenAnswer((_) async => [
            receivedShare1.toReceivedShareCache().toJson(),
          ]);

      final result = await receivedShareDatabaseManager
          .getListDataForRecipient(RECIPIENT_1.mail);

      expect(result, isA<List<ReceivedShare>>());
      expect(result.length, 1);
      expect(result.first.shareId, receivedShare1.shareId);
    });
    test(
      'getListDataForRecipient returns an empty list when no data matches the recipient',
      () async {
        when(mockDatabaseClient.getListDataWithCondition(
          ReceivedShareTable.TABLE_NAME,
          '${ReceivedShareTable.MAIL_RECIPIENT} !="" AND ${ReceivedShareTable.MAIL_RECIPIENT} = ? AND ${ReceivedShareTable.EXPIRATION_DATE} >= ?',
          [RECIPIENT_1.mail, todayDate],
        )).thenAnswer((_) async => []);

        final result = await receivedShareDatabaseManager
            .getListDataForRecipient(RECIPIENT_1.mail);
        expect(result, isA<List<ReceivedShare>>());
        expect(result.isEmpty, true);
        verify(mockDatabaseClient.getListDataWithCondition(
          ReceivedShareTable.TABLE_NAME,
          '${ReceivedShareTable.MAIL_RECIPIENT} !="" AND ${ReceivedShareTable.MAIL_RECIPIENT} = ? AND ${ReceivedShareTable.EXPIRATION_DATE} >= ?',
          [RECIPIENT_1.mail, todayDate],
        )).called(1);
      },
    );
  });
}
