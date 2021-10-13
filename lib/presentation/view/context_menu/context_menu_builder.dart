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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';

class ContextMenuBuilder {
  final imagePath = getIt<AppImagePaths>();
  final responsiveUtils = getIt<ResponsiveUtils>();

  final BuildContext _context;
  final List<Widget> _actionTiles = [];

  final bool areTilesHorizontal;

  Widget? _header;
  Widget? _footer;

  ContextMenuBuilder(this._context, { this.areTilesHorizontal = false });

  ContextMenuBuilder addTiles(List<Widget> tiles) {
    _actionTiles.addAll(tiles);
    return this;
  }

  ContextMenuBuilder addHeader(Widget header) {
    _header = header;
    return this;
  }

  ContextMenuBuilder addFooter(Widget footer) {
    _footer = footer;
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

  void build() {
    showModalBottomSheet(
      useRootNavigator: true,
      shape: _shape(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: _context,
      builder: (BuildContext buildContext) {
        return GestureDetector(
          onTap: () => Navigator.of(buildContext).pop(),
          child: SingleChildScrollView(
            child: Container(
              margin: responsiveUtils.getMarginContextMenuForScreen(buildContext),
              decoration: _decoration(buildContext),
              child: GestureDetector(
                onTap: () => {},
                child: Wrap(
                  children: [
                    _header ?? SizedBox.shrink(),
                    Divider(),
                    areTilesHorizontal
                      ? Row(children: [
                          ..._actionTiles,
                          _actionTiles.isNotEmpty && _footer != null ? Divider() : SizedBox.shrink()
                        ])
                      : Padding(
                          padding: _footer == null ? EdgeInsets.only(bottom: 10.0) : EdgeInsets.zero,
                          child: Column(children: [
                              ..._actionTiles,
                              _actionTiles.isNotEmpty && _footer != null ? Divider() : SizedBox.shrink()
                            ]),
                      ),
                    _footer != null
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Wrap(children: [_footer ?? SizedBox.shrink()]))
                      : SizedBox.shrink()
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}