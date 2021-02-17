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

import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/model/file/presentation_file.dart';
import 'package:equatable/equatable.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';

class WorkGroupFolderPresentationFile extends Equatable implements PresentationFile {
  final imagePath = getIt<AppImagePaths>();

  final WorkGroupNodeId workGroupNodeId;
  final WorkGroupNodeId parentWorkGroupNodeId;
  final WorkGroupNodeType type;
  final SharedSpaceId sharedSpaceId;
  final DateTime creationDate;
  final DateTime modificationDate;
  final String description;
  final String name;
  final Account lastAuthor;

  WorkGroupFolderPresentationFile(
    this.workGroupNodeId,
    this.parentWorkGroupNodeId,
    this.type,
    this.sharedSpaceId,
    this.creationDate,
    this.modificationDate,
    this.description,
    this.name,
    this.lastAuthor,
  );

  static WorkGroupFolderPresentationFile fromWorkGroupFolder(WorkGroupFolder workGroupFolder) {
    return WorkGroupFolderPresentationFile(
      workGroupFolder.workGroupNodeId,
      workGroupFolder.parentWorkGroupNodeId,
      workGroupFolder.type,
      workGroupFolder.sharedSpaceId,
      workGroupFolder.creationDate,
      workGroupFolder.modificationDate,
      workGroupFolder.description,
      workGroupFolder.name,
      workGroupFolder.lastAuthor,
    );
  }

  @override
  String fileName() {
    return name;
  }

  @override
  int fileSize() {
    return null;
  }

  @override
  Widget fileIcon() {
    return SvgPicture.asset(
      imagePath.icFolder,
      width: 20,
      height: 24,
      fit: BoxFit.fill,
    );
  }

  @override
  List<Object> get props => [
      workGroupNodeId,
      parentWorkGroupNodeId,
      type,
      sharedSpaceId,
      creationDate,
      modificationDate,
      description,
      name,
      lastAuthor,
  ];
}