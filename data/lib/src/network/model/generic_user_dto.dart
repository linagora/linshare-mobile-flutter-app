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

import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:data/src/network/model/converter/user_id_nullable_converter.dart';
import 'package:domain/domain.dart';

class GenericUserDto {
  String? _mail;
    String? get mail => _mail;

  Option<String> _lastName = none();
  Option<String> get lastName => _lastName;

  Option<String> _firstName = none();
  Option<String> get firstName => _firstName;

  UserId? userId;

  GenericUserDto(String mail, {Option<String>? lastName, Option<String>? firstName, UserId? userId}) {
    _mail = mail;
    _lastName = lastName ?? none();
    _firstName = firstName ?? none();
    this.userId = userId;
  }

  factory GenericUserDto.fromJson(Map<String, dynamic> json) {
    return GenericUserDto(
      json['mail'] as String,
      lastName: optionOf(json['lastName'] as String?),
      firstName: optionOf(json['firstName'] as String?),
      userId: UserIdNullableConverter().fromJson(json['uuid'] as String?)
    );
  }

  Map<String, dynamic> toJson() =>
    {
      jsonEncode('mail'): jsonEncode(_mail),
      jsonEncode('lastName'): jsonEncode(lastName.fold(() => '', (lastName) => lastName)),
      jsonEncode('firstName'): jsonEncode(firstName.fold(() => '', (firstName) => firstName))
    };
}


extension GenericUserDtoExtension on GenericUserDto {
  GenericUser toGenericUser() {
    return GenericUser(_mail ?? '', firstName: _firstName,
        lastName: _lastName,
        userId: userId);
  }
}
