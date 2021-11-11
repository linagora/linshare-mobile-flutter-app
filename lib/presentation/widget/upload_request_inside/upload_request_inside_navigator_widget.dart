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

import 'package:domain/domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/archived/archived_upload_request_inside_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/pending/pending_upload_request_inside_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_document_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_request_inside/upload_request_document_type.dart';

import '../../util/data_structure/stack.dart' as structure;
import 'active_close/active_closed_upload_request_inside_widget.dart';

typedef OnBackUploadRequestClickedCallback = void Function();
typedef OnUploadRequestClickedCallback = void Function(UploadRequest uploadRequest);

class UploadRequestNavigatorWidget extends StatefulWidget {

  final UploadRequestGroup uploadRequestGroup;
  final OnBackUploadRequestClickedCallback? onBackUploadRequestClickedCallback;

  UploadRequestNavigatorWidget(
      Key key,
      this.uploadRequestGroup,
      {this.onBackUploadRequestClickedCallback}
  ) : super(key: key);

  @override
  UploadRequestNavigatorWidgetState createState() => UploadRequestNavigatorWidgetState();
}

class UploadRequestNavigatorWidgetState extends State<UploadRequestNavigatorWidget> {

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  final structure.Stack<UploadRequestArguments> argumentStack = structure.Stack();
  UploadRequestArguments? get currentPageData => argumentStack.peek();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        wantToBack();
        return false;
      },
      child: Navigator(
        key: navigatorKey,
        onGenerateRoute: (settings) {
          final rootArgs = UploadRequestArguments(
              widget.uploadRequestGroup.collective
                  ? UploadRequestDocumentType.files
                  : UploadRequestDocumentType.recipients,
              widget.uploadRequestGroup,
              null
          );

          argumentStack.push(rootArgs);
          return _generateUploadRequestPageRoute(context, rootArgs);
        }
      )
    );
  }

  PageRoute _generateUploadRequestPageRoute(BuildContext context, UploadRequestArguments args) {
    return PageRouteBuilder(
      pageBuilder: (context, _, __) => _generateUploadRequestWidget(context, args),
      settings: RouteSettings(arguments: args),
      transitionDuration: Duration(seconds: 0),
      reverseTransitionDuration: Duration(seconds: 0),
    );
  }

  void _onClickUploadRequest(BuildContext context, UploadRequest selectedUploadRequest) {
    final newArgs = UploadRequestArguments(
      UploadRequestDocumentType.files,
      widget.uploadRequestGroup,
      selectedUploadRequest);

    argumentStack.push(newArgs);
    navigatorKey.currentState?.pushAndRemoveUntil(
      _generateUploadRequestPageRoute(context, newArgs),
      (Route<dynamic> route) => false
    );
  }

  void wantToBack() {
    argumentStack.pop();
    if (!argumentStack.isEmpty && currentPageData != null) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        _generateUploadRequestPageRoute(context, currentPageData!),
        (Route<dynamic> route) => false
      );
    } else if(widget.onBackUploadRequestClickedCallback != null) {
      widget.onBackUploadRequestClickedCallback!();
    }
  }

  Widget _generateUploadRequestWidget(BuildContext context, UploadRequestArguments args) {
    if (_validateActiveCloseUploadRequestInsideRoute(args.uploadRequestGroup.status)) {
      return ActiveClosedUploadRequestInsideWidget(
        wantToBack,
        (uploadRequest) => _onClickUploadRequest(context, uploadRequest));
    } else if (_validatePendingUploadRequestInsideRoute(args.uploadRequestGroup.status)) {
      return PendingUploadRequestInsideWidget(
        () => wantToBack(),
        (uploadRequest) => _onClickUploadRequest(context, uploadRequest));
    } else if (_validateArchivedUploadRequestInsideRoute(args.uploadRequestGroup.status)) {
      return ArchivedUploadRequestInsideWidget(
        () => wantToBack(),
        (uploadRequest) => _onClickUploadRequest(context, uploadRequest));
    } else {
      return SizedBox.shrink();
    }
  }

  bool _validateActiveCloseUploadRequestInsideRoute(UploadRequestStatus uploadRequestStatus) {
    return (uploadRequestStatus == UploadRequestStatus.ENABLED
      || uploadRequestStatus == UploadRequestStatus.CLOSED);
  }

  bool _validatePendingUploadRequestInsideRoute(UploadRequestStatus uploadRequestStatus) {
    return uploadRequestStatus == UploadRequestStatus.CREATED;
  }

  bool _validateArchivedUploadRequestInsideRoute(UploadRequestStatus uploadRequestStatus) {
    return uploadRequestStatus == UploadRequestStatus.ARCHIVED;
  }
}