/*
 * LinShare is an open source filesharing software, part of the LinPKI software
 * suite, developed by Linagora.
 *
 * Copyright (C) 2021 LINAGORA
 *
 * This program is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Affero General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version,
 * provided you comply with the Additional Terms applicable for LinShare software by
 * Linagora pursuant to Section 7 of the GNU Affero General Public License,
 * subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
 * display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
 * the words “You are using the Free and Open Source version of LinShare™, powered by
 * Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
 * offer!”. You must also retain the latter notice in all asynchronous messages such as
 * e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
 * http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
 * infringing Linagora intellectual property rights over its trademarks and commercial
 * brands. Other Additional Terms apply, see
 * <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
 * for more details.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
 * more details.
 * You should have received a copy of the GNU Affero General Public License and its
 * applicable Additional Terms for LinShare along with this program. If not, see
 * <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
 *  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
 *  the Additional Terms applicable to LinShare software.
 */

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';

class GetAllReceivedShareSuccess extends ViewState {
  final List<ReceivedShare> receivedShares;

  GetAllReceivedShareSuccess(this.receivedShares);

  @override
  List<Object> get props => [receivedShares];
}

class GetAllReceivedShareFailure extends FeatureFailure {
  final dynamic exception;

  GetAllReceivedShareFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class CopyMultipleToMySpaceFromReceivedSharesAllSuccessViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  CopyMultipleToMySpaceFromReceivedSharesAllSuccessViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class CopyMultipleToMySpaceFromReceivedSharesHasSomeFilesViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  CopyMultipleToMySpaceFromReceivedSharesHasSomeFilesViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class CopyMultipleToMySpaceFromReceivedSharesAllFailure extends FeatureFailure {
  final List<Either<Failure, Success>> resultList;

  CopyMultipleToMySpaceFromReceivedSharesAllFailure(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class ReceivedShareContextMenuItemViewState extends ViewState {
  final ReceivedShare share;

  ReceivedShareContextMenuItemViewState(this.share);

  @override
  List<Object> get props => [share];
}

class DownloadReceivedShareViewState extends ViewState {
  final List<DownloadTaskId> taskIds;

  DownloadReceivedShareViewState(this.taskIds);

  @override
  List<Object> get props => [taskIds];
}

class DownloadReceivedShareFailure extends FeatureFailure {
  final dynamic downloadFileException;

  DownloadReceivedShareFailure(this.downloadFileException);

  @override
  List<Object> get props => [downloadFileException];
}

class GetReceivedShareSuccess extends ViewState {
  final ReceivedShare receivedShare;

  GetReceivedShareSuccess(this.receivedShare);

  @override
  List<Object> get props => [receivedShare];
}

class GetReceivedShareFailure extends FeatureFailure {
  final dynamic exception;

  GetReceivedShareFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class RemoveReceivedShareViewState extends ViewState {
  final ReceivedShare receivedShare;

  RemoveReceivedShareViewState(this.receivedShare);

  @override
  List<Object> get props => [receivedShare];
}

class RemoveReceivedShareFailure extends FeatureFailure {
  final exception;

  RemoveReceivedShareFailure(this.exception);

  @override
  List<Object> get props => [exception];
}

class RemoveMultipleReceivedSharesAllSuccessViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  RemoveMultipleReceivedSharesAllSuccessViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class RemoveMultipleReceivedSharesHasSomeFilesFailedViewState extends ViewState {
  final List<Either<Failure, Success>> resultList;

  RemoveMultipleReceivedSharesHasSomeFilesFailedViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}

class RemoveMultipleReceivedSharesAllFailureViewState extends FeatureFailure {
  final List<Either<Failure, Success>> resultList;

  RemoveMultipleReceivedSharesAllFailureViewState(this.resultList);

  @override
  List<Object> get props => [resultList];
}