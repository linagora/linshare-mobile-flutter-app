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

import 'dart:core';
import 'package:linshare_flutter_app/presentation/util/app_assets_path.dart';

class AppImagePaths {
  String get icArrowBack => _getImagePath('ic_arrow_back.png');
  String get icLoginLogo => _getImagePath('ic_login_logo.png');
  String get icUploadFile => _getImagePath('ic_upload_file.svg');
  String get icSharedPeople => _getImagePath('ic_shared_people.svg');
  String get icContextMenu => _getImagePath('ic_context_menu.svg');
  String get icFileTypeImage => _getImagePath('ic_file_type_image.svg');
  String get icFileTypeDoc => _getImagePath('ic_file_type_doc.svg');
  String get icFileTypeFile => _getImagePath('ic_file_type_file.svg');
  String get icFileTypePdf => _getImagePath('ic_file_type_pdf.svg');
  String get icFileTypeSheets => _getImagePath('ic_file_type_sheets.svg');
  String get icFileTypeSlide => _getImagePath('ic_file_type_slide.svg');
  String get icFileTypeVideo => _getImagePath('ic_file_type_video.svg');
  String get icFileTypeAudio => _getImagePath('ic_file_type_audio.svg');
  String get icLinShareMenu => _getImagePath('ic_linshare_menu.svg');
  String get icLinShareLogo => _getImagePath('ic_linshare_logo.svg');
  String get icUnexpectedError => _getImagePath('ic_unexpected_error.svg');
  String get icFileDownload => _getImagePath('ic_file_download.svg');
  String get icExportFile => _getImagePath('ic_export_file.svg');
  String get icContextItemShare => _getImagePath('ic_context_item_share.svg');
  String get icExitToApp => _getImagePath('ic_exit_to_app.svg');
  String get icHome => _getImagePath('ic_home.svg');
  String get icSharedSpace => _getImagePath('ic_shared_space.svg');
  String get icSharedSpaceNoWorkGroup => _getImagePath('ic_shared_space_no_workgroup.svg');
  String get icBackBlue => _getImagePath('ic_arrow_back_blue.svg');
  String get icFolder => _getImagePath('ic_folder.svg');
  String get icPlus => _getImagePath('ic_plus.svg');
  String get icSharedSpaceDisable => _getImagePath('ic_shared_space_disable.svg');
  String get icMore => _getImagePath('ic_more.svg');
  String get icPhotoLibrary => _getImagePath('ic_photo_library.svg');
  String get icSelectAll => _getImagePath('ic_select_all.svg');
  String get icClose => _getImagePath('ic_close.svg');
  String get icMoreVertical => _getImagePath('ic_more_vertical.svg');
  String get icDelete => _getImagePath('ic_delete.svg');

  String _getImagePath(String imageName) {
    return AppAssetsPath.images + imageName;
  }
}
