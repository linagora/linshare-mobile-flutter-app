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

import 'package:data/src/network/model/converter/datetime_converter.dart';
import 'package:data/src/network/model/converter/datetime_nullable_converter.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'edit_upload_request_recipient_body_request.g.dart';

@JsonSerializable()
@DatetimeConverter()
@DatetimeNullableConverter()
class EditUploadRequestRecipientBodyRequest with EquatableMixin {
  final DateTime? activationDate;
  final DateTime notificationDate;
  final bool enableNotification;
  final bool canClose;
  final bool canDeleteDocument;
  final DateTime expiryDate;
  final String locale;
  final int maxDepositSize;
  final int maxFileCount;
  final int maxFileSize;

  EditUploadRequestRecipientBodyRequest(
    this.activationDate,
    this.notificationDate,
    this.enableNotification,
    this.canClose,
    this.canDeleteDocument,
    this.expiryDate,
    this.locale,
    this.maxDepositSize,
    this.maxFileCount,
    this.maxFileSize
  );

  factory EditUploadRequestRecipientBodyRequest.fromJson(Map<String, dynamic> json) => _$EditUploadRequestRecipientBodyRequestFromJson(json);

  Map<String, dynamic> toJson() => _editUploadBodyRequestRecipientToJson(this);

  Map<String, dynamic> _editUploadBodyRequestRecipientToJson(EditUploadRequestRecipientBodyRequest instance) => <String, dynamic>{
    jsonEncode('activationDate'): const DatetimeNullableConverter().toJson(instance.activationDate),
    jsonEncode('notificationDate'): const DatetimeConverter().toJson(instance.notificationDate),
    jsonEncode('enableNotification'): jsonEncode(instance.enableNotification),
    jsonEncode('canClose'): jsonEncode(instance.canClose),
    jsonEncode('canDeleteDocument'): jsonEncode(instance.canDeleteDocument),
    jsonEncode('expiryDate'): const DatetimeConverter().toJson(instance.expiryDate),
    jsonEncode('locale'): jsonEncode(instance.locale),
    jsonEncode('maxDepositSize'): jsonEncode(instance.maxDepositSize),
    jsonEncode('maxFileCount'): jsonEncode(instance.maxFileCount),
    jsonEncode('maxFileSize'): jsonEncode(instance.maxFileSize),
  };

  @override
  List<Object?> get props => [
    activationDate,
    notificationDate,
    enableNotification,
    canClose,
    canDeleteDocument,
    expiryDate,
    locale,
    maxDepositSize,
    maxFileCount,
    maxFileSize
  ];
}

extension EditUploadRequestRecipientExtension on EditUploadRequestRecipient {
  EditUploadRequestRecipientBodyRequest toBodyRequest() {
    return EditUploadRequestRecipientBodyRequest(
      activationDate,
      notificationDate,
      enableNotification,
      canClose,
      canDeleteDocument,
      expirationDate,
      locale,
      maxDepositSize,
      maxFileCount,
      maxFileSize
    );
  }
}