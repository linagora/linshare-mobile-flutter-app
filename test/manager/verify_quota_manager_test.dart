// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2020 LINAGORA
//
// This program is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later version,
// provided you comply with the Additional Terms applicable for LinShare software by
// Linagora pursuant to Section 7 of the GNU Affero General Public License,
// subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
// display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
// the words “You are using the Free and Open Source version of LinShare™, powered by
// Linagora © 2009–2020. Contribute to Linshare R&D by subscribing to an Enterprise
// offer!”. You must also retain the latter notice in all asynchronous messages such as
// e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
// http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
// infringing Linagora intellectual property rights over its trademarks and commercial
// brands. Other Additional Terms apply, see
// <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf
//
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses
// for the GNU Affero General Public License version
//
// 3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf
// for
//
// the Additional Terms applicable to LinShare software.

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:get_it/get_it.dart';
import 'package:linshare_flutter_app/presentation/manager/quota/verify_quota_manager.dart';
import 'package:linshare_flutter_app/presentation/redux/actions/account_action.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:mockito/mockito.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../../domain/test/fixture/test_fixture.dart';
import '../../domain/test/mock/repository/quota/mock_quota_repository.dart';
import '../../domain/test/mock/repository/authentication/mock_authentication_repository.dart';
import '../fixtures/test_redux_module.dart';

void main() {
  final getIt = GetIt.asNewInstance();
  TestReduxModule(getIt);

  group('verify_quota_manager_test', () {
    Store<AppState> _store;
    QuotaRepository _quotaRepository;
    GetQuotaInteractor _getQuotaInteractor;
    VerifyQuotaManager _verifyQuotaManager;

    setUp(() {
      _store = getIt.get<Store<AppState>>();
      _quotaRepository = MockQuotaRepository();
      _getQuotaInteractor = GetQuotaInteractor(_quotaRepository);
      _verifyQuotaManager = VerifyQuotaManager(_store, _getQuotaInteractor);
    });

    test(
      'verify quota should fail and returns fail action if getQuotaInteractor fails',
      () async {
        final accountQuota = AccountQuota(
          QuotaSize(2000),
          QuotaSize(1),
          QuotaSize(10000),
          false
        );
        _store.dispatch(SetAccountInformationsAction(user1));

        when(_quotaRepository.findQuota(user1.quotaUuid))
          .thenAnswer((_) async => accountQuota);

        final verifyQuotaResult = await _verifyQuotaManager.hasEnoughQuotaAndMaxFileSize(filesInfos: [fileInfo1, fileInfo2]);
        expect(verifyQuotaResult, true);
      },
    );

    test(
      'verify quota should fail if list infos is empty',
      () async {
        final accountQuota = AccountQuota(
          QuotaSize(2000),
          QuotaSize(1),
          QuotaSize(10000),
          false
        );
        _store.dispatch(SetAccountInformationsAction(user1));

        when(_quotaRepository.findQuota(user1.quotaUuid))
          .thenAnswer((_) async => accountQuota);

        final verifyQuotaResult = await _verifyQuotaManager.hasEnoughQuotaAndMaxFileSize(filesInfos: []);
        expect(verifyQuotaResult, false);
      },
    );

    test(
      'verify quota should fail and returns fail action if totalFilesSize exceeds quota left',
      () async {
        final accountQuota = AccountQuota(
          QuotaSize(1),
          QuotaSize(1),
          QuotaSize(10000),
          false
        );
        _store.dispatch(SetAccountInformationsAction(user1));

        when(_quotaRepository.findQuota(user1.quotaUuid))
          .thenAnswer((_) async => accountQuota);

        final verifyQuotaResult = await _verifyQuotaManager.hasEnoughQuotaAndMaxFileSize(filesInfos: [fileInfo1, fileInfo2]);
        
        expect(_store.state.uploadFileState.viewState, Left(NotEnoughQuotaMySpaceFailure(accountQuota.quota.size)));
        expect(verifyQuotaResult, false);
      },
    );

    test(
      'verify quota should fail and returns fail action if one or many files sizes exceeds max file size',
      () async {
        final accountQuota = AccountQuota(
          QuotaSize(10000),
          QuotaSize(1),
          QuotaSize(1),
          false
        );
        _store.dispatch(SetAccountInformationsAction(user1));

        when(_quotaRepository.findQuota(user1.quotaUuid))
          .thenAnswer((_) async => accountQuota);

        final verifyQuotaResult = await _verifyQuotaManager.hasEnoughQuotaAndMaxFileSize(filesInfos: [fileInfo1, fileInfo2]);
        
        expect(_store.state.uploadFileState.viewState, Left(TooBigFilesMySpaceFailure([fileInfo1, fileInfo2], accountQuota.maxFileSize.size)));
        expect(verifyQuotaResult, false);
      },
    );
  });
}
