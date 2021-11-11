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
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_type.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_ui_type.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_widget.dart';
import 'package:rxdart/rxdart.dart';

import '../../util/data_structure/stack.dart' as structure;

typedef OnBackSharedSpaceClickedCallback = void Function();
typedef OnBackToInsideDriveClickedCallback = void Function(SharedSpaceNodeNested);
typedef OnNodeClickedCallback = void Function(WorkGroupNode clickedNode);

class SharedSpaceDocumentNavigatorWidget extends StatefulWidget {

  final SharedSpaceNodeNested sharedSpaceNodeNested;
  final SharedSpaceNodeNested? drive;
  final SharedSpaceDocumentUIType sharedSpaceDocumentUIType;
  final OnBackSharedSpaceClickedCallback? onBackSharedSpaceClickedCallback;
  final OnBackToInsideDriveClickedCallback? onBackToInsideDriveClickedCallback;

  final BehaviorSubject<SharedSpaceDocumentArguments>? currentNodeObservable;

  SharedSpaceDocumentNavigatorWidget(
    Key key,
    this.sharedSpaceNodeNested,
    {
      this.onBackSharedSpaceClickedCallback,
      this.onBackToInsideDriveClickedCallback,
      this.drive,
      this.sharedSpaceDocumentUIType = SharedSpaceDocumentUIType.sharedSpace,
      this.currentNodeObservable
    }
  ) : super(key: key);

  @override
  SharedSpaceDocumentNavigatorWidgetState createState() => SharedSpaceDocumentNavigatorWidgetState();
}

class SharedSpaceDocumentNavigatorWidgetState extends State<SharedSpaceDocumentNavigatorWidget> {

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  final structure.Stack<SharedSpaceDocumentArguments> argumentStack = structure.Stack();
  SharedSpaceDocumentArguments? get currentPageData => argumentStack.peek();

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
          final rootArgs = SharedSpaceDocumentArguments(
              SharedSpaceDocumentType.root,
              widget.sharedSpaceNodeNested,
              drive: widget.drive,
              documentUIType: widget.sharedSpaceDocumentUIType
          );

          argumentStack.push(rootArgs);
          if (widget.currentNodeObservable != null) {
            widget.currentNodeObservable?.add(rootArgs);
          }
          return _generateSharedSpaceDocumentNode(context, rootArgs);
        }
      )
    );
  }

  PageRoute _generateSharedSpaceDocumentNode(BuildContext context, SharedSpaceDocumentArguments args) {
    return PageRouteBuilder(
      pageBuilder: (context, _, __) => SharedSpaceDocumentWidget(
        () => wantToBack(),
        (workGroupNode) => _onClickWorkGroupFolder(context, workGroupNode),
        widget.sharedSpaceNodeNested.sharedSpaceRole,
        sharedSpaceDocumentUIType: widget.sharedSpaceDocumentUIType
      ),
      settings: RouteSettings(arguments: args),
      transitionDuration: Duration(seconds: 0),
      reverseTransitionDuration: Duration(seconds: 0),
    );
  }

  void _onClickWorkGroupFolder(BuildContext context, WorkGroupNode workGroupNode) {
    final newArgs = SharedSpaceDocumentArguments(
      SharedSpaceDocumentType.children,
      widget.sharedSpaceNodeNested,
      workGroupFolder: workGroupNode as WorkGroupFolder,
      drive: widget.drive,
      documentUIType: widget.sharedSpaceDocumentUIType);

    argumentStack.push(newArgs);
    if (widget.currentNodeObservable != null) {
      widget.currentNodeObservable?.add(newArgs);
    }
    navigatorKey.currentState?.pushAndRemoveUntil(
      _generateSharedSpaceDocumentNode(context, newArgs),
      (Route<dynamic> route) => false
    );
  }

  void wantToBack() {
    argumentStack.pop();
    if (widget.currentNodeObservable != null && currentPageData != null) {
      widget.currentNodeObservable!.add(currentPageData!);
    }
    if (!argumentStack.isEmpty && currentPageData != null) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        _generateSharedSpaceDocumentNode(context, currentPageData!),
        (Route<dynamic> route) => false
      );
    } else {
      if (widget.drive != null) {
        if (widget.onBackToInsideDriveClickedCallback != null) {
          widget.onBackToInsideDriveClickedCallback!(widget.drive!);
        }
      } else {
        if (widget.onBackSharedSpaceClickedCallback != null) {
          widget.onBackSharedSpaceClickedCallback!();
        }
      }
    }
  }
}