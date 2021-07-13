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
import 'package:domain/src/model/upload_request/upload_request_id.dart';
import 'package:equatable/equatable.dart';

class UploadRequest with EquatableMixin {
  UploadRequest(
      this.uploadRequestId,
      this.owner,
      this.recipients,
      this.activationDate,
      this.modificationDate,
      this.creationDate,
      this.expiryDate,
      this.notificationDate,
      this.label,
      this.status,
      this.maxFileCount,
      this.maxDepositSize,
      this.maxFileSize,
      this.canDeleteDocument,
      this.canClose,
      this.body,
      this.pristine,
      this.protectedByPassword,
      this.extensions,
      this.enableNotification,
      this.canEditExpiryDate,
      this.collective,
      this.nbrUploadedFiles
  );

  final UploadRequestId uploadRequestId;
  final UploadRequestAccount owner;
  final Set<UploadRequestAccount> recipients;
  final DateTime activationDate;
  final DateTime modificationDate;
  final DateTime creationDate;

  // could be null
  DateTime expiryDate;
  final DateTime notificationDate;
  final String label;
  final UploadRequestStatus status;
  final int maxFileCount;
  double? maxDepositSize;
  double? maxFileSize;
  final bool canDeleteDocument;
  final bool canClose;
  String? body;
  final bool isClosed = false;
  final bool pristine;
  final bool protectedByPassword;
  final double usedSpace = 0;
  final Set<String>? extensions;
  final bool enableNotification;
  final bool canEditExpiryDate;
  final bool collective;
  final int nbrUploadedFiles;

  @override
  List<Object?> get props => [
      uploadRequestId,
      owner,
      recipients,
      activationDate,
      modificationDate,
      creationDate,
      expiryDate,
      notificationDate,
      label,
      status,
      maxFileCount,
      maxDepositSize,
      maxFileSize,
      canDeleteDocument,
      canClose,
      body,
      pristine,
      protectedByPassword,
      extensions,
      enableNotification,
      canEditExpiryDate,
      collective,
      nbrUploadedFiles
  ];
}
