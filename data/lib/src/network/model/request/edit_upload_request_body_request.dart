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

part 'edit_upload_request_body_request.g.dart';

@JsonSerializable(explicitToJson: true)
@DatetimeConverter()
@DatetimeNullableConverter()
class EditUploadRequestBodyRequest with EquatableMixin {
  final DateTime? activationDate;
  final DateTime? notificationDate;
  final bool enableNotification;
  final String? body;
  final bool? canClose;
  final bool? canDelete;
  final DateTime? expiryDate;
  final String label;
  final String locale;
  final int? maxDepositSize;
  final int? maxFileCount;
  final int? maxFileSize;

  EditUploadRequestBodyRequest(
    this.activationDate,
    this.notificationDate,
    this.enableNotification,
    this.body,
    this.canClose,
    this.canDelete,
    this.expiryDate,
    this.label,
    this.locale,
    this.maxDepositSize,
    this.maxFileCount,
    this.maxFileSize
  );

  factory EditUploadRequestBodyRequest.fromJson(Map<String, dynamic> json) => _$EditUploadRequestBodyRequestFromJson(json);

  Map<String, dynamic> toJson() => _editUploadBodyRequestToJson(this);

  Map<String, dynamic> _editUploadBodyRequestToJson(EditUploadRequestBodyRequest instance) => <String, dynamic>{
    if (instance.activationDate != null) jsonEncode('activationDate'): const DatetimeNullableConverter().toJson(instance.activationDate),
    if (instance.notificationDate != null) jsonEncode('notificationDate'): const DatetimeNullableConverter().toJson(instance.notificationDate),
    jsonEncode('enableNotification'): jsonEncode(instance.enableNotification),
    jsonEncode('body'): jsonEncode(instance.body),
    if (instance.canClose != null) jsonEncode('canClose'): jsonEncode(instance.canClose),
    if (instance.canDelete != null) jsonEncode('canDelete'): jsonEncode(instance.canDelete),
    if (instance.expiryDate != null) jsonEncode('expiryDate'): const DatetimeNullableConverter().toJson(instance.expiryDate),
    jsonEncode('label'): jsonEncode(instance.label),
    jsonEncode('locale'): jsonEncode(instance.locale),
    if (instance.maxDepositSize != null) jsonEncode('maxDepositSize'): jsonEncode(instance.maxDepositSize),
    if (instance.maxFileCount != null) jsonEncode('maxFileCount'): jsonEncode(instance.maxFileCount),
    if (instance.maxFileSize != null) jsonEncode('maxFileSize'): jsonEncode(instance.maxFileSize),
  };

  @override
  List<Object?> get props => [
    activationDate,
    notificationDate,
    enableNotification,
    body,
    canClose,
    canDelete,
    expiryDate,
    label,
    locale,
    maxDepositSize,
    maxFileCount,
    maxFileSize
  ];
}

extension EditUploadRequestExtension on EditUploadRequest {
  EditUploadRequestBodyRequest toBodyRequest() {
    return EditUploadRequestBodyRequest(
      activationDate,
      notificationDate,
      enableNotification,
      body,
      canClose,
      canDelete,
      expirationDate,
      label,
      locale,
      maxDepositSize,
      maxFileCount,
      maxFileSize
    );
  }
}