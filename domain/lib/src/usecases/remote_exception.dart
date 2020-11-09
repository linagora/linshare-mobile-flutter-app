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

import 'package:equatable/equatable.dart';

abstract class RemoteException extends Equatable implements Exception {
  static final missingRequiredFields = 'Missing required fields';
  static final serverNotFound = 'Server not found';
  static final internalServerError = 'Internal server error';
  static final connectError = 'Connect error';
  static final noPermissionError = 'No permission error';
  static final dataNotFoundError = 'Data not found error';

  final String message;

  RemoteException(this.message);
}

class MissingRequiredFields extends RemoteException {
  MissingRequiredFields() : super(RemoteException.missingRequiredFields);

  @override
  List<Object> get props => [];
}

class ServerNotFound extends RemoteException {
  ServerNotFound() : super(RemoteException.serverNotFound);

  @override
  List<Object> get props => [];
}

class InternalServerError extends RemoteException {
  InternalServerError() : super(RemoteException.internalServerError);

  @override
  List<Object> get props => [];
}

class ConnectError extends RemoteException {
  ConnectError() : super(RemoteException.connectError);

  @override
  List<Object> get props => [];
}

class NoPermission extends RemoteException {
  NoPermission() : super(RemoteException.noPermissionError);

  @override
  List<Object> get props => [];
}

class DataNotFound extends RemoteException {
  DataNotFound() : super(RemoteException.dataNotFoundError);

  @override
  List<Object> get props => [];
}

class UnknownError extends RemoteException {
  UnknownError(String message) : super(message);

  @override
  List<Object> get props => [];
}
