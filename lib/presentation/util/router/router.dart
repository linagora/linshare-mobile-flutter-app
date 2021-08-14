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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/util/router/route_paths.dart';
import 'package:linshare_flutter_app/presentation/view/transparent_page_route.dart';
import 'package:linshare_flutter_app/presentation/widget/biometric_authentication/biometric_authentication_login_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/biometric_authentication/biometric_authentication_setting_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/authentication/authentication_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/current_uploads/current_uploads_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/enter_otp/enter_otp_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/home/home_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/login/login_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/received_share_details/received_share_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/second_factor_authentication/second_factor_authentication_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/myspace/document_details/document_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/add_shared_space_member/add_shared_space_member_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_details/shared_space_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_details/shared_space_node_details_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_node_versions/shared_space_node_versions_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_file_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_creation/upload_request_creation_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_group/add_recipient_upload_request_group/add_recipients_upload_request_group_widget.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RoutePaths.loginRoute:
      return MaterialPageRoute(builder: (context) => getIt<LoginWidget>(), settings: settings);
    case RoutePaths.homeRoute:
      return MaterialPageRoute(builder: (context) => getIt<HomeWidget>(), settings: settings);
    case RoutePaths.uploadDocumentRoute:
      return MaterialPageRoute(builder: (context) => getIt<UploadFileWidget>(), settings: settings);
    case RoutePaths.currentUploads:
      return MaterialPageRoute(builder: (context) => getIt<CurrentUploadsWidget>(), settings: settings);
    case RoutePaths.destinationPicker:
      return TransparentPageRoute(builder: (context) => getIt<DestinationPickerWidget>(), settings: settings);
    case RoutePaths.sharedSpaceDetails:
      return MaterialPageRoute(builder: (context) => getIt<SharedSpaceDetailsWidget>(), settings: settings);
    case RoutePaths.authentication:
      return MaterialPageRoute(builder: (context) => getIt<AuthenticationWidget>(), settings: settings);
    case RoutePaths.enter_otp:
      return MaterialPageRoute(builder: (context) => getIt<EnterOTPWidget>(), settings: settings);
    case RoutePaths.second_factor_authentication:
      return MaterialPageRoute(builder: (context) => getIt<SecondFactorAuthenticationWidget>(), settings: settings);
    case RoutePaths.addSharedSpaceMember:
      return MaterialPageRoute(builder: (context) => getIt<AddSharedSpaceMemberWidget>(), settings: settings);
    case RoutePaths.documentDetails:
      return MaterialPageRoute(builder: (context) => getIt<DocumentDetailsWidget>(), settings: settings);
    case RoutePaths.sharedSpaceNodeDetails:
      return MaterialPageRoute(builder: (context) => getIt<SharedSpaceNodeDetailsWidget>(), settings: settings);
    case RoutePaths.biometricAuthenticationSetting:
      return MaterialPageRoute(builder: (context) => getIt<BiometricAuthenticationSettingWidget>(), settings: settings);
    case RoutePaths.sharedSpaceNodeVersions:
      return MaterialPageRoute(builder: (context) => getIt<SharedSpaceNodeVersionsWidget>(), settings: settings);
    case RoutePaths.biometricAuthenticationLogin:
      return MaterialPageRoute(builder: (context) => getIt<BiometricAuthenticationLoginWidget>(), settings: settings);
    case RoutePaths.createUploadRequest:
      return MaterialPageRoute(builder: (context) => getIt<UploadRequestCreationWidget>(), settings: settings);
    case RoutePaths.receivedShareDetails:
      return MaterialPageRoute(builder: (context) => getIt<ReceivedShareDetailsWidget>(), settings: settings);
    case RoutePaths.addRecipientsUploadRequestGroup:
      return MaterialPageRoute(builder: (context) => getIt<AddRecipientsUploadRequestGroupWidget>(), settings: settings);
    default:
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('No path for ${settings.name}'),
          ),
        ),
      );
  }
}
