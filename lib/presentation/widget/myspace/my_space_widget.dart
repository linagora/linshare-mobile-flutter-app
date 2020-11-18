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

import 'package:dartz/dartz.dart' as dartz;
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/my_space_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/view/background_widgets/error_background_widget_builder.dart';
import 'package:linshare_flutter_app/presentation/widget/myspace/my_space_viewmodel.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/datetime_extension.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/media_type_extension.dart';
import 'package:redux/redux.dart';

class MySpaceWidget extends StatefulWidget {
  @override
  _MySpaceWidgetState createState() => _MySpaceWidgetState();
}

class _MySpaceWidgetState extends State<MySpaceWidget> {
  final mySpaceViewModel = getIt<MySpaceViewModel>();
  final imagePath = getIt<AppImagePaths>();
  final appToast = getIt<AppToast>();

  @override
  void initState() {
    super.initState();
    mySpaceViewModel.getAllDocument();
  }

  @override
  void dispose() {
    mySpaceViewModel.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
        builder: (BuildContext context, MySpaceViewModel viewModel) => Scaffold(
              body: Column(
                children: [
                  StreamBuilder(builder: (context, snapshot) {
                    return handleUploadToastMessage(context,
                        mySpaceViewModel.store.state.uploadFileState.viewState);
                  }),
                  Container(
                    child: StreamBuilder(builder: (context, snapshot) {
                      return handleUploadWidget(
                          context,
                          mySpaceViewModel.store.state.uploadFileState.viewState
                              .getOrElse(() => null));
                    }),
                  ),
                  StoreConnector<AppState, dartz.Either<Failure, Success>>(
                    converter: (store) => store.state.mySpaceState.viewState,
                    builder: (context, viewState) {
                      return viewState.fold(
                          (failure) => Container(),
                          (success) => (success is LoadingState)
                              ? Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              AppColor.primaryColor),
                                    ),
                                  ),
                                )
                              : Container());
                    },
                  ),
                  Expanded(
                    child: _buildMySpaceList(context),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => mySpaceViewModel.handleOnUploadFilePressed(),
                backgroundColor: AppColor.primaryColor,
                child: Image(image: AssetImage(imagePath.icAdd)),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            ),
        converter: (Store<AppState> store) => mySpaceViewModel);
  }

  Widget _buildMySpaceList(BuildContext context) {
    return StoreConnector<AppState, MySpaceState>(
        converter: (store) => store.state.mySpaceState,
        builder: (context, mySpaceState) {
          return mySpaceState.viewState.fold(
            (failure) =>
              RefreshIndicator(
                onRefresh: () async => mySpaceViewModel.getAllDocument(),
                child: failure is MySpaceFailure ?
              ErrorBackgroundWidgetBuilder(context, imagePath).build() : _buildMySpaceListView(context, mySpaceState.documentList)),
            (success) => success is LoadingState ?
              _buildMySpaceListView(context, mySpaceState.documentList) :
              RefreshIndicator(
                onRefresh: () async => mySpaceViewModel.getAllDocument(),
                child: _buildMySpaceListView(context, mySpaceState.documentList)));
        });
  }

  Widget _buildMySpaceListView(BuildContext context, List<Document> documentList) {
    if (documentList.isEmpty) {
      return _buildUploadFileHere(context);
    } else {
      return ListView.builder(
        itemCount: documentList.length,
        itemBuilder: (context, index) {
          return _buildMySpaceListItem(context, documentList[index]);
        });
    }
  }

  Widget _buildMySpaceListItem(BuildContext context, Document document) {
    return ListTile(
      leading: SvgPicture.asset(
        document.mediaType.getFileTypeImagePath(imagePath),
        width: 16,
        height: 20,
        fit: BoxFit.fill,
      ),
      title: Transform(
        transform: Matrix4.translationValues(-16, -2, 0.0),
        child: Text(
          document.name,
          maxLines: 1,
          style:
              TextStyle(fontSize: 14, color: AppColor.documentNameItemTextColor),
        ),
      ),
      subtitle: Transform(
        transform: Matrix4.translationValues(-16, 0.0, 0.0),
        child: Row(
          children: [
            Text(
              AppLocalizations.of(context).item_last_modified(
                  document.modificationDate.getMMMddyyyyFormatString()),
              style: TextStyle(
                  fontSize: 13,
                  color: AppColor.documentModifiedDateItemTextColor),
            ),
            document.isShared()
                ? Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: SvgPicture.asset(
                      imagePath.icSharedPeople,
                      width: 16,
                      height: 16,
                      fit: BoxFit.fill,
                    ),
                  )
                : Container()
          ],
        ),
      ),
      trailing: SvgPicture.asset(
        imagePath.icContextMenu,
        width: 24,
        height: 24,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget handleUploadWidget(BuildContext context, [Success success]) {
    if (success is UploadingProgress) {
      return _buildUploadingFile(context, success.fileName, success.progress);
    } else if (success is FilePickerSuccessViewState) {
      return _buildPreparingUploadFile(context, success.fileInfo.fileName);
    } else {
      return Container();
    }
  }

  Widget _buildPreparingUploadFile(BuildContext context, String fileName) {
    return SizedBox(
      height: 54,
      child: Container(
        color: AppColor.mySpaceUploadBackground,
        child: Column(children: [
          Expanded(
              child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 24),
                  child: Text(
                    AppLocalizations.of(context).upload_prepare_text,
                    maxLines: 1,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              )
            ],
          )),
        ]),
      ),
    );
  }

  Widget _buildUploadingFile(
      BuildContext context, String fileName, int progress) {
    return SizedBox(
      height: 58,
      child: Container(
        color: AppColor.mySpaceUploadBackground,
        child: Column(children: [
          _buildLinearProgress(context, progress),
          Expanded(child: _buildUploadFileInfo(context, fileName, progress)),
        ]),
      ),
    );
  }

  Widget _buildLinearProgress(BuildContext context, int progress) {
    return SizedBox(
      height: 4,
      child: LinearProgressIndicator(
        backgroundColor: AppColor.uploadProgressBackgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        value: progress.toDouble() / 100,
      ),
    );
  }

  Widget _buildUploadFileInfo(
      BuildContext context, String fileName, int progress) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 24),
            child: Text(
              'Uploading ' + fileName + ' ($progress)%...',
              maxLines: 1,
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildUploadFileHere(BuildContext context) {
    return BackgroundWidgetBuilder(
      SvgPicture.asset(
        imagePath.icUploadFile,
        width: 120,
        height: 120,
        fit: BoxFit.fill,
      ),
      AppLocalizations.of(context).my_space_text_upload_your_files_here).build();
  }

  Widget handleUploadToastMessage(
      BuildContext context, dartz.Either<Failure, Success> uploadFileState) {
    uploadFileState.fold(
        (failure) => appToast.showToast(
            AppLocalizations.of(context).upload_failure_text),
        (success) => {
          if (success is UploadFileSuccess) {
            appToast.showToast(AppLocalizations.of(context).upload_success_text),
            mySpaceViewModel.cleanUploadViewState()
          }
        });
    return Container();
  }
}
