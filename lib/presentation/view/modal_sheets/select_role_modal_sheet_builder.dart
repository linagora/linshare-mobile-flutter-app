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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/shared_space_role_name_extension.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';

typedef OnSelectActionClick = void Function(SharedSpaceRoleName role);

class SelectRoleModalSheetBuilder {
  final responsiveUtils = getIt<ResponsiveUtils>();

  @protected final Key key;
  @protected final SharedSpaceRoleName selectedRole;
  @protected final List<SharedSpaceRoleName> listRoles;
  @protected OnSelectActionClick? _onSelectActionClick;

  Widget? _header;

  SelectRoleModalSheetBuilder({required this.key, required this.selectedRole, required this.listRoles});

  SelectRoleModalSheetBuilder onConfirmAction(OnSelectActionClick onConfirmActionClick) {
    _onSelectActionClick = onConfirmActionClick;
    return this;
  }

  SelectRoleModalSheetBuilder addHeader(Widget header) {
    _header = header;
    return this;
  }

  RoundedRectangleBorder _shape() {
    return RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0)
        )
    );
  }

  BoxDecoration _decoration(BuildContext context) {
    return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20.0),
            topRight: const Radius.circular(20.0)));
  }

  void show(context) {
    showModalBottomSheet(
        useRootNavigator: true,
        shape: _shape(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: SingleChildScrollView(
                  child: Container(
                      key: key,
                      padding: EdgeInsets.all(20),
                      margin: responsiveUtils
                          .getMarginContextMenuForScreen(context),
                      decoration: _decoration(context),
                      child: GestureDetector(
                          onTap: () => {},
                          child: Wrap(
                            children: [
                              if(_header != null) _header!,
                              if(_header != null) Divider(),
                              ...listRoles
                                  .map((role) => _getSelectingRoleTile(context, role, selectedRole))
                                  .toList()
                            ],
                          )
                      )
                  )
              )
          );
        }
    );
  }

  ListTile _getSelectingRoleTile(BuildContext context, SharedSpaceRoleName role, SharedSpaceRoleName selectedRole) {
    return ListTile(
      title: Text(role.getRoleName(context),
          style: TextStyle(
            color: selectedRole == role
                ? AppColor.primaryColor
                : AppColor.addSharedSpaceMemberRoleTileColor,
            fontSize: 16,
          )),
      leading: selectedRole == role
          ? Icon(Icons.check, color: AppColor.primaryColor)
          : SizedBox(),
      onTap: () {
        if (_onSelectActionClick != null) {
          _onSelectActionClick?.call(role);
        }
      },
    );
  }
}
