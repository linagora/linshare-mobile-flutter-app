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
// <http://www.linshare.org/licenses/LinShare-LicenseAfferoGPL-v3.pdf>
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
//  3 and <http://www.linshare.org/licenses/LinShare-LicenseAfferoGPL-v3.pdf> for
//  the Additional Terms applicable to LinShare software.

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:linshare_flutter_app/presentation/model/file_size_type.dart';
import 'package:linshare_flutter_app/presentation/model/notification_language.dart';

class UploadRequestPresentation extends Equatable {

  final UploadRequestStatus? status;
  final String? activationDate;
  final bool? passwordProtected;
  final List<FileSizeType>? listMaxFileSizeType;
  final List<FileSizeType>? listTotalFileSizeType;
  final List<NotificationLanguage>? listNotificationLanguages;
  final FunctionalityTime? activationSetting;
  final FunctionalityTime? expirationSetting;
  final FunctionalityTime? notificationSetting;
  final FunctionalitySize? totalFileSizeSetting;
  final FunctionalityInteger? maxFileCountSetting;
  final FunctionalitySize? maxFileSizeSetting;
  final FunctionalityBoolean? canCloseSetting;
  final FunctionalityBoolean? canDeleteSetting;
  final FunctionalityBoolean? protectPasswordSetting;
  final FunctionalitySimple? enableReminderNotificationSetting;
  final FunctionalityLanguage? notificationLanguageSetting;

  UploadRequestPresentation({
    this.status,
    this.activationDate,
    this.passwordProtected,
    this.listMaxFileSizeType,
    this.listTotalFileSizeType,
    this.listNotificationLanguages,
    this.activationSetting,
    this.expirationSetting,
    this.notificationSetting,
    this.totalFileSizeSetting,
    this.maxFileCountSetting,
    this.maxFileSizeSetting,
    this.canCloseSetting,
    this.canDeleteSetting,
    this.protectPasswordSetting,
    this.enableReminderNotificationSetting,
    this.notificationLanguageSetting,
  });

  @override
  List<Object?> get props => [
    status,
    activationDate,
    passwordProtected,
    listMaxFileSizeType,
    listTotalFileSizeType,
    listNotificationLanguages,
    activationSetting,
    expirationSetting,
    notificationSetting,
    totalFileSizeSetting,
    maxFileCountSetting,
    maxFileSizeSetting,
    canCloseSetting,
    canDeleteSetting,
    protectPasswordSetting,
    enableReminderNotificationSetting,
    notificationLanguageSetting,
  ];
}