import 'dart:developer';
import 'package:domain/domain.dart';

class RemoveDeletedReceivedShareFromLocalDatabaseInteractor {
  final ReceivedShareRepository _receivedShareRepository;

  RemoveDeletedReceivedShareFromLocalDatabaseInteractor(
      this._receivedShareRepository);

  Future<void> execute(
      List<ReceivedShare> receivedShares, String recipient) async {
    try {
      var localReceivedShares = await _receivedShareRepository
          .getAllReceivedShareOfflineByRecipient(recipient);
      final receivedShareIds =
          receivedShares.map((received) => received.shareId).toSet();
      for (final local in localReceivedShares) {
        if (!receivedShareIds.contains(local.shareId)) {
          await _receivedShareRepository.disableOffline(
              local.shareId, local.localPath ?? '');
        }
      }
    } catch (exception) {
      log('RemoveDeletedReceivedShareFromLocalDatabaseInteractor: $exception');
    }
  }
}
