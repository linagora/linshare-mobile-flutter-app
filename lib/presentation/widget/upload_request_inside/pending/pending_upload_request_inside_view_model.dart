/*
 * LinShare is an open source filesharing software, part of the LinPKI software
 * suite, developed by Linagora.
 *
 * Copyright (C) 2021 LINAGORA
 *
 * This program is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Affero General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version,
 * provided you comply with the Additional Terms applicable for LinShare software by
 * Linagora pursuant to Section 7 of the GNU Affero General Public License,
 * subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
 * display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
 * the words “You are using the Free and Open Source version of LinShare™, powered by
 * Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
 * offer!”. You must also retain the latter notice in all asynchronous messages such as
 * e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
 * http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
 * infringing Linagora intellectual property rights over its trademarks and commercial
 * brands. Other Additional Terms apply, see
 * <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
 * for more details.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
 * more details.
 * You should have received a copy of the GNU Affero General Public License and its
 * applicable Additional Terms for LinShare along with this program. If not, see
 * <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
 *  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
 *  the Additional Terms applicable to LinShare software.
 */

import 'package:data/src/util/device_manager.dart';
import 'package:domain/domain.dart';
import 'package:domain/src/usecases/search_upload_request_inside/search_upload_request_entries_interactor.dart';
import 'package:domain/src/usecases/upload_request/get_all_upload_requests_interactor.dart';
import 'package:domain/src/usecases/upload_request_entry/copy_multiple_files_from_upload_request_entries_to_my_space_interactor.dart';
import 'package:domain/src/usecases/upload_request_entry/download_multiple_upload_request_entry_ios_interactor.dart';
import 'package:domain/src/usecases/upload_request_entry/download_upload_request_entry_interactor.dart';
import 'package:domain/src/usecases/upload_request_entry/get_all_upload_request_entries_interactor.dart';
import 'package:domain/src/usecases/upload_request_entry/remove_multiple_upload_request_entry_interactor.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_inside_viewmodel.dart';
import 'package:redux/src/store.dart';

class PendingUploadRequestInsideViewModel extends UploadRequestInsideViewModel {
  PendingUploadRequestInsideViewModel(
    Store<AppState> store,
    AppNavigation appNavigation,
    GetAllUploadRequestsInteractor getAllUploadRequestsInteractor,
    GetAllUploadRequestEntriesInteractor getAllUploadRequestEntriesInteractor,
    DownloadUploadRequestEntriesInteractor downloadEntriesInteractor,
    DownloadMultipleUploadRequestEntryIOSInteractor downloadMultipleEntryIOSInteractor,
    SearchUploadRequestEntriesInteractor searchUploadRequestEntriesInteractor,
    CopyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor copyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor,
    DeviceManager deviceManager,
    RemoveMultipleUploadRequestEntryInteractor removeMultipleUploadRequestEntryInteractor,
    UpdateMultipleUploadRequestStateInteractor updateMultipleUploadRequestStateInteractor,
  ) : super(
    store,
    appNavigation,
    getAllUploadRequestsInteractor,
    getAllUploadRequestEntriesInteractor,
    downloadEntriesInteractor,
    downloadMultipleEntryIOSInteractor,
    searchUploadRequestEntriesInteractor,
    copyMultipleFilesFromUploadRequestEntriesToMySpaceInteractor,
    deviceManager,
    removeMultipleUploadRequestEntryInteractor,
    updateMultipleUploadRequestStateInteractor);
}