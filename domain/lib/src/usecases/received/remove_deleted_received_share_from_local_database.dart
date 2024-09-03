import 'package:domain/domain.dart';
import 'package:collection/collection.dart';

class RemoveDeletedReceivedShareFromLocalDatabaseInteractor {
  final ReceivedShareRepository _receivedShareRepository;

  RemoveDeletedReceivedShareFromLocalDatabaseInteractor(
      this._receivedShareRepository);

  Future<void> execute(
      List<ReceivedShare> receivedShares, String recipient) async {
    var localRecievedShares = await _receivedShareRepository
        .getAllReceivedShareOfflineByRecipient(recipient);

    for (final localReceived in localRecievedShares) {
      final receivedShare = receivedShares.firstWhereOrNull(
          (received) => received.shareId == localReceived.shareId);
      if (receivedShare == null) {
        await _receivedShareRepository.disableOffline(
            localReceived.shareId, localReceived.localPath ?? '');
      }
    }
  }
}
