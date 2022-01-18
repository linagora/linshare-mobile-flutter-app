import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:get_it/get_it.dart';
import 'package:linshare_flutter_app/presentation/manager/upload_and_share_file/upload_and_share_file_manager.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/helper/file_helper.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';
import 'package:testshared/testshared.dart';

import '../../domain/test/mock/repository/authentication/mock_api_repository.dart';
import '../../domain/test/mock/repository/authentication/mock_credential_repository.dart';
import '../../domain/test/mock/repository/authentication/mock_document_repository.dart';
import '../../domain/test/mock/repository/authentication/mock_token_repository.dart';
import '../../domain/test/mock/repository/quota/mock_quota_repository.dart';
import '../fixtures/mock/mock_fixtures.dart';
import '../fixtures/test_redux_module.dart';

void main() {
  final getIt = GetIt.instance;
  TestReduxModule(getIt);
  getIt.registerLazySingleton<UploadWorkGroupDocumentInteractor>(() => MockUploadWorkGroupDocumentInteractor());

  group('upload_and_share_file_manager_test', () {
    late MockDocumentRepository documentRepository;
    MockTokenRepository tokenRepository;
    MockCredentialRepository credentialRepository;
    MockAPIRepository apiRepository;
    UploadMySpaceDocumentInteractor uploadFileInteractor;
    ShareDocumentInteractor shareDocumentInteractor;
    UploadWorkGroupDocumentInteractor uploadWorkGroupDocumentInteractor;
    late UploadShareFileManager uploadShareFileManager;
    FileHelper fileHelper;
    QuotaRepository quotaRepository;
    GetQuotaInteractor getQuotaInteractor;
    late Store<AppState> store;

    setUp(() {
      documentRepository = MockDocumentRepository();
      tokenRepository = MockTokenRepository();
      credentialRepository = MockCredentialRepository();
      apiRepository = MockAPIRepository();
      uploadFileInteractor = UploadMySpaceDocumentInteractor(
        documentRepository,
        tokenRepository,
        credentialRepository,
        apiRepository
      );
      shareDocumentInteractor = ShareDocumentInteractor(documentRepository);
      fileHelper = FileHelper();
      quotaRepository = MockQuotaRepository();
      getQuotaInteractor = GetQuotaInteractor(quotaRepository);
      uploadWorkGroupDocumentInteractor = getIt.get<UploadWorkGroupDocumentInteractor>();
      store = getIt.get<Store<AppState>>();
      uploadShareFileManager = UploadShareFileManager(
        store,
        Stream.fromIterable([]),
        uploadFileInteractor,
        shareDocumentInteractor,
        uploadWorkGroupDocumentInteractor,
        fileHelper,
        getQuotaInteractor
      );
    });

    // TODO: Rewrite test with upload list files
    /*test(
      'justUpload just mapping result into action, then dispatch to store',
      () async {

        expect(true, true);
      },
    );*/

    // TODO: Rewrite test with upload list files
    /*test(
      'justUpload just mapping result into action in case failed, then dispatch to store',
      () async {

        expect(true, true);
      },
    );*/

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
          store.state.shareState.viewState,
          equals(Right<Failure, Success>(ShareDocumentViewState([share1]))),
        );
      },
    );

    test(
      'justShare share empty documents',
      () async {
        await uploadShareFileManager.justShare(recipients, []);

        expect(
          store.state.shareState.viewState,
          equals(Left<Failure, Success>(ShareDocumentFailure(ShareDocumentEmpty()))),
        );
      },
    );

    test(
      'justShare share empty recipients',
      () async {
        await uploadShareFileManager.justShare([], [document1.documentId]);

        expect(
          store.state.shareState.viewState,
          equals(Left<Failure, Success>(ShareDocumentFailure(ShareDocumentToNobodyException()))),
        );
      },
    );

    // TODO: Rewrite test with upload and share list files
    /*test(
      'uploadAndShare upload and share success',
      () async {

        expect(true, true);
      },
    );*/
  });
}
