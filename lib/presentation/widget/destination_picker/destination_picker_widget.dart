// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2021 LINAGORA
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
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/destination_picker_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_action/choose_destination_picker_action.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/node_surfing_type.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_detail_files_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space/file_surfing/workgroup_nodes_surfling_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/upload_destination_type.dart';

import 'destination_picker_action/negative_destination_picker_action.dart';
import 'destination_picker_viewmodel.dart';

class DestinationPickerWidget extends StatefulWidget {
  @override
  _DestinationPickerWidgetState createState() =>
      _DestinationPickerWidgetState();
}

class _DestinationPickerWidgetState extends State<DestinationPickerWidget> {
  final _destinationPickerKey = GlobalKey<ScaffoldState>();
  final _imagePath = getIt<AppImagePaths>();
  final _destinationPickerViewModel = getIt<DestinationPickerViewModel>();
  final GlobalKey<WorkGroupDetailFilesWidgetState> _workGroupDetailFilesWidgetKey = GlobalKey();
  DestinationPickerArguments _destinationPickerArguments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _destinationPickerArguments = ModalRoute.of(context).settings.arguments as DestinationPickerArguments;
        _destinationPickerViewModel.setCurrentViewByDestinationPickerType(_destinationPickerArguments.destinationPickerType);
      } catch (exception) {
        print(exception);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _destinationPickerViewModel.onDisposed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _destinationPickerKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 1.0,
        title: StreamBuilder(
          stream: _destinationPickerViewModel.currentNodeObservable.stream,
          builder: (context, AsyncSnapshot<WorkGroupNodesSurfingArguments> snapshot) {
            if (snapshot.data == null) {
              return Text(
                AppLocalizations.of(context).pick_the_destination,
                style: TextStyle(
                    fontSize: 20.0,
                    color: AppColor.destinationPickerAppBarTitleColor),
              );
            } else if (snapshot.data.folderType == FolderNodeType.normal) {
              return Text(
                snapshot.data.folder.name,
                style: TextStyle(
                    fontSize: 20.0,
                    color: AppColor.destinationPickerAppBarTitleColor),
              );
            } else {
              return Text(
                snapshot.data.sharedSpaceNodeNested.name,
                style: TextStyle(
                    fontSize: 20.0,
                    color: AppColor.destinationPickerAppBarTitleColor),
              );
            }
          },
        ),
        backgroundColor: Colors.white,
        leading: StoreConnector<AppState, DestinationPickerState>(
            converter: (store) => store.state.destinationPickerState,
            builder: (context, state)  {
              if (state.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.uploadDestination) {
                return IconButton(icon: SvgPicture.asset(_imagePath.icClose),
                    onPressed: () => _destinationPickerViewModel.handleOnSharedSpaceBackPress());
              } else if (state.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.sharedSpace) {
                if (_destinationPickerArguments.destinationPickerType == DestinationPickerType.upload) {
                  return IconButton(
                      icon: SvgPicture.asset(_imagePath.icBackBlue),
                      onPressed: () => _destinationPickerViewModel.backToUploadDestination());
                }
                return IconButton(
                    icon: SvgPicture.asset(_imagePath.icClose),
                    onPressed: () => _destinationPickerViewModel.handleOnSharedSpaceBackPress());
              } else if (state.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.sharedSpaceInside) {
                return IconButton(
                    icon: SvgPicture.asset(_imagePath.icBackBlue),
                    onPressed: () => _workGroupDetailFilesWidgetKey.currentState.widget.nodeSurfingNavigateBack());
              }
              return SizedBox.shrink();
            }),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
              bottom: 56.0,
              child: StoreConnector<AppState, DestinationPickerState>(
                  converter: (store) => store.state.destinationPickerState,
                  builder: (context, state) {
                    if (state.routeData.destinationPickerCurrentView ==
                        DestinationPickerCurrentView.sharedSpace) {
                      return _buildSharedSpacesList(context, state);
                    } else if (state.routeData.destinationPickerCurrentView ==
                        DestinationPickerCurrentView.uploadDestination) {
                      return _buildUploadDestinationPickerList();
                    } else if (state.routeData.destinationPickerCurrentView ==
                        DestinationPickerCurrentView.sharedSpaceInside) {
                      return WorkGroupDetailFilesWidget(
                        _workGroupDetailFilesWidgetKey,
                        state.routeData.sharedSpaceNodeNested,
                            () => _destinationPickerViewModel.backToSharedSpace(),
                        nodeSurfingType: NodeSurfingType.destinationPicker,
                        currentNodeObservable: _destinationPickerViewModel.currentNodeObservable,
                      );
                    }
                    return SizedBox.shrink();
                  })),
          StoreConnector<AppState, DestinationPickerState>(
              converter: (store) => store.state.destinationPickerState,
              builder: (context, state) =>
                  state.routeData.destinationPickerCurrentView ==
                          DestinationPickerCurrentView.sharedSpaceInside
                      ? _buildBottomBarLine()
                      : Positioned(
                          bottom: 0.0,
                          child: SizedBox.shrink())),
          StoreConnector<AppState, DestinationPickerState>(
              converter: (store) => store.state.destinationPickerState,
              builder: (context, state) =>
                  state.routeData.destinationPickerCurrentView ==
                          DestinationPickerCurrentView.sharedSpaceInside
                      ? _buildBottomBarAction(context)
                      : Positioned(bottom: 0.0, child: SizedBox.shrink())),
        ],
      ),
    );
  }

  Widget _buildBottomBarLine() {
    return Positioned(
        bottom: 48.0,
        left: 0.0,
        right: 0.0,
        child: Divider(
          thickness: 1.0,
        ));
  }

  Widget _buildBottomBarAction(BuildContext context) {
    return Positioned(
        bottom: 0.0,
        left: 20.0,
        right: 20.0,
        child: SizedBox(
          height: 56.0,
          child: Row(
            textDirection: TextDirection.rtl,
            children: _buildBottomActionList(context),
          ),
        ));
  }

  List<Widget> _buildBottomActionList(BuildContext context) {
    final listAction = <Widget>[];
    if (_destinationPickerArguments != null) {
      for (final action in _destinationPickerArguments.actionList) {
        listAction.add(TextButton(
            onPressed: () {
              if (action.actionClick != null) {
                action is NegativeDestinationPickerAction
                    ? action.actionClick(null)
                    : action.actionClick(
                    _destinationPickerViewModel.currentNodeObservable.value);
              }
            },
            child: action.actionWidget));
      }
    }
    return listAction;
  }

  Widget _buildUploadDestinationPickerList() {
    return ListView.builder(
      key: Key('shared_spaces_list'),
      padding: EdgeInsets.zero,
      itemCount: _destinationPickerViewModel.uploadDestinationTypeList.length,
      itemBuilder: (context, index) {
        return _buildUploadDestinationPickerListItem(_destinationPickerViewModel.uploadDestinationTypeList[index]);
      },
    );
  }

  Widget _buildUploadDestinationPickerListItem(UploadDestinationType uploadDestinationType) {
    return ListTile(
      leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SvgPicture.asset(uploadDestinationType == UploadDestinationType.mySpace ? _imagePath.icHome : _imagePath.icSharedSpace,
            width: 20, height: 24, fit: BoxFit.fill)
      ]),
      title: Text(
        uploadDestinationType == UploadDestinationType.mySpace
            ? AppLocalizations.of(context).my_space_title
            : AppLocalizations.of(context).current_uploads_shared_space_tab,
        maxLines: 1,
        style: TextStyle(
            fontSize: 14, color: AppColor.documentNameItemTextColor),
      ),
      onTap: () => _destinationPickerViewModel.onUploadDestinationPressed(
          uploadDestinationType,
          _destinationPickerArguments.actionList.firstWhere(
              (element) => element is ChooseDestinationPickerAction)),
    );
  }

  Widget _buildSharedSpacesList(
      BuildContext context, DestinationPickerState state) {
    return state.viewState.fold(
        (failure) => RefreshIndicator(
            onRefresh: () async =>
                _destinationPickerViewModel.getAllSharedSpaces(_destinationPickerArguments.destinationPickerType),
            child: failure is SharedSpaceFailure
                ? BackgroundWidgetBuilder()
                    .key(Key('shared_space_error_background'))
                    .image(SvgPicture.asset(_imagePath.icUnexpectedError,
                        width: 120, height: 120, fit: BoxFit.fill))
                    .text(AppLocalizations.of(context)
                        .common_error_occured_message)
                    .build()
                : _buildSharedSpacesListView(context, state)),
        (success) => success is LoadingState
            ? Column(
                children: [
                  Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColor.primaryColor),
                        ),
                      )),
                  Expanded(
                      child: _buildSharedSpacesListView(
                          context, state))
                ],
              )
            : RefreshIndicator(
                onRefresh: () async =>
                    _destinationPickerViewModel.getAllSharedSpaces(_destinationPickerArguments.destinationPickerType),
                child: _buildSharedSpacesListView(
                    context, state)));
  }

  Widget _buildSharedSpacesListView(
      BuildContext context, DestinationPickerState state) {
    if (state.sharedSpacesList.isEmpty) {
      return state.viewState.fold(
              (failure) => _buildNoWorkgroupYet(context),
              (success) => success is LoadingState ? SizedBox.shrink() : _buildNoWorkgroupYet(context));
    } else {
      return ListView.builder(
        key: Key('shared_spaces_list'),
        padding: EdgeInsets.zero,
        itemCount: state.sharedSpacesList.length,
        itemBuilder: (context, index) {
          return _buildSharedSpaceListItem(context, state.sharedSpacesList[index]);
        },
      );
    }
  }

  Widget _buildNoWorkgroupYet(BuildContext context) {
    return BackgroundWidgetBuilder()
        .key(Key('shared_space_no_workgroup_yet'))
        .image(SvgPicture.asset(_imagePath.icSharedSpaceNoWorkGroup,
            width: 120, height: 120, fit: BoxFit.fill))
        .text(AppLocalizations.of(context).do_not_have_any_workgroup)
        .build();
  }

  Widget _buildSharedSpaceListItem(
      BuildContext context, SharedSpaceNodeNested sharedSpace) {
    return ListTile(
      leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SvgPicture.asset(_imagePath.icSharedSpace,
            width: 20, height: 24, fit: BoxFit.fill)
      ]),
      title: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: _buildSharedSpaceName(sharedSpace.name),
      ),
      onTap: () {
        _destinationPickerViewModel.openSharedSpaceInside(sharedSpace);
      },
    );
  }

  Widget _buildSharedSpaceName(String sharedSpaceName) {
    return Text(
      sharedSpaceName,
      maxLines: 1,
      style: TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor),
    );
  }
}
