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
//

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/node_surfing_type.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfing_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfling_arguments.dart';
import 'package:rxdart/rxdart.dart';
import 'workgroup_nodes_surfing_widget.dart';
import '../../../util/data_structure/stack.dart' as structure;


class WorkGroupNodesSurfingNavigator extends StatefulWidget {
  WorkGroupNodesSurfingNavigator(
      Key key,
      this.sharedSpaceNodeNested,
      this.onBackClickedCallback,
      {this.nodeSurfingType = NodeSurfingType.normal,
      this.currentNodeObservable})
      : super(key: key);

  final SharedSpaceNodeNested sharedSpaceNodeNested;
  final OnBackClickedCallback onBackClickedCallback;
  final NodeSurfingType nodeSurfingType;
  final structure.Stack<WorkGroupNodesSurfingArguments> pagesStack = structure.Stack();
  WorkGroupNodesSurfingArguments get currentPageData => pagesStack.peek();
  final BehaviorSubject<WorkGroupNodesSurfingArguments> currentNodeObservable;

  final WorkGroupNodesSurfingNavigatorState _state = WorkGroupNodesSurfingNavigatorState();

  @override
  WorkGroupNodesSurfingNavigatorState createState() => _state;

  void nodeSurfingNavigateBack() => _state.wantToBack();
}

class WorkGroupNodesSurfingNavigatorState extends State<WorkGroupNodesSurfingNavigator> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        wantToBack();
        return false;
      },
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) {
          final rootArgs = WorkGroupNodesSurfingArguments(
              FolderNodeType.root,
              widget.sharedSpaceNodeNested);
          widget.pagesStack.push(rootArgs);
          if (widget.currentNodeObservable != null) {
            widget.currentNodeObservable.add(rootArgs);
          }
          return _generateNewPage(
            context,
            rootArgs,
          );
        },
      ),
    );
  }

  PageRoute _generateNewPage(
    BuildContext context,
    WorkGroupNodesSurfingArguments args,
  ) {
    return PageRouteBuilder(
      pageBuilder: (context, _, __) {
        return WorkGroupNodesSurfingWidget(
          (clickedNode) {
            if (clickedNode is WorkGroupFolder) {
              final pageArgs = WorkGroupNodesSurfingArguments(
                  FolderNodeType.normal,
                  widget.sharedSpaceNodeNested,
                  folder: clickedNode);
              widget.pagesStack.push(pageArgs);
              if (widget.currentNodeObservable != null) {
                widget.currentNodeObservable.add(pageArgs);
              }
              Navigator.push(
                  context,
                  _generateNewPage(
                    context,
                    pageArgs,
                  ));
            }
          },
          () {
            wantToBack();
          },
          nodeSurfingType: widget.nodeSurfingType,
        );
      },
      settings: RouteSettings(arguments: args),
      transitionDuration: Duration(seconds: 0),
      reverseTransitionDuration: Duration(seconds: 0),
    );
  }

  void wantToBack() {
    if (_navigatorKey.currentState.canPop()) {
      _navigatorKey.currentState.pop();
    } else {
      widget.onBackClickedCallback();
    }
    widget.pagesStack.pop();
    if (widget.currentNodeObservable != null) {
      widget.currentNodeObservable.add(widget.currentPageData);
    }
  }

}

typedef OnNodeClickedCallback = void Function(WorkGroupNode clickedNode);

typedef OnBackClickedCallback = void Function();
