import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:get_it/get_it.dart';
import 'package:linshare_flutter_app/presentation/manager/upload_and_share_file/upload_and_share_file_manager.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/share_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/upload_file_state.dart';
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
    UploadFileInteractor uploadFileInteractor;
    ShareDocumentInteractor shareDocumentInteractor;
    UploadWorkGroupDocumentInteractor uploadWorkGroupDocumentInteractor;
    UploadShareFileManager uploadShareFileManager;
    UploadTaskId uploadTaskId;

    setUp(() {
      documentRepository = MockDocumentRepository();
      tokenRepository = MockTokenRepository();
      credentialRepository = MockCredentialRepository();
      uploadTaskId = UploadTaskId('upload_task_id_1');
      uploadFileInteractor = UploadFileInteractor(
        documentRepository,
        tokenRepository,
        credentialRepository,
      );
      shareDocumentInteractor = ShareDocumentInteractor(documentRepository);

      uploadShareFileManager = UploadShareFileManager(
        getIt.get<Store<AppState>>(),
        uploadFileInteractor,
        shareDocumentInteractor,
        uploadWorkGroupDocumentInteractor
      );
    });

    void mockPermanentUploadData() {
      when(tokenRepository.getToken()).thenAnswer((_) async => permanentToken);
      when(credentialRepository.getBaseUrl())
          .thenAnswer((_) async => linShareBaseUrl);
    }

    test(
      'justUpload just mapping result into action, then dispatch to store',
      () async {
        mockPermanentUploadData();
        when(documentRepository.upload(
          fileInfo1,
          permanentToken,
          linShareBaseUrl,
        )).thenAnswer(
          (_) async => FileUploadState(
            Stream.fromIterable([
              Right<Failure, Success>(fileUploadProgress10),
              Right<Failure, Success>(fileUploadProgress100),
              Right<Failure, Success>(FileUploadSuccess(document)),
            ]),
            uploadTaskId,
          ),
        );

        expect(
          getIt.get<Store<AppState>>().onChange.map((event) => event.uploadFileState),
          emitsInOrder([
            UploadFileState(viewState: Right(fileUploadProgress10)),
            UploadFileState(viewState: Right(fileUploadProgress100)),
            UploadFileState(viewState: Right(FileUploadSuccess(document))),
          ]),
        );

        uploadShareFileManager.justUpload(fileInfo1);
      },
    );

    test(
      'justUpload just mapping result into action in case failed, then dispatch to store',
      () async {
        final downloadFailException = Exception('Download failed exception');

        mockPermanentUploadData();
        when(documentRepository.upload(
          fileInfo1,
          permanentToken,
          linShareBaseUrl,
        )).thenAnswer(
          (_) async => FileUploadState(
            Stream.fromIterable([
              Right<Failure, Success>(fileUploadProgress10),
              Right<Failure, Success>(fileUploadProgress100),
              Left<Failure, Success>(FileUploadFailure(fileInfo1, downloadFailException)),
            ]),
            uploadTaskId,
          ),
        );

        expect(
          getIt.get<Store<AppState>>().onChange.map((event) => event.uploadFileState),
          emitsInOrder([
            UploadFileState(viewState: Right(fileUploadProgress10)),
            UploadFileState(viewState: Right(fileUploadProgress100)),
            UploadFileState(viewState: Left(FileUploadFailure(fileInfo1, downloadFailException))),
          ]),
        );

        uploadShareFileManager.justUpload(fileInfo1);
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
        mockPermanentUploadData();
        when(documentRepository.upload(
          fileInfo1,
          permanentToken,
          linShareBaseUrl,
        )).thenAnswer(
              (_) async => FileUploadState(
            Stream.fromIterable([
              Right<Failure, Success>(fileUploadProgress10),
              Right<Failure, Success>(fileUploadProgress100),
              Right<Failure, Success>(FileUploadSuccess(document1)),
            ]),
            uploadTaskId,
          ),
        );

        when(documentRepository.share(
          [document1.documentId],
          [mailListId],
          [genericUser],
        )).thenAnswer((_) async => [share1]);

        expect(
          getIt.get<Store<AppState>>().onChange,
          emitsInOrder([
            createAppStateWithUploadState(UploadFileState(viewState: Right(fileUploadProgress10))),
            createAppStateWithUploadState(UploadFileState(viewState: Right(fileUploadProgress100))),
            createAppStateWithUploadState(UploadFileState(viewState: Right(SharingAfterUploadState(recipients, document1)))),
            createAppStateWithShareState(
                UploadFileState(viewState: Right(SharingAfterUploadState(recipients, document1))),
                ShareState(Right(ShareAfterUploadSuccess(recipients, document1)))
            ),
          ]),
        );

        uploadShareFileManager.uploadThenShare(fileInfo1, recipients);
      },
    );
  });
}
