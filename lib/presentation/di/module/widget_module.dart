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

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/local_file_picker.dart';
import 'package:linshare_flutter_app/presentation/util/router/app_navigation.dart';
import 'package:linshare_flutter_app/presentation/widget/home/home_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/home/home_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/initialize/initialize_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/initialize_get_it/initialize_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/login/login_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/login/login_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/myspace/my_space_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/myspace/my_space_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_manager.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_widget.dart';
import 'package:redux/redux.dart';

class WidgetModule {
  WidgetModule() {
    _provideLoginComponent();
    _provideHomeComponent();
    _provideMySpaceComponent();
    _provideUploadFileComponent();
    _provideInitializeComponent();
  }

  void _provideLoginComponent() {
    getIt.registerFactory(() => LoginWidget());
    getIt.registerFactory(() => LoginViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<CreatePermanentTokenInteractor>(),
      getIt.get<AppNavigation>()
    ));
  }

  void _provideHomeComponent() {
    getIt.registerFactory(() => HomeWidget());
    getIt.registerFactory(() => HomeViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<AppNavigation>(),
      getIt.get<UploadFileManager>()
    ));
  }

  void _provideMySpaceComponent() {
    getIt.registerFactory(() => MySpaceWidget());
    getIt.registerFactory(() => MySpaceViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<LocalFilePicker>(),
      getIt.get<AppNavigation>()
    ));
  }

  void _provideUploadFileComponent() {
    getIt.registerFactory(() => UploadFileWidget());
    getIt.registerFactory(() => UploadFileViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<AppNavigation>(),
      getIt.get<UploadFileInteractor>()
    ));
  }

  void _provideInitializeComponent() {
    getIt.registerFactory(() => InitializeWidget());
    getIt.registerFactory(() => InitializeViewModel(
      getIt.get<Store<AppState>>(),
      getIt.get<GetCredentialInteractor>(),
      getIt.get<AppNavigation>(),
      getIt.get<DynamicUrlInterceptors>(),
      getIt.get<RetryAuthenticationInterceptors>(),
      getIt.get<UploadFileManager>()
    ));
  }
}
