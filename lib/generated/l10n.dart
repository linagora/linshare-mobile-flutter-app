// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Initializing data...`
  String get initializing_data {
    return Intl.message(
      'Initializing data...',
      name: 'initializing_data',
      desc: '',
      args: [],
    );
  }

  /// `Store and share your files from anywhere`
  String get login_text_slogan {
    return Intl.message(
      'Store and share your files from anywhere',
      name: 'login_text_slogan',
      desc: '',
      args: [],
    );
  }

  /// `Please login to continue`
  String get login_text_login_to_continue {
    return Intl.message(
      'Please login to continue',
      name: 'login_text_login_to_continue',
      desc: '',
      args: [],
    );
  }

  /// `https://`
  String get https {
    return Intl.message(
      'https://',
      name: 'https',
      desc: '',
      args: [],
    );
  }

  /// `email`
  String get email {
    return Intl.message(
      'email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `password`
  String get password {
    return Intl.message(
      'password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login_button_login {
    return Intl.message(
      'Login',
      name: 'login_button_login',
      desc: '',
      args: [],
    );
  }

  /// `Upload file`
  String get upload_file_title {
    return Intl.message(
      'Upload file',
      name: 'upload_file_title',
      desc: '',
      args: [],
    );
  }

  /// `Upload to My Space`
  String get upload_text_button {
    return Intl.message(
      'Upload to My Space',
      name: 'upload_text_button',
      desc: '',
      args: [],
    );
  }

  /// `My Space`
  String get my_space_title {
    return Intl.message(
      'My Space',
      name: 'my_space_title',
      desc: '',
      args: [],
    );
  }

  /// `Preparing to upload...`
  String get upload_prepare_text {
    return Intl.message(
      'Preparing to upload...',
      name: 'upload_prepare_text',
      desc: '',
      args: [],
    );
  }

  /// `Upload your files here`
  String get my_space_text_upload_your_files_here {
    return Intl.message(
      'Upload your files here',
      name: 'my_space_text_upload_your_files_here',
      desc: '',
      args: [],
    );
  }

  /// `Failed to upload file`
  String get upload_failure_text {
    return Intl.message(
      'Failed to upload file',
      name: 'upload_failure_text',
      desc: '',
      args: [],
    );
  }

  /// `File uploaded`
  String get upload_success_text {
    return Intl.message(
      'File uploaded',
      name: 'upload_success_text',
      desc: '',
      args: [],
    );
  }

  /// `Server URL is not valid, please try again`
  String get wrong_url_message {
    return Intl.message(
      'Server URL is not valid, please try again',
      name: 'wrong_url_message',
      desc: '',
      args: [],
    );
  }

  /// `Authentication failed, either the email or the password is invalid, please try again`
  String get credential_error_message {
    return Intl.message(
      'Authentication failed, either the email or the password is invalid, please try again',
      name: 'credential_error_message',
      desc: '',
      args: [],
    );
  }

  /// `Unknown error occurred, please try again`
  String get unknown_error_login_message {
    return Intl.message(
      'Unknown error occurred, please try again',
      name: 'unknown_error_login_message',
      desc: '',
      args: [],
    );
  }

  /// `Modified {dateString}`
  String item_last_modified(Object dateString) {
    return Intl.message(
      'Modified $dateString',
      name: 'item_last_modified',
      desc: '',
      args: [dateString],
    );
  }

  /// `My Space`
  String get my_space {
    return Intl.message(
      'My Space',
      name: 'my_space',
      desc: '',
      args: [],
    );
  }

  /// `Unexpected error occurs\nPlease reload or try again later`
  String get common_error_occured_message {
    return Intl.message(
      'Unexpected error occurs\nPlease reload or try again later',
      name: 'common_error_occured_message',
      desc: '',
      args: [],
    );
  }

  /// `Download to device`
  String get download_to_device {
    return Intl.message(
      'Download to device',
      name: 'download_to_device',
      desc: '',
      args: [],
    );
  }

  /// `Export file`
  String get export_file {
    return Intl.message(
      'Export file',
      name: 'export_file',
      desc: '',
      args: [],
    );
  }

  /// `Preparing to export`
  String get preparing_to_export {
    return Intl.message(
      'Preparing to export',
      name: 'preparing_to_export',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Downloading {fileName}`
  String downloading_file(Object fileName) {
    return Intl.message(
      'Downloading $fileName',
      name: 'downloading_file',
      desc: '',
      args: [fileName],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Quick Share`
  String get title_quick_share {
    return Intl.message(
      'Quick Share',
      name: 'title_quick_share',
      desc: '',
      args: [],
    );
  }

  /// `Add recipients`
  String get add_recipients {
    return Intl.message(
      'Add recipients',
      name: 'add_recipients',
      desc: '',
      args: [],
    );
  }

  /// `Add people`
  String get add_people {
    return Intl.message(
      'Add people',
      name: 'add_people',
      desc: '',
      args: [],
    );
  }

  /// `The file is successfully shared`
  String get file_is_successfully_shared {
    return Intl.message(
      'The file is successfully shared',
      name: 'file_is_successfully_shared',
      desc: '',
      args: [],
    );
  }

  /// `The file could not be shared`
  String get file_could_not_be_share {
    return Intl.message(
      'The file could not be shared',
      name: 'file_could_not_be_share',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get logout {
    return Intl.message(
      'Log out',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out of this account ?`
  String get confirm_remove_account_title {
    return Intl.message(
      'Are you sure you want to log out of this account ?',
      name: 'confirm_remove_account_title',
      desc: '',
      args: [],
    );
  }

  /// `Shared space`
  String get shared_space {
    return Intl.message(
      'Shared space',
      name: 'shared_space',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any workgroup yet`
  String get do_not_have_any_workgroup {
    return Intl.message(
      'You don\'t have any workgroup yet',
      name: 'do_not_have_any_workgroup',
      desc: '',
      args: [],
    );
  }

  /// `Unknown user`
  String get unknown_user {
    return Intl.message(
      'Unknown user',
      name: 'unknown_user',
      desc: '',
      args: [],
    );
  }

  /// `Upload and Share`
  String get upload_and_share_button {
    return Intl.message(
      'Upload and Share',
      name: 'upload_and_share_button',
      desc: '',
      args: [],
    );
  }

  /// `The file is uploaded and shared with {recipientName}`
  String sharing_single_after_uploaded_success(Object recipientName) {
    return Intl.message(
      'The file is uploaded and shared with $recipientName',
      name: 'sharing_single_after_uploaded_success',
      desc: '',
      args: [recipientName],
    );
  }

  /// `The file is uploaded and shared with {numberOfRecipients} people`
  String sharing_multiple_after_uploaded_success(Object numberOfRecipients) {
    return Intl.message(
      'The file is uploaded and shared with $numberOfRecipients people',
      name: 'sharing_multiple_after_uploaded_success',
      desc: '',
      args: [numberOfRecipients],
    );
  }

  /// `The file will be ready for upload and sharing once connection is available`
  String get sharing_after_uploaded_failure {
    return Intl.message(
      'The file will be ready for upload and sharing once connection is available',
      name: 'sharing_after_uploaded_failure',
      desc: '',
      args: [],
    );
  }

  /// `Back to Shared Space`
  String get workgroup_nodes_surfing_root_back_title {
    return Intl.message(
      'Back to Shared Space',
      name: 'workgroup_nodes_surfing_root_back_title',
      desc: '',
      args: [],
    );
  }

  /// `Modification date`
  String get workgroup_nodes_surfing_sort_type_title {
    return Intl.message(
      'Modification date',
      name: 'workgroup_nodes_surfing_sort_type_title',
      desc: '',
      args: [],
    );
  }

  /// `Destination`
  String get destination {
    return Intl.message(
      'Destination',
      name: 'destination',
      desc: '',
      args: [],
    );
  }

  /// `Upload to Workspace`
  String get upload_to_workspace {
    return Intl.message(
      'Upload to Workspace',
      name: 'upload_to_workspace',
      desc: '',
      args: [],
    );
  }

  /// `Photos and Videos`
  String get photos_and_videos {
    return Intl.message(
      'Photos and Videos',
      name: 'photos_and_videos',
      desc: '',
      args: [],
    );
  }

  /// `Browse`
  String get browse {
    return Intl.message(
      'Browse',
      name: 'browse',
      desc: '',
      args: [],
    );
  }

  /// `Select all`
  String get select_all {
    return Intl.message(
      'Select all',
      name: 'select_all',
      desc: '',
      args: [],
    );
  }

  /// `Unselect all`
  String get unselect_all {
    return Intl.message(
      'Unselect all',
      name: 'unselect_all',
      desc: '',
      args: [],
    );
  }

  /// `{numberOfItems,plural, =0{No item}=1{{numberOfItems} item}other{{numberOfItems} items}}`
  String items(num numberOfItems) {
    return Intl.plural(
      numberOfItems,
      zero: 'No item',
      one: '$numberOfItems item',
      other: '$numberOfItems items',
      name: 'items',
      desc: '',
      args: [numberOfItems],
    );
  }

  /// `{numberOfItems,plural, =1{{numberOfItems} item selected}other{{numberOfItems} items selected}}`
  String items_selected(num numberOfItems) {
    return Intl.plural(
      numberOfItems,
      one: '$numberOfItems item selected',
      other: '$numberOfItems items selected',
      name: 'items_selected',
      desc: '',
      args: [numberOfItems],
    );
  }

  /// `Uploading files`
  String get uploading_files_status_title {
    return Intl.message(
      'Uploading files',
      name: 'uploading_files_status_title',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get uploading_files_view_button {
    return Intl.message(
      'View',
      name: 'uploading_files_view_button',
      desc: '',
      args: [],
    );
  }

  /// `Current uploads`
  String get current_uploads_screen_title {
    return Intl.message(
      'Current uploads',
      name: 'current_uploads_screen_title',
      desc: '',
      args: [],
    );
  }

  /// `My Space`
  String get current_uploads_my_space_tab {
    return Intl.message(
      'My Space',
      name: 'current_uploads_my_space_tab',
      desc: '',
      args: [],
    );
  }

  /// `Shared Space`
  String get current_uploads_shared_space_tab {
    return Intl.message(
      'Shared Space',
      name: 'current_uploads_shared_space_tab',
      desc: '',
      args: [],
    );
  }

  /// `Waiting`
  String get current_uploads_waiting_status {
    return Intl.message(
      'Waiting',
      name: 'current_uploads_waiting_status',
      desc: '',
      args: [],
    );
  }

  /// `Uploading`
  String get current_uploads_uploading_status {
    return Intl.message(
      'Uploading',
      name: 'current_uploads_uploading_status',
      desc: '',
      args: [],
    );
  }

  /// `Upload failed`
  String get current_uploads_upload_failed_status {
    return Intl.message(
      'Upload failed',
      name: 'current_uploads_upload_failed_status',
      desc: '',
      args: [],
    );
  }

  /// `Share failed`
  String get current_uploads_share_failed_status {
    return Intl.message(
      'Share failed',
      name: 'current_uploads_share_failed_status',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get current_uploads_succeed_status {
    return Intl.message(
      'Completed',
      name: 'current_uploads_succeed_status',
      desc: '',
      args: [],
    );
  }

  /// `Pick the destination`
  String get pick_the_destination {
    return Intl.message(
      'Pick the destination',
      name: 'pick_the_destination',
      desc: '',
      args: [],
    );
  }

  /// `copy here`
  String get copy_here {
    return Intl.message(
      'copy here',
      name: 'copy_here',
      desc: '',
      args: [],
    );
  }

  /// `Copy to a workgroup`
  String get copy_to_a_workgroup {
    return Intl.message(
      'Copy to a workgroup',
      name: 'copy_to_a_workgroup',
      desc: '',
      args: [],
    );
  }

  /// `The file is copied to a Shared space`
  String get the_file_is_copied_to_a_shared_space {
    return Intl.message(
      'The file is copied to a Shared space',
      name: 'the_file_is_copied_to_a_shared_space',
      desc: '',
      args: [],
    );
  }

  /// `Can not copy file to Shared space`
  String get cannot_copy_file_to_shared_space {
    return Intl.message(
      'Can not copy file to Shared space',
      name: 'cannot_copy_file_to_shared_space',
      desc: '',
      args: [],
    );
  }

  /// `Some items could not be copied to Shared space`
  String get some_items_could_not_be_copied_to_shared_space {
    return Intl.message(
      'Some items could not be copied to Shared space',
      name: 'some_items_could_not_be_copied_to_shared_space',
      desc: '',
      args: [],
    );
  }

  /// `{numberOfItems,plural, =1{Are you sure you want to delete "{singleItemName}"?}other{Are you sure you want to delete {numberOfItems} items?}}`
  String are_you_sure_you_want_to_delete_multiple(num numberOfItems, Object singleItemName) {
    return Intl.plural(
      numberOfItems,
      one: 'Are you sure you want to delete "$singleItemName"?',
      other: 'Are you sure you want to delete $numberOfItems items?',
      name: 'are_you_sure_you_want_to_delete_multiple',
      desc: '',
      args: [numberOfItems, singleItemName],
    );
  }

  /// `The file has been successfully deleted`
  String get the_file_has_been_successfully_deleted {
    return Intl.message(
      'The file has been successfully deleted',
      name: 'the_file_has_been_successfully_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Files have been successfully deleted`
  String get files_have_been_successfully_deleted {
    return Intl.message(
      'Files have been successfully deleted',
      name: 'files_have_been_successfully_deleted',
      desc: '',
      args: [],
    );
  }

  /// `The file could not be deleted`
  String get the_file_could_not_be_deleted {
    return Intl.message(
      'The file could not be deleted',
      name: 'the_file_could_not_be_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Files could not be deleted`
  String get files_could_not_be_deleted {
    return Intl.message(
      'Files could not be deleted',
      name: 'files_could_not_be_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Some items could not be deleted`
  String get some_items_could_not_be_deleted {
    return Intl.message(
      'Some items could not be deleted',
      name: 'some_items_could_not_be_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Some items are successfully deleted`
  String get some_items_are_successfully_deleted {
    return Intl.message(
      'Some items are successfully deleted',
      name: 'some_items_are_successfully_deleted',
      desc: '',
      args: [],
    );
  }

  /// `{numberOfFiles,plural, =1{Downloading {numberOfFiles} file}other{Downloading {numberOfFiles} files}}`
  String downloading_files(num numberOfFiles) {
    return Intl.plural(
      numberOfFiles,
      one: 'Downloading $numberOfFiles file',
      other: 'Downloading $numberOfFiles files',
      name: 'downloading_files',
      desc: '',
      args: [numberOfFiles],
    );
  }

  /// `Cannot connect to the network`
  String get can_not_connect_network {
    return Intl.message(
      'Cannot connect to the network',
      name: 'can_not_connect_network',
      desc: '',
      args: [],
    );
  }

  /// `Cannot process while offline`
  String get can_not_proceed_while_offline {
    return Intl.message(
      'Cannot process while offline',
      name: 'can_not_proceed_while_offline',
      desc: '',
      args: [],
    );
  }

  /// `choose`
  String get choose {
    return Intl.message(
      'choose',
      name: 'choose',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Account details`
  String get account_details {
    return Intl.message(
      'Account details',
      name: 'account_details',
      desc: '',
      args: [],
    );
  }

  /// `First name`
  String get first_name {
    return Intl.message(
      'First name',
      name: 'first_name',
      desc: '',
      args: [],
    );
  }

  /// `Last name`
  String get last_name {
    return Intl.message(
      'Last name',
      name: 'last_name',
      desc: '',
      args: [],
    );
  }

  /// `Last login`
  String get last_login {
    return Intl.message(
      'Last login',
      name: 'last_login',
      desc: '',
      args: [],
    );
  }

  /// `Available space`
  String get available_space {
    return Intl.message(
      'Available space',
      name: 'available_space',
      desc: '',
      args: [],
    );
  }

  /// `{usedSpace} on {quota}`
  String available_space_value(Object quota, Object usedSpace) {
    return Intl.message(
      '$usedSpace on $quota',
      name: 'available_space_value',
      desc: '',
      args: [quota, usedSpace],
    );
  }

  /// `Received shares`
  String get received_shares {
    return Intl.message(
      'Received shares',
      name: 'received_shares',
      desc: '',
      args: [],
    );
  }

  /// `Received`
  String get received {
    return Intl.message(
      'Received',
      name: 'received',
      desc: '',
      args: [],
    );
  }

  /// `Created {dateString}`
  String item_created_date(Object dateString) {
    return Intl.message(
      'Created $dateString',
      name: 'item_created_date',
      desc: '',
      args: [dateString],
    );
  }

  /// `You have reached the max quota of {quota}`
  String notEnoughQuota(Object quota) {
    return Intl.message(
      'You have reached the max quota of $quota',
      name: 'notEnoughQuota',
      desc: '',
      args: [quota],
    );
  }

  /// `{nbFiles,plural, =1{{firstElementName} has exceeded the max file of {quota}}other{Some files have exceeded the max file of {quota}}}`
  String tooBigFiles(num nbFiles, Object quota, Object firstElementName) {
    return Intl.plural(
      nbFiles,
      one: '$firstElementName has exceeded the max file of $quota',
      other: 'Some files have exceeded the max file of $quota',
      name: 'tooBigFiles',
      desc: '',
      args: [nbFiles, quota, firstElementName],
    );
  }

  /// `Copy to My Space`
  String get copy_to_my_space {
    return Intl.message(
      'Copy to My Space',
      name: 'copy_to_my_space',
      desc: '',
      args: [],
    );
  }

  /// `The file has been copied successfully`
  String get the_file_has_been_copied_successfully {
    return Intl.message(
      'The file has been copied successfully',
      name: 'the_file_has_been_copied_successfully',
      desc: '',
      args: [],
    );
  }

  /// `The file could not be copied`
  String get the_file_could_not_be_copied {
    return Intl.message(
      'The file could not be copied',
      name: 'the_file_could_not_be_copied',
      desc: '',
      args: [],
    );
  }

  /// `Can not copy files to My Space`
  String get cannot_copy_files_to_my_space {
    return Intl.message(
      'Can not copy files to My Space',
      name: 'cannot_copy_files_to_my_space',
      desc: '',
      args: [],
    );
  }

  /// `Some items have been copied to My Space`
  String get some_items_have_been_copied_to_my_space {
    return Intl.message(
      'Some items have been copied to My Space',
      name: 'some_items_have_been_copied_to_my_space',
      desc: '',
      args: [],
    );
  }

  /// `All items have been copied to My Space`
  String get all_items_have_been_copied_to_my_space {
    return Intl.message(
      'All items have been copied to My Space',
      name: 'all_items_have_been_copied_to_my_space',
      desc: '',
      args: [],
    );
  }

  /// `Search in My Space`
  String get search_in_my_space {
    return Intl.message(
      'Search in My Space',
      name: 'search_in_my_space',
      desc: '',
      args: [],
    );
  }

  /// `Search in Shared Space files`
  String get search_in_shared_space_files {
    return Intl.message(
      'Search in Shared Space files',
      name: 'search_in_shared_space_files',
      desc: '',
      args: [],
    );
  }

  /// `{numberOfResults,plural, =0{{numberOfResults} result}=1{{numberOfResults} result}other{{numberOfResults} results}}`
  String results_count(num numberOfResults) {
    return Intl.plural(
      numberOfResults,
      zero: '$numberOfResults result',
      one: '$numberOfResults result',
      other: '$numberOfResults results',
      name: 'results_count',
      desc: '',
      args: [numberOfResults],
    );
  }

  /// `No results found`
  String get no_results_found {
    return Intl.message(
      'No results found',
      name: 'no_results_found',
      desc: '',
      args: [],
    );
  }

  /// `Search in Shared Space`
  String get search_in_shared_space {
    return Intl.message(
      'Search in Shared Space',
      name: 'search_in_shared_space',
      desc: '',
      args: [],
    );
  }

  /// `{sharedSpacesNumber,plural, =1{The Shared Space could not be deleted}other{Shared Spaces could not be deleted}}`
  String shared_spaces_could_not_be_deleted(num sharedSpacesNumber) {
    return Intl.plural(
      sharedSpacesNumber,
      one: 'The Shared Space could not be deleted',
      other: 'Shared Spaces could not be deleted',
      name: 'shared_spaces_could_not_be_deleted',
      desc: '',
      args: [sharedSpacesNumber],
    );
  }

  /// `The Shared Space has been deleted`
  String get shared_space_has_been_deleted {
    return Intl.message(
      'The Shared Space has been deleted',
      name: 'shared_space_has_been_deleted',
      desc: '',
      args: [],
    );
  }

  /// `All Shared Spaces have been deleted`
  String get all_shared_spaces_have_been_deleted {
    return Intl.message(
      'All Shared Spaces have been deleted',
      name: 'all_shared_spaces_have_been_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get preview {
    return Intl.message(
      'Preview',
      name: 'preview',
      desc: '',
      args: [],
    );
  }

  /// `No preview available`
  String get no_preview_available {
    return Intl.message(
      'No preview available',
      name: 'no_preview_available',
      desc: '',
      args: [],
    );
  }

  /// `Preparing to preview file`
  String get preparing_to_preview_file {
    return Intl.message(
      'Preparing to preview file',
      name: 'preparing_to_preview_file',
      desc: '',
      args: [],
    );
  }

  /// `Modification date`
  String get modification_date {
    return Intl.message(
      'Modification date',
      name: 'modification_date',
      desc: '',
      args: [],
    );
  }

  /// `Creation date`
  String get creation_date {
    return Intl.message(
      'Creation date',
      name: 'creation_date',
      desc: '',
      args: [],
    );
  }

  /// `Size`
  String get size {
    return Intl.message(
      'Size',
      name: 'size',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Shared`
  String get shared {
    return Intl.message(
      'Shared',
      name: 'shared',
      desc: '',
      args: [],
    );
  }

  /// `Order by`
  String get order_by {
    return Intl.message(
      'Order by',
      name: 'order_by',
      desc: '',
      args: [],
    );
  }

  /// `Add new file or folder`
  String get add_new_file_or_folder {
    return Intl.message(
      'Add new file or folder',
      name: 'add_new_file_or_folder',
      desc: '',
      args: [],
    );
  }

  /// `Create Folder`
  String get create_folder {
    return Intl.message(
      'Create Folder',
      name: 'create_folder',
      desc: '',
      args: [],
    );
  }

  /// `New folder`
  String get new_folder {
    return Intl.message(
      'New folder',
      name: 'new_folder',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get rename {
    return Intl.message(
      'Rename',
      name: 'rename',
      desc: '',
      args: [],
    );
  }

  /// `The name cannot be empty!`
  String get name_not_empty {
    return Intl.message(
      'The name cannot be empty!',
      name: 'name_not_empty',
      desc: '',
      args: [],
    );
  }

  /// `The name already exists!`
  String get name_already_exists {
    return Intl.message(
      'The name already exists!',
      name: 'name_already_exists',
      desc: '',
      args: [],
    );
  }

  /// `Create new folder`
  String get create_new_folder {
    return Intl.message(
      'Create new folder',
      name: 'create_new_folder',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message(
      'Details',
      name: 'details',
      desc: '',
      args: [],
    );
  }

  /// `Members`
  String get members {
    return Intl.message(
      'Members',
      name: 'members',
      desc: '',
      args: [],
    );
  }

  /// `Modified`
  String get modified {
    return Intl.message(
      'Modified',
      name: 'modified',
      desc: '',
      args: [],
    );
  }

  /// `Created`
  String get created {
    return Intl.message(
      'Created',
      name: 'created',
      desc: '',
      args: [],
    );
  }

  /// `My rights`
  String get my_rights {
    return Intl.message(
      'My rights',
      name: 'my_rights',
      desc: '',
      args: [],
    );
  }

  /// `Max file size`
  String get max_file_size {
    return Intl.message(
      'Max file size',
      name: 'max_file_size',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `No description`
  String get no_description {
    return Intl.message(
      'No description',
      name: 'no_description',
      desc: '',
      args: [],
    );
  }

  /// `Copy to`
  String get copy_to {
    return Intl.message(
      'Copy to',
      name: 'copy_to',
      desc: '',
      args: [],
    );
  }

  /// `Admin`
  String get admin {
    return Intl.message(
      'Admin',
      name: 'admin',
      desc: '',
      args: [],
    );
  }

  /// `Reader`
  String get reader {
    return Intl.message(
      'Reader',
      name: 'reader',
      desc: '',
      args: [],
    );
  }

  /// `Contributor`
  String get contributor {
    return Intl.message(
      'Contributor',
      name: 'contributor',
      desc: '',
      args: [],
    );
  }

  /// `Writer`
  String get writer {
    return Intl.message(
      'Writer',
      name: 'writer',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Role`
  String get unknown_role {
    return Intl.message(
      'Unknown Role',
      name: 'unknown_role',
      desc: '',
      args: [],
    );
  }

  /// `Activities`
  String get activities {
    return Intl.message(
      'Activities',
      name: 'activities',
      desc: '',
      args: [],
    );
  }

  /// `by {actorName}`
  String audit_log_actor(Object actorName) {
    return Intl.message(
      'by $actorName',
      name: 'audit_log_actor',
      desc: '',
      args: [actorName],
    );
  }

  /// `Addition:`
  String get audit_action_title_addition {
    return Intl.message(
      'Addition:',
      name: 'audit_action_title_addition',
      desc: '',
      args: [],
    );
  }

  /// `Delete:`
  String get audit_action_title_delete {
    return Intl.message(
      'Delete:',
      name: 'audit_action_title_delete',
      desc: '',
      args: [],
    );
  }

  /// `Update:`
  String get audit_action_title_update {
    return Intl.message(
      'Update:',
      name: 'audit_action_title_update',
      desc: '',
      args: [],
    );
  }

  /// `Creation:`
  String get audit_action_title_create {
    return Intl.message(
      'Creation:',
      name: 'audit_action_title_create',
      desc: '',
      args: [],
    );
  }

  /// `Upload file:`
  String get audit_action_title_upload {
    return Intl.message(
      'Upload file:',
      name: 'audit_action_title_upload',
      desc: '',
      args: [],
    );
  }

  /// `Copy:`
  String get audit_action_title_copy {
    return Intl.message(
      'Copy:',
      name: 'audit_action_title_copy',
      desc: '',
      args: [],
    );
  }

  /// `Download:`
  String get audit_action_title_download {
    return Intl.message(
      'Download:',
      name: 'audit_action_title_download',
      desc: '',
      args: [],
    );
  }

  /// `Version uploaded:`
  String get audit_action_title_upload_revision {
    return Intl.message(
      'Version uploaded:',
      name: 'audit_action_title_upload_revision',
      desc: '',
      args: [],
    );
  }

  /// `Version deleted:`
  String get audit_action_title_delete_revision {
    return Intl.message(
      'Version deleted:',
      name: 'audit_action_title_delete_revision',
      desc: '',
      args: [],
    );
  }

  /// `Restore version:`
  String get audit_action_title_restore_revision {
    return Intl.message(
      'Restore version:',
      name: 'audit_action_title_restore_revision',
      desc: '',
      args: [],
    );
  }

  /// `Version downloaded:`
  String get audit_action_title_download_revision {
    return Intl.message(
      'Version downloaded:',
      name: 'audit_action_title_download_revision',
      desc: '',
      args: [],
    );
  }

  /// `{authorName} has created a new Workgroup : {resourceName}.`
  String audit_action_message_create_workgroup(Object authorName, Object resourceName) {
    return Intl.message(
      '$authorName has created a new Workgroup : $resourceName.',
      name: 'audit_action_message_create_workgroup',
      desc: '',
      args: [authorName, resourceName],
    );
  }

  /// `{authorName} has deleted the Workgroup : {resourceName}.`
  String audit_action_message_delete_workgroup(Object authorName, Object resourceName) {
    return Intl.message(
      '$authorName has deleted the Workgroup : $resourceName.',
      name: 'audit_action_message_delete_workgroup',
      desc: '',
      args: [authorName, resourceName],
    );
  }

  /// `{authorName} has edited the Workgroup : {resourceName}.`
  String audit_action_message_update_workgroup(Object authorName, Object resourceName) {
    return Intl.message(
      '$authorName has edited the Workgroup : $resourceName.',
      name: 'audit_action_message_update_workgroup',
      desc: '',
      args: [authorName, resourceName],
    );
  }

  /// `{authorName} has added a new member : {resourceName} to the Workgroup : {nameVarious}.`
  String audit_action_message_add_member(Object authorName, Object resourceName, Object nameVarious) {
    return Intl.message(
      '$authorName has added a new member : $resourceName to the Workgroup : $nameVarious.',
      name: 'audit_action_message_add_member',
      desc: '',
      args: [authorName, resourceName, nameVarious],
    );
  }

  /// `{authorName} has removed the member : {resourceName} from the Workgroup : {nameVarious}.`
  String audit_action_message_delete_member(Object authorName, Object resourceName, Object nameVarious) {
    return Intl.message(
      '$authorName has removed the member : $resourceName from the Workgroup : $nameVarious.',
      name: 'audit_action_message_delete_member',
      desc: '',
      args: [authorName, resourceName, nameVarious],
    );
  }

  /// `{authorName} has edited the member : {resourceName} from the Workgroup : {nameVarious}.`
  String audit_action_message_update_member(Object authorName, Object resourceName, Object nameVarious) {
    return Intl.message(
      '$authorName has edited the member : $resourceName from the Workgroup : $nameVarious.',
      name: 'audit_action_message_update_member',
      desc: '',
      args: [authorName, resourceName, nameVarious],
    );
  }

  /// `{authorName} has created a new folder : {resourceName} into the Workgroup {nameVarious}.`
  String audit_action_message_create_folder(Object authorName, Object resourceName, Object nameVarious) {
    return Intl.message(
      '$authorName has created a new folder : $resourceName into the Workgroup $nameVarious.',
      name: 'audit_action_message_create_folder',
      desc: '',
      args: [authorName, resourceName, nameVarious],
    );
  }

  /// `{authorName} has deleted the folder : {resourceName} from the Workgroup : {nameVarious}.`
  String audit_action_message_delete_folder(Object authorName, Object resourceName, Object nameVarious) {
    return Intl.message(
      '$authorName has deleted the folder : $resourceName from the Workgroup : $nameVarious.',
      name: 'audit_action_message_delete_folder',
      desc: '',
      args: [authorName, resourceName, nameVarious],
    );
  }

  /// `{authorName} has edited the folder : {resourceName} from the Workgroup : {nameVarious}.`
  String audit_action_message_update_folder(Object authorName, Object resourceName, Object nameVarious) {
    return Intl.message(
      '$authorName has edited the folder : $resourceName from the Workgroup : $nameVarious.',
      name: 'audit_action_message_update_folder',
      desc: '',
      args: [authorName, resourceName, nameVarious],
    );
  }

  /// `{authorName} has downloaded the folder : {resourceName} from the Workgroup : {nameVarious}.`
  String audit_action_message_download_folder(Object authorName, Object resourceName, Object nameVarious) {
    return Intl.message(
      '$authorName has downloaded the folder : $resourceName from the Workgroup : $nameVarious.',
      name: 'audit_action_message_download_folder',
      desc: '',
      args: [authorName, resourceName, nameVarious],
    );
  }

  /// `{authorName} has deleted the file : {resourceName} from the Workgroup {nameVarious}.`
  String audit_action_message_delete_workgroup_document(Object authorName, Object resourceName, Object nameVarious) {
    return Intl.message(
      '$authorName has deleted the file : $resourceName from the Workgroup $nameVarious.',
      name: 'audit_action_message_delete_workgroup_document',
      desc: '',
      args: [authorName, resourceName, nameVarious],
    );
  }

  /// `{authorName} has edited the file : {resourceName} from the Workgroup {nameVarious}.`
  String audit_action_message_update_workgroup_document(Object authorName, Object resourceName, Object nameVarious) {
    return Intl.message(
      '$authorName has edited the file : $resourceName from the Workgroup $nameVarious.',
      name: 'audit_action_message_update_workgroup_document',
      desc: '',
      args: [authorName, resourceName, nameVarious],
    );
  }

  /// `{authorName} has downloaded the file : {resourceName} from the Workgroup {nameVarious}.`
  String audit_action_message_download_workgroup_document(Object authorName, Object resourceName, Object nameVarious) {
    return Intl.message(
      '$authorName has downloaded the file : $resourceName from the Workgroup $nameVarious.',
      name: 'audit_action_message_download_workgroup_document',
      desc: '',
      args: [authorName, resourceName, nameVarious],
    );
  }

  /// `{authorName} has upload a new file : {resourceName} into the Workgroup : {nameVarious}.`
  String audit_action_message_upload_workgroup_document(Object authorName, Object resourceName, Object nameVarious) {
    return Intl.message(
      '$authorName has upload a new file : $resourceName into the Workgroup : $nameVarious.',
      name: 'audit_action_message_upload_workgroup_document',
      desc: '',
      args: [authorName, resourceName, nameVarious],
    );
  }

  /// `{authorName} has created the document : {resourceName} into {nameVarious}, from {whose} Personal Space.`
  String audit_action_message_copy_document_from_personal_space(Object authorName, Object resourceName, Object nameVarious, Object whose) {
    return Intl.message(
      '$authorName has created the document : $resourceName into $nameVarious, from $whose Personal Space.',
      name: 'audit_action_message_copy_document_from_personal_space',
      desc: '',
      args: [authorName, resourceName, nameVarious, whose],
    );
  }

  /// `{authorName} has created the document : {resourceName} into {nameVarious}, from {whose} received share.`
  String audit_action_message_copy_document_from_received_share(Object authorName, Object resourceName, Object nameVarious, Object whose) {
    return Intl.message(
      '$authorName has created the document : $resourceName into $nameVarious, from $whose received share.',
      name: 'audit_action_message_copy_document_from_received_share',
      desc: '',
      args: [authorName, resourceName, nameVarious, whose],
    );
  }

  /// `{authorName} has created this file by copying : {resourceName} from another Workgroup.`
  String audit_action_message_copy_document_from_shared_space(Object authorName, Object resourceName) {
    return Intl.message(
      '$authorName has created this file by copying : $resourceName from another Workgroup.',
      name: 'audit_action_message_copy_document_from_shared_space',
      desc: '',
      args: [authorName, resourceName],
    );
  }

  /// `{authorName} has copied the document : {resourceName} into {whose} Personal Space.`
  String audit_action_message_copy_document_to_personal_space(Object authorName, Object resourceName, Object whose) {
    return Intl.message(
      '$authorName has copied the document : $resourceName into $whose Personal Space.',
      name: 'audit_action_message_copy_document_to_personal_space',
      desc: '',
      args: [authorName, resourceName, whose],
    );
  }

  /// `{authorName} has created a duplicated of this file into {nameVarious}.`
  String audit_action_message_copy_document_to_shared_space(Object authorName, Object nameVarious) {
    return Intl.message(
      '$authorName has created a duplicated of this file into $nameVarious.',
      name: 'audit_action_message_copy_document_to_shared_space',
      desc: '',
      args: [authorName, nameVarious],
    );
  }

  /// `A version of the file {resourceName} has been added in the workgroup {nameVarious}.`
  String audit_action_message_upload_revision(Object resourceName, Object nameVarious) {
    return Intl.message(
      'A version of the file $resourceName has been added in the workgroup $nameVarious.',
      name: 'audit_action_message_upload_revision',
      desc: '',
      args: [resourceName, nameVarious],
    );
  }

  /// `The version of the file {resourceName} had been removed from the workgroup {nameVarious}.`
  String audit_action_message_delete_revision(Object resourceName, Object nameVarious) {
    return Intl.message(
      'The version of the file $resourceName had been removed from the workgroup $nameVarious.',
      name: 'audit_action_message_delete_revision',
      desc: '',
      args: [resourceName, nameVarious],
    );
  }

  /// `The document was restore with the version {resourceName}.`
  String audit_action_message_copy_revision_from_shared_space(Object resourceName) {
    return Intl.message(
      'The document was restore with the version $resourceName.',
      name: 'audit_action_message_copy_revision_from_shared_space',
      desc: '',
      args: [resourceName],
    );
  }

  /// `{authorName} has downloaded the version : {resourceName} from the workgroup {nameVarious}.`
  String audit_action_message_download_revision(Object authorName, Object resourceName, Object nameVarious) {
    return Intl.message(
      '$authorName has downloaded the version : $resourceName from the workgroup $nameVarious.',
      name: 'audit_action_message_download_revision',
      desc: '',
      args: [authorName, resourceName, nameVarious],
    );
  }

  /// `You`
  String get you {
    return Intl.message(
      'You',
      name: 'you',
      desc: '',
      args: [],
    );
  }

  /// `Me`
  String get me {
    return Intl.message(
      'Me',
      name: 'me',
      desc: '',
      args: [],
    );
  }

  /// `his`
  String get his {
    return Intl.message(
      'his',
      name: 'his',
      desc: '',
      args: [],
    );
  }

  /// `your`
  String get your {
    return Intl.message(
      'your',
      name: 'your',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'messages'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}