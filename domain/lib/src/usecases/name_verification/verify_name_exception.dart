// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2021 LINAGORA
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
//

import 'package:domain/domain.dart';

abstract class VerifyNameException extends RemoteException {
  static const DuplicatedName = 'The name already exists!';
  static const EmptyName = 'The name cannot be empty!';
  static const NameContainSpecialCharacter = 'The name cannot contain special characters';
  static const NameContainLastDot = 'The name cannot finishes by character "."';
  static const EmptyLoginEmail = 'The email cannot be empty!';
  static const LoginEmailInvalid = 'The email is invalid!';
  static const EmailNotAvailable = 'The email is not available';
  static const EmptyLoginPassword = 'The password cannot be empty!';
  static const EmptyLoginEmailPassword = 'The email and password cannot be empty!';
  static const EmptyLoginUrl = 'The url cannot be empty!';
  static const PasswordContainSpecialCharacter = 'The password cannot contain special characters';
  static const EmptySignUpAllName = 'The name and surname cannot be empty!';
  static const EmptySignUpSurname = 'The surname cannot be empty!';
  static const EmptySignUpName = 'The signup name cannot be empty!';

  VerifyNameException(String message) : super(message);
}

class EmptyNameException extends VerifyNameException {
  EmptyNameException() : super(VerifyNameException.EmptyName);

  @override
  List<Object> get props => [];
}

class DuplicatedNameException extends VerifyNameException {
  DuplicatedNameException() : super(VerifyNameException.DuplicatedName);

  @override
  List<Object> get props => [];
}

class SpecialCharacterException extends VerifyNameException {
  SpecialCharacterException() : super(VerifyNameException.NameContainSpecialCharacter);

  @override
  List<Object> get props => [];
}

class LastDotException extends VerifyNameException {
  LastDotException() : super(VerifyNameException.NameContainLastDot);

  @override
  List<Object> get props => [];
}

class EmptyLoginEmailException extends VerifyNameException {
  EmptyLoginEmailException() : super(VerifyNameException.EmptyLoginEmail);

  @override
  List<Object> get props => [];
}

class LoginEmailInvalidException extends VerifyNameException {
  LoginEmailInvalidException() : super(VerifyNameException.LoginEmailInvalid);

  @override
  List<Object> get props => [];
}

class EmailNotAvailableException extends VerifyNameException {
  EmailNotAvailableException() : super(VerifyNameException.EmailNotAvailable);

  @override
  List<Object> get props => [];
}

class EmptyLoginPasswordException extends VerifyNameException {
  EmptyLoginPasswordException() : super(VerifyNameException.EmptyLoginPassword);

  @override
  List<Object> get props => [];
}

class EmptyLoginEmailAndPasswordException extends VerifyNameException {
  EmptyLoginEmailAndPasswordException() : super(VerifyNameException.EmptyLoginEmailPassword);

  @override
  List<Object> get props => [];
}

class EmptyLoginUrlException extends VerifyNameException {
  EmptyLoginUrlException() : super(VerifyNameException.EmptyLoginUrl);

  @override
  List<Object> get props => [];
}

class PasswordSpecialCharacterException extends VerifyNameException {
  PasswordSpecialCharacterException() : super(VerifyNameException.PasswordContainSpecialCharacter);

  @override
  List<Object> get props => [];
}

class EmptySignUpSurnameException extends VerifyNameException {
  EmptySignUpSurnameException() : super(VerifyNameException.EmptySignUpSurname);

  @override
  List<Object> get props => [];
}

class EmptySignUpAllNameException extends VerifyNameException {
  EmptySignUpAllNameException() : super(VerifyNameException.EmptySignUpAllName);

  @override
  List<Object> get props => [];
}

class EmptySignUpNameException extends VerifyNameException {
  EmptySignUpNameException() : super(VerifyNameException.EmptySignUpName);

  @override
  List<Object> get props => [];
}
