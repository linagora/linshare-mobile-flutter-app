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
// <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
//  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
//  the Additional Terms applicable to LinShare software.

import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/model/shared_space_details_info.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/base/base_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/shared_space_details_arguments.dart';
import 'package:redux/redux.dart';

class SharedSpaceDetailsViewModel extends BaseViewModel {
  final AppNavigation _appNavigation;
  final GetSharedSpaceInteractor _getSharedSpaceInteractor;
  final GetQuotaInteractor _getQuotaInteractor;
  final GetAllSharedSpaceMembersInteractor _getAllSharedSpaceMembersInteractor;
  final SharedSpaceActivitiesInteractor _sharedSpaceActivitiesInteractor;

  SharedSpaceNodeNested sharedSpaceNodeNested;

  SharedSpaceDetailsViewModel(
    Store<AppState> store,
    this._appNavigation,
    this._getSharedSpaceInteractor,
    this._getQuotaInteractor,
    this._getAllSharedSpaceMembersInteractor,
    this._sharedSpaceActivitiesInteractor
  ) : super(store);

  Future<SharedSpaceNodeNested> getSharedSpace(SharedSpaceId sharedSpaceId) async {
    return (await _getSharedSpaceInteractor.execute(sharedSpaceId))
        .map((result) => result is SharedSpaceDetailViewState ? result.sharedSpace : null)
        .getOrElse(() => null);
  }

  Future<AccountQuota> getAccountQuota(QuotaId quotaId) async {
    return (await _getQuotaInteractor.execute(quotaId))
        .map((result) => result is AccountQuotaViewState ? result.accountQuota : null)
        .getOrElse(() => null);
  }

  Future<SharedSpaceDetailsInfo> getSharedSpaceDetails(SharedSpaceDetailsArguments sharedSpaceDetailsArguments) async {
    return await getSharedSpace(sharedSpaceDetailsArguments.sharedSpaceId).then(
      (sharedSpace) async {
        return await Future.wait([
            _getQuotaInteractor.execute(sharedSpace.quotaId),
            _getAllSharedSpaceMembersInteractor.execute(sharedSpace.sharedSpaceId),
            _sharedSpaceActivitiesInteractor.execute(sharedSpace.sharedSpaceId)
        ]).then((response) async {
          final accountQuota = response[0]
              .map((result) => result is AccountQuotaViewState ? result.accountQuota : [])
              .getOrElse(() => []);
          final members = response[1]
              .map((result) => result is SharedSpaceMembersViewState ? result.members : [])
              .getOrElse(() => []);
          final activities = response[2]
              .map((result) => result is SharedSpacesActivitiesViewState ? result.auditLogEntryUserList : [])
              .getOrElse(() => []);
          return SharedSpaceDetailsInfo(sharedSpace, accountQuota, members, activities);
        });
      });
  }

  void backToSharedSpacesList() {
    _appNavigation.popBack();
  }

  @override
  void onDisposed() {
    super.onDisposed();
  }
}
