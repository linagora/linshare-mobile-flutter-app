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
import 'package:linshare_flutter_app/presentation/di/get_it_service.dart';
import 'package:linshare_flutter_app/presentation/localizations/app_localizations.dart';
import 'package:linshare_flutter_app/presentation/redux/states/app_state.dart';
import 'package:linshare_flutter_app/presentation/util/app_image_paths.dart';
import 'package:linshare_flutter_app/presentation/util/app_toast.dart';
import 'package:linshare_flutter_app/presentation/util/extensions/color_extension.dart';
import 'package:linshare_flutter_app/presentation/widget/myspace/my_space_viewmodel.dart';
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
  void dispose() {
    mySpaceViewModel.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector(
        builder: (BuildContext context, MySpaceViewModel viewModel) => Scaffold(
              appBar: AppBar(
                title: Text(
                    AppLocalizations.of(context).stringOf('my_space_title'),
                    style: TextStyle(fontSize: 24, color: Colors.white)),
                centerTitle: true,
                backgroundColor: AppColor.primaryColor,
              ),
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
                  Expanded(
                    child: _buildUploadFileHere(context),
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
                    AppLocalizations.of(context)
                        .stringOf('upload_prepare_text'),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            imagePath.icUploadFile,
            width: 120,
            height: 120,
            fit: BoxFit.fill,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              AppLocalizations.of(context)
                  .stringOf('my_space_text_upload_your_files_here'),
              style: TextStyle(
                  color: AppColor.loginTextFieldTextColor, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget handleUploadToastMessage(
      BuildContext context, dartz.Either<Failure, Success> uploadFileState) {
    uploadFileState.fold(
        (failure) => appToast.showToast(
            AppLocalizations.of(context).stringOf('upload_failure_text')),
        (success) => {
              if (success is UploadFileSuccess)
                {
                  appToast.showToast(AppLocalizations.of(context)
                      .stringOf('upload_success_text')),
                  mySpaceViewModel.cleanUploadViewState()
                }
            });
    return Container();
  }
}
