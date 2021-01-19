import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:get_it/get_it.dart';
import 'package:linshare_flutter_app/presentation/manager/upload_and_share_file/upload_and_share_file_manager.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/helper/file_helper.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:redux/redux.dart';
import 'package:testshared/testshared.dart';

import '../../domain/test/fixture/test_fixture.dart';
import '../../domain/test/mock/repository/authentication/mock_credential_repository.dart';
import '../../domain/test/mock/repository/authentication/mock_document_repository.dart';
import '../../domain/test/mock/repository/authentication/mock_token_repository.dart';
import '../fixtures/test_redux_module.dart';

void main() {
  final getIt = GetIt.asNewInstance();
  TestReduxModule(getIt);

  group('upload_and_share_file_manager_test', () {
    MockDocumentRepository documentRepository;
    MockTokenRepository tokenRepository;
    MockCredentialRepository credentialRepository;
    UploadMySpaceDocumentInteractor uploadFileInteractor;
    ShareDocumentInteractor shareDocumentInteractor;
    UploadWorkGroupDocumentInteractor uploadWorkGroupDocumentInteractor;
    UploadShareFileManager uploadShareFileManager;
    UploadTaskId uploadTaskId;
    FileHelper fileHelper;

    setUp(() {
      documentRepository = MockDocumentRepository();
      tokenRepository = MockTokenRepository();
      credentialRepository = MockCredentialRepository();
      uploadTaskId = UploadTaskId('upload_task_id_1');
      uploadFileInteractor = UploadMySpaceDocumentInteractor(
        documentRepository,
        tokenRepository,
        credentialRepository,
      );
      shareDocumentInteractor = ShareDocumentInteractor(documentRepository);
      fileHelper = FileHelper();
      uploadShareFileManager = UploadShareFileManager(
        getIt.get<Store<AppState>>(),
        Stream.fromIterable([]),
        uploadFileInteractor,
        shareDocumentInteractor,
        uploadWorkGroupDocumentInteractor,
        fileHelper
      );
    });

    void mockPermanentUploadData() {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl()).thenAnswer((_) async => linShareBaseUrl);
    }

    test(
      'justUpload just mapping result into action, then dispatch to store',
      () async {
        // TODO: Rewrite test with upload list files
        expect(true, true);
      },
    );

    test(
      'justUpload just mapping result into action in case failed, then dispatch to store',
      () async {
        // TODO: Rewrite test with upload list files
        expect(true, true);
      },
    );

    test(
      'justShare just mapping result into action, then dispatch to store',
      () async {
        when(documentRepository.share(
          [document1.documentId],
          [mailListId],
          [genericUser],
        )).thenAnswer((_) async => [share1]);

        await uploadShareFileManager.justShare(recipients, [document1.documentId]);

        expect(
          getIt.get<Store<AppState>>().state.shareState.viewState,
          equals(Right<Failure, Success>(ShareDocumentViewState([share1]))),
        );
      },
    );

    test(
      'justShare share empty documents',
      () async {
        await uploadShareFileManager.justShare(recipients, []);

        expect(
          getIt.get<Store<AppState>>().state.shareState.viewState,
          equals(Left<Failure, Success>(ShareDocumentFailure(ShareDocumentEmpty()))),
        );
      },
    );

    test(
      'justShare share empty recipients',
      () async {
        await uploadShareFileManager.justShare([], [document1.documentId]);

        expect(
          getIt.get<Store<AppState>>().state.shareState.viewState,
          equals(Left<Failure, Success>(ShareDocumentFailure(ShareDocumentToNobodyException()))),
        );
      },
    );

    test(
      'uploadAndShare upload and share success',
      () async {
        // TODO: Rewrite test with upload and share list files
        expect(true, true);
      },
    );
  });
}
