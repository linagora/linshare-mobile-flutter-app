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

class SortInteractor {

  final SortRepository _sortRepository;

  SortInteractor(this._sortRepository);

  Future<Either<Failure, Success>> execute<T>(List<T> listFiles, Sorter sorter) async {
    try {
      final filesSorted = await _sortRepository.sortFiles(listFiles, sorter);

      if (filesSorted is List<Document>) {
        return Right<Failure, Success>(MySpaceViewState(filesSorted.cast<Document>()));
      } else if (filesSorted is List<SharedSpaceNodeNested>) {
        if (sorter.orderScreen == OrderScreen.insideDrive) {
          return Right<Failure, Success>(GetAllWorkgroupsViewState(filesSorted.cast<SharedSpaceNodeNested>()));
        } else {
          return Right<Failure, Success>(SharedSpacesViewState(filesSorted.cast<SharedSpaceNodeNested>()));
        }
      } else if (filesSorted is List<WorkGroupNode>) {
        return Right<Failure, Success>(GetChildNodesViewState(filesSorted.cast<WorkGroupNode>()));
      } else if (filesSorted is List<ReceivedShare>) {
        return Right<Failure, Success>(GetAllReceivedShareSuccess(filesSorted.cast<ReceivedShare>()));
      } else if (filesSorted is List<UploadRequestGroup>) {
        return Right<Failure, Success>(UploadRequestGroupViewState(filesSorted.cast<UploadRequestGroup>()));
      } else {
        return Right<Failure, Success>(SortFileSuccess(filesSorted));
      }
    } catch (exception) {
      switch (sorter.orderScreen) {
        case OrderScreen.mySpace:
          return Left<Failure, Success>(MySpaceFailure(exception));
        case OrderScreen.workGroup:
          return Left<Failure, Success>(SharedSpacesFailure(exception));
        case OrderScreen.destinationPicker:
          return Left<Failure, Success>(SharedSpacesFailure(exception));
        case OrderScreen.insideDrive:
          return Left<Failure, Success>(GetAllWorkgroupsFailure(exception));
        case OrderScreen.sharedSpaceDocument:
          return Left<Failure, Success>(GetChildNodesFailure(exception));
        case OrderScreen.receivedShares:
          return Left<Failure, Success>(GetAllReceivedShareFailure(exception));
        case OrderScreen.uploadRequestGroupsCreated:
          return Left<Failure, Success>(UploadRequestGroupFailure(exception));
        case OrderScreen.uploadRequestGroupsActiveClosed:
          return Left<Failure, Success>(UploadRequestGroupFailure(exception));
        case OrderScreen.uploadRequestGroupsArchived:
          return Left<Failure, Success>(UploadRequestGroupFailure(exception));
        default:
          return Left<Failure, Success>(SortFileFailure(exception));
      }
    }
  }
}