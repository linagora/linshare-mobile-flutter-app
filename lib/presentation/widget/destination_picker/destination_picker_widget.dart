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
import 'package:linshare_flutter_app/presentation/util/helper/responsive_utils.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/view/context_menu/context_menu_builder.dart';
import 'package:linshare_flutter_app/presentation/view/header/simple_bottom_sheet_header_builder.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_button.dart';
import 'package:linshare_flutter_app/presentation/view/order_by/order_by_dialog_bottom_sheet.dart';
import 'package:linshare_flutter_app/presentation/widget/destination_picker/destination_picker_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_arguments.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_navigator_widget.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_type.dart';
import 'package:linshare_flutter_app/presentation/widget/shared_space_document/shared_space_document_ui_type.dart';
import 'package:linshare_flutter_app/presentation/widget/upload_file/destination_type.dart';
import 'package:redux/redux.dart';
import 'destination_picker_action/negative_destination_picker_action.dart';
import 'destination_picker_viewmodel.dart';

class DestinationPickerWidget extends StatefulWidget {
  @override
  _DestinationPickerWidgetState createState() =>
      _DestinationPickerWidgetState();
}

class _DestinationPickerWidgetState extends State<DestinationPickerWidget> {
  final _responsiveUtils = getIt<ResponsiveUtils>();
  final _destinationPickerKey = GlobalKey<ScaffoldState>();
  final _imagePath = getIt<AppImagePaths>();
  final _destinationPickerViewModel = getIt<DestinationPickerViewModel>();
  final _sharedSpaceDocumentNavigatorKey = GlobalKey<SharedSpaceDocumentNavigatorWidgetState>();

  DestinationPickerArguments? _destinationPickerArguments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      try {
        _destinationPickerArguments = ModalRoute.of(context)?.settings.arguments as DestinationPickerArguments;
        if (_destinationPickerArguments != null) {
          _destinationPickerViewModel.setCurrentViewByOperation(_destinationPickerArguments!.operator);
        }
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
    _destinationPickerArguments = ModalRoute.of(context)?.settings.arguments as DestinationPickerArguments;
    return GestureDetector(
      onTap: () => _destinationPickerViewModel.handleOnSharedSpaceBackPress(),
      child: Card(
        margin: EdgeInsets.zero,
        borderOnForeground: false,
        color: Colors.transparent,
        child: Container(
          margin: _responsiveUtils.getMarginForDestinationPicker(context),
          child: ClipRRect(
            borderRadius: _responsiveUtils.getBorderRadiusView(context),
            child: GestureDetector(
              onTap: () => {},
              child: Scaffold(
                key: _destinationPickerKey,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  elevation: _responsiveUtils.isSmallScreen(context) ? 1.0 : 0.0,
                  title: StoreConnector<AppState, DestinationPickerState>(
                      converter: (store) => store.state.destinationPickerState,
                      builder: (context, state) => StreamBuilder(
                          stream: _destinationPickerViewModel.currentNodeObservable.stream,
                          builder: (context, AsyncSnapshot<SharedSpaceDocumentArguments> snapshot) {
                            return Column(
                              crossAxisAlignment: _getCrossAxisAlignmentAppBar(snapshot.data, state),
                              mainAxisAlignment: _getMainAxisAlignmentAppBar(snapshot.data, state),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildTitleAppBar(snapshot, state)
                              ],
                            );
                          }
                      )
                  ),
                  backgroundColor: Colors.white,
                  leading: _buildLeadingAppBar(),
                  bottom: !_responsiveUtils.isSmallScreen(context)
                    ? PreferredSize(
                      preferredSize: Size.fromHeight(1.0),
                      child: Container(
                        color: AppColor.uploadLineDividerWorkGroupDestination,
                        height: 1.0))
                    : null,
                  actions: [
                    _buildCreateFolderButton()
                  ],
                ),
                backgroundColor: Colors.white,
                body: Column(
                  children: [
                    _buildMenuSorter(),
                    Expanded(
                      child: StoreConnector<AppState, DestinationPickerState>(
                        converter: (store) => store.state.destinationPickerState,
                        builder: (context, state) {
                          if (state.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.sharedSpace) {
                            return _buildSharedSpacesList(context, state);
                          } else if (state.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.chooseSpaceDestination) {
                            return _buildChooseSpaceDestination(state.operation);
                          } else if (state.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.sharedSpaceNodeInside) {
                            return _buildWorkgroupListInsideSharedSpaceNode(context, state);
                          } else if (state.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.workgroupInside) {
                            return SharedSpaceDocumentNavigatorWidget(
                                _sharedSpaceDocumentNavigatorKey,
                                state.routeData.sharedSpaceNodeNested!,
                                parentNode: state.routeData.parentNode,
                                onBackToInsideSharedSpaceNodeClickedCallback: (parentNode) => _destinationPickerViewModel.backToInsideSharedSpaceNodeDestination(parentNode),
                                onBackSharedSpaceClickedCallback: () => _destinationPickerViewModel.backToSharedSpace(),
                                sharedSpaceDocumentUIType: SharedSpaceDocumentUIType.destinationPicker,
                                currentNodeObservable: _destinationPickerViewModel.currentNodeObservable
                            );
                          }
                          return SizedBox.shrink();
                        }
                      )
                    ),
                    StoreConnector<AppState, DestinationPickerState>(
                      converter: (store) => store.state.destinationPickerState,
                      builder: (context, state) => state.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.workgroupInside
                          ? Divider(thickness: 1.0)
                          : SizedBox.shrink()),
                    StoreConnector<AppState, DestinationPickerState>(
                      converter: (store) => store.state.destinationPickerState,
                      builder: (context, state) => state.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.workgroupInside
                          ? _buildBottomBarAction(context)
                          : SizedBox.shrink()),
                  ]
                )
              )
            ),
          )
        )
      )
    );
  }

  CrossAxisAlignment _getCrossAxisAlignmentAppBar(SharedSpaceDocumentArguments? arguments, DestinationPickerState destinationPickerState) {
    if (destinationPickerState.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.workgroupInside) {
      if (arguments != null) {
        return CrossAxisAlignment.center;
      } else {
        if (destinationPickerState.routeData.parentNode != null) {
          return CrossAxisAlignment.center;
        } else {
          return CrossAxisAlignment.stretch;
        }
      }
    } else {
      if (destinationPickerState.routeData.parentNode != null) {
        return CrossAxisAlignment.center;
      } else {
        if (destinationPickerState.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.sharedSpace &&
            (destinationPickerState.operation == Operation.upload || destinationPickerState.operation == Operation.copyTo)) {
          return CrossAxisAlignment.center;
        }
        return CrossAxisAlignment.stretch;
      }
    }
  }

  MainAxisAlignment _getMainAxisAlignmentAppBar(SharedSpaceDocumentArguments? arguments, DestinationPickerState destinationPickerState) {
    if (destinationPickerState.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.workgroupInside) {
      if (arguments != null) {
        return MainAxisAlignment.center;
      } else {
        if (destinationPickerState.routeData.parentNode != null) {
          return MainAxisAlignment.center;
        } else {
          return MainAxisAlignment.start;
        }
      }
    } else {
      if (destinationPickerState.routeData.parentNode != null) {
        return MainAxisAlignment.center;
      } else {
        if (destinationPickerState.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.sharedSpace &&
            (destinationPickerState.operation == Operation.upload || destinationPickerState.operation == Operation.copyTo)) {
          return MainAxisAlignment.center;
        }
        return MainAxisAlignment.start;
      }
    }
  }

  Widget _buildTitleAppBar(AsyncSnapshot<SharedSpaceDocumentArguments> snapshot, DestinationPickerState destinationPickerState) {
    if (destinationPickerState.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.sharedSpaceNodeInside) {
      return Text(
        destinationPickerState.routeData.parentNode?.name ?? '',
        style: TextStyle(
            fontSize: 20.0,
            color: AppColor.destinationPickerAppBarTitleColor),
      );
    } else if (destinationPickerState.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.sharedSpace) {
      return Text((destinationPickerState.operation == Operation.upload || destinationPickerState.operation == Operation.copyTo)
            ? AppLocalizations.of(context).shared_space
            : AppLocalizations.of(context).pick_the_destination,
        style: TextStyle(
            fontSize: 20.0,
            color: AppColor.destinationPickerAppBarTitleColor),
      );
    } else if (destinationPickerState.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.chooseSpaceDestination) {
      return Text(
        AppLocalizations.of(context).pick_the_destination,
        style: TextStyle(
            fontSize: 20.0,
            color: AppColor.destinationPickerAppBarTitleColor),
      );
    } else {
      if (snapshot.data?.documentType == SharedSpaceDocumentType.children) {
        return Text(
          snapshot.data!.workGroupFolder?.name ?? '',
          style: TextStyle(
            fontSize: 20.0,
            color: AppColor.destinationPickerAppBarTitleColor),
        );
      } else {
        return Text(
          destinationPickerState.routeData.sharedSpaceNodeNested?.name ?? '',
          style: TextStyle(
            fontSize: 20.0,
            color: AppColor.destinationPickerAppBarTitleColor),
        );
      }
    }
  }

  Widget _buildLeadingAppBar() {
    return StoreConnector<AppState, DestinationPickerState>(
      converter: (store) => store.state.destinationPickerState,
      builder: (context, state)  {
        if (state.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.chooseSpaceDestination) {
          return IconButton(
              icon: SvgPicture.asset(_imagePath.icClose),
              onPressed: () => _destinationPickerViewModel.handleOnSharedSpaceBackPress());
        } else if (state.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.sharedSpace) {
          if (state.operation == Operation.upload || state.operation == Operation.copyTo) {
            return IconButton(
                icon: SvgPicture.asset(_imagePath.icBackBlue),
                onPressed: () => _destinationPickerViewModel.backToChooseSpaceDestination(state.operation));
          }
          return IconButton(
              icon: SvgPicture.asset(_imagePath.icClose),
              onPressed: () => _destinationPickerViewModel.handleOnSharedSpaceBackPress());
        } else if (state.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.sharedSpaceNodeInside) {
          return IconButton(
              icon: SvgPicture.asset(_imagePath.icBackBlue),
              onPressed: () => _destinationPickerViewModel.backToSharedSpace(parentNode: state.routeData.parentNode));
        } else if (state.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.workgroupInside) {
          return IconButton(
              icon: SvgPicture.asset(_imagePath.icBackBlue),
              onPressed: () => _sharedSpaceDocumentNavigatorKey.currentState?.wantToBack());
        }
        return SizedBox.shrink();
      });
  }

  Widget _buildCreateFolderButton() {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, appState)  {
        if (appState.destinationPickerState.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.workgroupInside) {
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: SvgPicture.asset(_imagePath.icCreateFolder, width: 20, height: 20, fit: BoxFit.fill),
              onPressed: () => _destinationPickerViewModel.openCreateFolderModal(context)));
        }
        return SizedBox.shrink();
      });
  }

  Widget _buildBottomBarAction(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          textDirection: TextDirection.rtl,
          children: _buildBottomActionList(context)
        ),
      )
    );
  }

  List<Widget> _buildBottomActionList(BuildContext context) {
    final listAction = <Widget>[];
    if (_destinationPickerArguments != null) {
      for (final action in (_destinationPickerArguments!.actionList)) {
        listAction.add(TextButton(
            onPressed: () {
              action is NegativeDestinationPickerAction
                ? action.actionClick(null)
                : action.actionClick(_destinationPickerViewModel.currentNodeObservable.valueWrapper?.value);
            },
            child: action.actionWidget));
      }
    }
    return listAction;
  }

  Widget _buildChooseSpaceDestination(Operation pickerForOperation) {
    return ListView.builder(
      key: Key('shared_spaces_list'),
      padding: EdgeInsets.zero,
      itemCount: _destinationPickerViewModel.destinationTypeList.length,
      itemBuilder: (context, index) {
        return _buildChooseSpaceDestinationItem(pickerForOperation, _destinationPickerViewModel.destinationTypeList[index]);
      },
    );
  }

  Widget _buildChooseSpaceDestinationItem(Operation pickerForOperation, DestinationType destinationType) {
    return _isDestinationAvailable(destinationType)
      ? ListTile(
          leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SvgPicture.asset(
                destinationType == DestinationType.mySpace
                    ? _imagePath.icHome
                    : _imagePath.icSharedSpace,
                width: 20, height: 24, fit: BoxFit.fill)
          ]),
          title: Text(
            destinationType == DestinationType.mySpace
                ? AppLocalizations.of(context).my_space_title
                : AppLocalizations.of(context).current_uploads_shared_space_tab,
            maxLines: 1,
            style: TextStyle(
                fontSize: 14, color: AppColor.documentNameItemTextColor),
          ),
          onTap: () {
            if (_destinationPickerArguments != null) {
              _destinationPickerViewModel.onChoseSpaceDestination(
                            destinationType,
                            pickerForOperation,
                            _destinationPickerArguments!.actionList);
            }
          })
        : SizedBox.shrink();
  }

  Widget _buildSharedSpacesList(
      BuildContext context, DestinationPickerState state) {
    return state.viewState.fold(
        (failure) => RefreshIndicator(
            onRefresh: () async {
              _destinationPickerViewModel.getAllSharedSpaces(state.operation);
            },
            child: failure is SharedSpaceDetailFailure
                ? BackgroundWidgetBuilder(context)
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
                onRefresh: () async {
                  _destinationPickerViewModel.getAllSharedSpaces(state.operation);
                },
                child: _buildSharedSpacesListView(
                    context, state)));
  }

  Widget _buildWorkgroupListInsideSharedSpaceNode(BuildContext context, DestinationPickerState state) {
    return state.viewState.fold(
      (failure) => RefreshIndicator(
        onRefresh: () async => _destinationPickerViewModel.getAllWorkgroupInsideSharedSpaceNode(state.operation, state.routeData.parentNode!),
        child: failure is GetAllWorkgroupsFailure
          ? BackgroundWidgetBuilder(context)
              .key(Key('shared_space_error_background'))
              .image(SvgPicture.asset(_imagePath.icUnexpectedError, width: 120, height: 120, fit: BoxFit.fill))
              .text(AppLocalizations.of(context).common_error_occured_message)
              .build()
          : _buildSharedSpacesListView(context, state)
      ),
      (success) => success is LoadingState
          ? Column(
              children: [
                Center(child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor)),
                  )
                )),
                Expanded(child: _buildSharedSpacesListView(context, state))
              ])
          : RefreshIndicator(
              onRefresh: () async => _destinationPickerViewModel.getAllWorkgroupInsideSharedSpaceNode(state.operation, state.routeData.parentNode!),
              child: _buildSharedSpacesListView(context, state)));
  }

  Widget _buildSharedSpacesListView(
      BuildContext context, DestinationPickerState state) {
    if (state.sharedSpacesList.isEmpty) {
      return state.viewState.fold(
              (failure) => _buildNoWorkgroupYet(context),
              (success) => success is LoadingState ? SizedBox.shrink() : _buildNoWorkgroupYet(context));
    } else {
      return SafeArea(child: ListView.builder(
        key: Key('shared_spaces_list'),
        padding: EdgeInsets.zero,
        itemCount: state.sharedSpacesList.length,
        itemBuilder: (context, index) {
          return _buildSharedSpaceListItem(context, state.sharedSpacesList[index], state.routeData.parentNode);
        },
      ));
    }
  }

  Widget _buildNoWorkgroupYet(BuildContext context) {
    return BackgroundWidgetBuilder(context)
        .key(Key('shared_space_no_workgroup_yet'))
        .image(SvgPicture.asset(_imagePath.icSharedSpaceNoWorkGroup,
            width: 120, height: 120, fit: BoxFit.fill))
        .text(AppLocalizations.of(context).do_not_have_any_workgroup)
        .build();
  }

  Widget _buildSharedSpaceListItem(
      BuildContext context, SharedSpaceNodeNested sharedSpace, SharedSpaceNodeNested? parentNode) {
    return ListTile(
      leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SvgPicture.asset(sharedSpace.nodeType == LinShareNodeType.WORK_GROUP ? _imagePath.icWorkgroup : _imagePath.icDrive,
            width: 20, height: 24, fit: BoxFit.fill)
      ]),
      title: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: _buildSharedSpaceName(sharedSpace.name),
      ),
      onTap: () {
        if (sharedSpace.nodeType == LinShareNodeType.WORK_GROUP) {
          _destinationPickerViewModel.openWorkgroupInside(sharedSpace, parentNode);
        } else {
          _destinationPickerViewModel.openSharedSpaceNodeInside(sharedSpace);
        }
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

  bool _isDestinationAvailable(DestinationType destinationType) {
    return _destinationPickerArguments != null
        && _destinationPickerArguments!.availableDestinationTypes.contains(destinationType);
  }

  Widget _buildMenuSorter() {
    return StoreConnector<AppState, DestinationPickerState>(
      converter: (Store<AppState> store) => store.state.destinationPickerState,
      builder: (context, state) {
        return state.routeData.destinationPickerCurrentView == DestinationPickerCurrentView.sharedSpace
          ? OrderByButtonBuilder(context, state.sorter)
              .onOpenOrderMenuAction((currentSorter) => _openPopupMenuSorter(context, currentSorter))
              .build()
          : SizedBox.shrink();
      },
    );
  }

  void _openPopupMenuSorter(BuildContext context, Sorter currentSorter) {
    ContextMenuBuilder(context)
      .addHeader(SimpleBottomSheetHeaderBuilder(Key('destination_picker_order_by_menu_header'))
          .addLabel(AppLocalizations.of(context).order_by)
          .build())
      .addTiles(OrderByDialogBottomSheetBuilder(context, currentSorter)
          .onSelectSorterAction((sorterSelected) => _destinationPickerViewModel.sortSharedSpace(sorterSelected))
          .build())
      .build();
  }
}
