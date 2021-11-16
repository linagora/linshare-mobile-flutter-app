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

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';

class UploadRequestViewState extends ViewState {
  final List<UploadRequest> uploadRequests;

  UploadRequestViewState(this.uploadRequests);

  @override
  List<Object> get props => [uploadRequests];
}

class UploadRequestFailure extends FeatureFailure {
  final exception;

  UploadRequestFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class UpdateUploadRequestStateViewState extends ViewState {
  final UploadRequest uploadRequest;
  UpdateUploadRequestStateViewState(this.uploadRequest);

  @override
  List<Object?> get props => [uploadRequest];
}

class UpdateUploadRequestStateFailure extends FeatureFailure {
  final exception;

  UpdateUploadRequestStateFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class UpdateUploadRequestAllSuccessViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  UpdateUploadRequestAllSuccessViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class UpdateUploadRequestAllFailureViewState extends FeatureFailure {
  final List<Either<Failure, Success>> resultList;

  UpdateUploadRequestAllFailureViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class UpdateUploadRequestHasSomeFailedViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  UpdateUploadRequestHasSomeFailedViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class GetUploadRequestViewState extends ViewState {
  final UploadRequest uploadRequest;

  GetUploadRequestViewState(this.uploadRequest);

  @override
  List<Object?> get props => [uploadRequest];
}

class GetUploadRequestFailure extends FeatureFailure {
  final exception;

  GetUploadRequestFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class EditUploadRequestRecipientViewState extends ViewState {
  final UploadRequest uploadRequest;

  EditUploadRequestRecipientViewState(this.uploadRequest);

  @override
  List<Object?> get props => [uploadRequest];
}

class EditUploadRequestRecipientFailure extends FeatureFailure {
  final exception;

  EditUploadRequestRecipientFailure(this.exception);

  @override
  List<Object> get props => [exception];
}