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
import 'package:intl/intl.dart';
import 'package:linshare_flutter_app/l10n/messages_all.dart';

class AppLocalizations {

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Future<AppLocalizations> load(Locale locale) async {
    final name = locale.countryCode == null ? locale.languageCode : locale.toString();

    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  String get initializing_data {
    return Intl.message('Initializing data...',
      name: 'initializing_data');
  }

  String get login_text_slogan {
    return Intl.message('Store and share your files from anywhere',
      name: 'login_text_slogan');
  }

  String get login_text_login_to_continue {
    return Intl.message('Please login to continue',
      name: 'login_text_login_to_continue');
  }

  String get https {
    return Intl.message('https://',
      name: 'https');
  }

  String get email {
    return Intl.message('email',
      name: 'email');
  }

  String get password {
    return Intl.message('password',
      name: 'password');
  }

  String get login_button_login {
    return Intl.message('Login',
      name: 'login_button_login');
  }

  String get upload_file_title {
    return Intl.message('Upload file',
      name: 'upload_file_title');
  }

  String get upload_text_button {
    return Intl.message('Upload to My Space',
      name: 'upload_text_button');
  }

  String get my_space_title {
    return Intl.message('My Space',
      name: 'my_space_title');
  }

  String get upload_prepare_text {
    return Intl.message('Preparing to upload...',
      name: 'upload_prepare_text');
  }

  String get my_space_text_upload_your_files_here {
    return Intl.message('Upload your files here',
      name: 'my_space_text_upload_your_files_here');
  }

  String get upload_failure_text {
    return Intl.message('Failed to upload file',
      name: 'upload_failure_text');
  }

  String get upload_success_text {
    return Intl.message('File uploaded',
      name: 'upload_success_text');
  }

  String get wrong_url_message {
    return Intl.message('Server URL is not valid, please try again',
      name: 'wrong_url_message');
  }

  String get credential_error_message {
    return Intl.message('Authentication failed, either the email or the password is invalid, please try again',
      name: 'credential_error_message');
  }

  String get unknown_error_login_message {
    return Intl.message('Unknown error occurred, please try again',
      name: 'unknown_error_login_message');
  }

  String get download_to_device {
    return Intl.message('Download to device',
      name: 'download_to_device');
  }

  String get share {
    return Intl.message('Share',
        name: 'share');
  }

  String get title_quick_share {
    return Intl.message('Quick Share',
        name: 'title_quick_share');
  }

  String get add_recipients {
    return Intl.message('Add recipients',
        name: 'add_recipients');
  }

  String get add_people {
    return Intl.message('Add people',
        name: 'add_people');
  }

  String get file_is_successfully_shared {
    return Intl.message('The file is successfully shared',
        name: 'file_is_successfully_shared');
  }

  String get file_could_not_be_share {
    return Intl.message('The file could not be shared',
        name: 'file_could_not_be_share');
  }

  String item_last_modified(String dateString) =>
    Intl.message('Modified $dateString',
        name: 'item_last_modified',
        args: [dateString]);

  String get my_space {
    return Intl.message('My Space', name: 'my_space');
  }

  String get common_error_occured_message {
    return Intl.message('Unexpected error occurs\nPlease reload or try again later');
  }

  String get export_file {
    return Intl.message('Export file',
        name: 'export_file');
  }

  String get preparing_to_export {
    return Intl.message('Preparing to export',
        name: 'preparing_to_export');
  }

  String get cancel {
    return Intl.message('Cancel',
        name: 'cancel');
  }

  String downloading_file(String fileName) =>
      Intl.message('Downloading $fileName',
          name: 'downloading_file',
          args: [fileName]);

  String get logout {
    return Intl.message('Log out',
        name: 'logout');
  }

  String get confirm_remove_account_title {
    return Intl.message('Are you sure you want to log out of this account ?',
        name: 'confirm_remove_account_title');
  }

  String get shared_space {
    return Intl.message('Shared space',
        name: 'shared_space');
  }

  String get do_not_have_any_workgroup {
    return Intl.message('You don\'t have any workgroup yet',
        name: 'do_not_have_any_workgroup');
  }

  String get not_have_received_yet {
    return Intl.message('View your received shares',
        name: 'not_have_received_yet');
  }

  String get unknown_user {
    return Intl.message('Unknown user',
        name: 'unknown_user');
  }

  String get upload_and_share_button {
    return Intl.message(
      'Upload and Share',
      name: 'upload_and_share_button',
    );
  }

  String sharing_single_after_uploaded_success(String recipientName) {
    return Intl.message(
      'The file is uploaded and shared with $recipientName',
      name: 'sharing_single_after_uploaded_success',
      args: [recipientName],
    );
  }

  String sharing_multiple_after_uploaded_success(int numberOfRecipients) {
    return Intl.message(
      'The file is uploaded and shared with $numberOfRecipients people',
      name: 'sharing_multiple_after_uploaded_success',
      args: [numberOfRecipients],
    );
  }

  String get sharing_after_uploaded_failure {
    return Intl.message(
      'The file will be ready for upload and sharing once connection is available',
      name: 'sharing_after_uploaded_failure',
    );
  }

  String get workgroup_nodes_surfing_root_back_title {
    return Intl.message(
      'Back to Shared Space',
      name: 'workgroup_nodes_surfing_root_back_title',
    );
  }

    String get workgroup_nodes_surfing_sort_type_title {
    return Intl.message(
      'Modification date',
      name: 'workgroup_nodes_surfing_sort_type_title',
    );
  }

  String get destination {
    return Intl.message(
      'Destination',
      name: 'destination',
    );
  }

  String get upload_to_workspace {
    return Intl.message(
      'Upload to Workspace',
      name: 'upload_to_workspace',
    );
  }

  String get photos_and_videos {
    return Intl.message(
      'Photos and Videos',
      name: 'photos_and_videos',
    );
  }

  String get browse {
    return Intl.message(
      'Browse',
      name: 'browse',
    );
  }

  String get select_all {
    return Intl.message(
      'Select all',
      name: 'select_all',
    );
  }

  String get unselect_all {
    return Intl.message(
      'Unselect all',
      name: 'unselect_all',
    );
  }

  String items(int numberOfItems) {
    return Intl.message(
      '''${Intl.plural(numberOfItems,
          zero: 'No item',
          one: '$numberOfItems item',
          other: '$numberOfItems items')}''',
      name: 'items',
      args: [numberOfItems],
    );
  }

  String items_selected(int numberOfItems) {
    return Intl.message(
      '''${Intl.plural(numberOfItems,
          one: '$numberOfItems item selected',
          other: '$numberOfItems items selected')}''',
      name: 'items_selected',
      args: [numberOfItems],
    );
  }

  String get uploading_files_status_title {
    return Intl.message(
      'Uploading files',
      name: 'uploading_files_status_title',
    );
  }

  String get uploading_files_view_button {
    return Intl.message(
      'View',
      name: 'uploading_files_view_button',
    );
  }

  String get current_uploads_screen_title {
    return Intl.message(
      'Current uploads',
      name: 'current_uploads_screen_title',
    );
  }

  String get current_uploads_my_space_tab {
    return Intl.message(
      'My Space',
      name: 'current_uploads_my_space_tab',
    );
  }

  String get current_uploads_shared_space_tab {
    return Intl.message(
      'Shared Space',
      name: 'current_uploads_shared_space_tab',
    );
  }

  String get current_uploads_waiting_status {
    return Intl.message(
      'Waiting',
      name: 'current_uploads_waiting_status',
    );
  }

  String get current_uploads_uploading_status {
    return Intl.message(
      'Uploading',
      name: 'current_uploads_uploading_status',
    );
  }

  String get current_uploads_upload_failed_status {
    return Intl.message(
      'Upload failed',
      name: 'current_uploads_upload_failed_status',
    );
  }

  String get current_uploads_share_failed_status {
    return Intl.message(
      'Share failed',
      name: 'current_uploads_share_failed_status',
    );
  }

  String get current_uploads_succeed_status {
    return Intl.message(
      'Completed',
      name: 'current_uploads_succeed_status',
    );
  }

  String get pick_the_destination {
    return Intl.message(
      'Pick the destination',
      name: 'pick_the_destination',
    );
  }

  String get copy_here {
    return Intl.message(
      'copy here',
      name: 'copy_here',
    );
  }

  String get copy_to_a_workgroup {
    return Intl.message(
      'Copy to a workgroup',
      name: 'copy_to_a_workgroup',
    );
  }

  String get the_file_is_copied_to_a_shared_space {
    return Intl.message(
      'The file is copied to a Shared space',
      name: 'the_file_is_copied_to_a_shared_space',
    );
  }

  String get cannot_copy_file_to_shared_space {
    return Intl.message(
      'Can not copy file to Shared space',
      name: 'cannot_copy_file_to_shared_space',
    );
  }

  String get some_items_could_not_be_copied_to_shared_space {
    return Intl.message(
      'Some items could not be copied to Shared space',
      name: 'some_items_could_not_be_copied_to_shared_space',
    );
  }

  String are_you_sure_you_want_to_delete_multiple(int numberOfItems, String singleItemName) {
    return Intl.message(
      '''${Intl.plural(numberOfItems,
          one: 'Are you sure you want to delete \"$singleItemName\"?',
          other: 'Are you sure you want to delete $numberOfItems items?')}''',
      name: 'are_you_sure_you_want_to_delete_multiple',
      args: [numberOfItems, singleItemName],
    );
  }

  String get the_file_has_been_successfully_deleted {
    return Intl.message(
      'The file has been successfully deleted',
      name: 'the_file_has_been_successfully_deleted',
    );
  }

  String get files_have_been_successfully_deleted {
    return Intl.message(
      'Files have been successfully deleted',
      name: 'files_have_been_successfully_deleted',
    );
  }

  String get the_file_could_not_be_deleted {
    return Intl.message(
      'The file could not be deleted',
      name: 'the_file_could_not_be_deleted',
    );
  }

  String get files_could_not_be_deleted {
    return Intl.message(
      'Files could not be deleted',
      name: 'files_could_not_be_deleted',
    );
  }

  String get some_items_could_not_be_deleted {
    return Intl.message(
      'Some items could not be deleted',
      name: 'some_items_could_not_be_deleted',
    );
  }

  String get some_items_are_successfully_deleted {
    return Intl.message(
      'Some items are successfully deleted',
      name: 'some_items_are_successfully_deleted',
    );
  }

  String downloading_files(int numberOfFiles) {
    return Intl.message(
      '''${Intl.plural(numberOfFiles,
          one: 'Downloading $numberOfFiles file',
          other: 'Downloading $numberOfFiles files')}''',
      name: 'downloading_files',
      args: [numberOfFiles],
    );
  }

  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
    );
  }

  String get can_not_connect_network {
    return Intl.message(
      'Cannot connect to the network',
      name: 'can_not_connect_network',
    );
  }

  String get can_not_proceed_while_offline {
    return Intl.message(
      'Cannot process while offline',
      name: 'can_not_proceed_while_offline',
    );
  }

  String get choose {
    return Intl.message(
      'choose',
      name: 'choose',
    );
  }

  String get account_details_title {
    return Intl.message(
      'Account Details',
      name: 'account_details_title',
    );
  }

  String get account_details {
    return Intl.message(
      'Account details',
      name: 'account_details',
    );
  }

  String get first_name {
    return Intl.message(
      'First name',
      name: 'first_name',
    );
  }

  String get last_name {
    return Intl.message(
      'Last name',
      name: 'last_name',
    );
  }

  String get last_login {
    return Intl.message(
      'Last login',
      name: 'last_login',
    );
  }

  String get available_space {
    return Intl.message(
      'Available space',
      name: 'available_space',
    );
  }

  String available_space_value(String quota, String usedSpace) =>
    Intl.message('$usedSpace on $quota',
        name: 'available_space_value',
        args: [quota, usedSpace]);

  String get received_shares {
    return Intl.message(
      'Received shares',
      name: 'received_shares',
    );
  }

  String get received {
    return Intl.message(
      'Received',
      name: 'received',
    );
  }

  String item_created_date(String dateString) =>
      Intl.message('Created $dateString',
          name: 'item_created_date',
          args: [dateString]);

  String notEnoughQuota(String quota) {
    return Intl.message(
      'You have reached the max quota of $quota',
      name: 'notEnoughQuota',
      args: [quota],
    );
  }

  String tooBigFiles(int nbFiles, String quota, String firstElementName) {
    return Intl.message(
      '''${Intl.plural(nbFiles,
          one: '$firstElementName has exceeded the max file of $quota',
          other: 'Some files have exceeded the max file of $quota')}''',
      name: 'tooBigFiles',
      args: [nbFiles, quota, firstElementName],
    );
  }

  String get copy_to_my_space {
    return Intl.message(
      'Copy to My Space',
      name: 'copy_to_my_space',
    );
  }

  String get the_file_has_been_copied_successfully {
    return Intl.message(
      'The file has been copied successfully',
      name: 'the_file_has_been_copied_successfully',
    );
  }

  String get the_file_could_not_be_copied {
    return Intl.message(
      'The file could not be copied',
      name: 'the_file_could_not_be_copied',
    );
  }

  String get cannot_copy_files_to_my_space {
    return Intl.message(
      'Can not copy files to My Space',
      name: 'cannot_copy_files_to_my_space',
    );
  }

  String get some_items_have_been_copied_to_my_space {
    return Intl.message(
      'Some items have been copied to My Space',
      name: 'some_items_have_been_copied_to_my_space',
    );
  }

  String get all_items_have_been_copied_to_my_space {
    return Intl.message(
      'All items have been copied to My Space',
      name: 'all_items_have_been_copied_to_my_space',
    );
  }

  String get search_in_my_space {
    return Intl.message(
      'Search in My Space',
      name: 'search_in_my_space',
    );
  }

  String get search_in_shared_space_files {
    return Intl.message(
      'Search in Shared Space files',
      name: 'search_in_shared_space_files',
    );
  }

  String results_count(int numberOfResults) {
    return Intl.message(
      '''${Intl.plural(numberOfResults,
          zero: '$numberOfResults result',
          one: '$numberOfResults result',
          other: '$numberOfResults results')}''',
      name: 'results_count',
      args: [numberOfResults],
    );
  }

  String get no_results_found {
    return Intl.message(
      'No results found',
      name: 'no_results_found',
    );
  }

  String get search_in_shared_space {
    return Intl.message(
      'Search in Shared Space',
      name: 'search_in_shared_space',
    );
  }

  String shared_spaces_could_not_be_deleted(int sharedSpacesNumber) {
    return Intl.message(
      '''${Intl.plural(sharedSpacesNumber,
          one: 'The Shared Space could not be deleted',
          other: 'Shared Spaces could not be deleted')}''',
      name: 'shared_spaces_could_not_be_deleted',
      args: [sharedSpacesNumber],
    );
  }

  String get shared_space_has_been_deleted {
    return Intl.message(
      'The Shared Space has been deleted',
      name: 'shared_space_has_been_deleted',
    );
  }

  String get all_shared_spaces_have_been_deleted {
    return Intl.message(
      'All Shared Spaces have been deleted',
      name: 'all_shared_spaces_have_been_deleted',
    );
  }

  String get preview {
    return Intl.message(
      'Preview',
      name: 'preview',
    );
  }

  String get no_preview_available {
    return Intl.message(
      'No preview available',
      name: 'no_preview_available',
    );
  }

  String get preparing_to_preview_file {
    return Intl.message(
      'Preparing to preview file',
      name: 'preparing_to_preview_file'
    );
  }

  String get add_new_file_or_folder {
    return Intl.message(
      'Add new file or folder',
      name: 'add_new_file_or_folder',
    );
  }

  String get create_folder {
    return Intl.message(
      'Create Folder',
      name: 'create_folder',
    );
  }

  String get new_folder {
    return Intl.message(
      'New folder',
      name: 'new_folder',
    );
  }

  String get rename {
    return Intl.message(
      'Rename',
      name: 'rename',
    );
  }

  String get create_new_folder {
    return Intl.message(
      'Create new folder',
      name: 'create_new_folder',
    );
  }

  String get modification_date {
    return Intl.message(
      'Modification date',
      name: 'modification_date',
    );
  }

  String get creation_date {
    return Intl.message(
      'Creation date',
      name: 'creation_date',
    );
  }

  String get size {
    return Intl.message(
      'Size',
      name: 'size',
    );
  }

  String get name {
    return Intl.message(
      'Name',
      name: 'name',
    );
  }

  String get shared {
    return Intl.message(
      'Shared',
      name: 'shared',
    );
  }

  String get order_by {
    return Intl.message('Order by',
        name: 'order_by');
  }

  String get details {
    return Intl.message(
      'Details',
      name: 'details',
    );
  }

  String get members {
    return Intl.message(
      'Members',
      name: 'members',
    );
  }

  String get modified {
    return Intl.message(
      'Modified',
      name: 'modified',
    );
  }

  String get created {
    return Intl.message(
      'Created',
      name: 'created',
    );
  }

  String get my_rights {
    return Intl.message(
      'My rights',
      name: 'my_rights',
    );
  }

  String get max_file_size {
    return Intl.message(
      'Max file size',
      name: 'max_file_size',
    );
  }

  String get description {
    return Intl.message(
      'Description',
      name: 'description',
    );
  }

  String get no_description {
    return Intl.message(
      'No description',
      name: 'no_description',
    );
  }

  String get copy_to {
    return Intl.message(
      'Copy to',
      name : 'copy_to'
    );
  }

  String get admin {
    return Intl.message(
      'Admin',
      name: 'admin',
    );
  }

  String get reader {
    return Intl.message(
      'Reader',
      name: 'reader',
    );
  }

  String get contributor {
    return Intl.message(
      'Contributor',
      name: 'contributor',
    );
  }

  String get writer {
    return Intl.message(
      'Writer',
      name: 'writer',
    );
  }

  String get unknown_role {
    return Intl.message(
      'Unknown Role',
      name: 'unknown_role',
    );
  }

  String get activities {
    return Intl.message(
      'Activities',
      name: 'activities',
    );
  }

  String audit_log_actor(String actorName) {
    return Intl.message(
      'by $actorName',
      name: 'audit_log_actor',
      args: [actorName]
    );
  }

  String get audit_action_title_addition {
    return Intl.message(
      'Addition:',
      name: 'audit_action_title_addition',
    );
  }

  String get audit_action_title_delete {
    return Intl.message(
      'Delete:',
      name: 'audit_action_title_delete',
    );
  }

  String get audit_action_title_update {
    return Intl.message(
      'Update:',
      name: 'audit_action_title_update',
    );
  }

  String get audit_action_title_create {
    return Intl.message(
      'Creation:',
      name: 'audit_action_title_create',
    );
  }

  String get audit_action_title_upload {
    return Intl.message(
      'Upload file:',
      name: 'audit_action_title_upload',
    );
  }

  String get audit_action_title_copy {
    return Intl.message(
      'Copy:',
      name: 'audit_action_title_copy',
    );
  }

  String get audit_action_title_download {
    return Intl.message(
      'Download:',
      name: 'audit_action_title_download',
    );
  }

  String get audit_action_title_upload_revision {
    return Intl.message(
      'Version uploaded:',
      name: 'audit_action_title_upload_revision',
    );
  }

  String get audit_action_title_delete_revision {
    return Intl.message(
      'Version deleted:',
      name: 'audit_action_title_delete_revision',
    );
  }

  String get audit_action_title_restore_revision {
    return Intl.message(
      'Restore version:',
      name: 'audit_action_title_restore_revision',
    );
  }

  String get audit_action_title_download_revision {
    return Intl.message(
      'Version downloaded:',
      name: 'audit_action_title_download_revision',
    );
  }

  String audit_action_message_create_workgroup(String authorName, String resourceName) {
    return Intl.message(
        '$authorName has created a new Workgroup : $resourceName.',
        name: 'audit_action_message_create_workgroup',
        args: [authorName, resourceName]
    );
  }

  String audit_action_message_delete_workgroup(String authorName, String resourceName) {
    return Intl.message(
        '$authorName has deleted the Workgroup : $resourceName.',
        name: 'audit_action_message_delete_workgroup',
        args: [authorName, resourceName]
    );
  }

  String audit_action_message_update_workgroup(String authorName, String resourceName) {
    return Intl.message(
        '$authorName has edited the Workgroup : $resourceName.',
        name: 'audit_action_message_update_workgroup',
        args: [authorName, resourceName]
    );
  }

  String audit_action_message_add_member(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has added a new member : $resourceName to the Workgroup : $nameVarious.',
        name: 'audit_action_message_add_member',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_delete_member(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has removed the member : $resourceName from the Workgroup : $nameVarious.',
        name: 'audit_action_message_delete_member',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_update_member(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has edited the member : $resourceName from the Workgroup : $nameVarious.',
        name: 'audit_action_message_update_member',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_create_folder(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has created a new folder : $resourceName into the Workgroup $nameVarious.',
        name: 'audit_action_message_create_folder',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_delete_folder(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has deleted the folder : $resourceName from the Workgroup : $nameVarious.',
        name: 'audit_action_message_delete_folder',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_update_folder(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has edited the folder : $resourceName from the Workgroup : $nameVarious.',
        name: 'audit_action_message_update_folder',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_download_folder(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has downloaded the folder : $resourceName from the Workgroup : $nameVarious.',
        name: 'audit_action_message_download_folder',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_delete_workgroup_document(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has deleted the file : $resourceName from the Workgroup $nameVarious.',
        name: 'audit_action_message_delete_workgroup_document',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_update_workgroup_document(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has edited the file : $resourceName from the Workgroup $nameVarious.',
        name: 'audit_action_message_update_workgroup_document',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_download_workgroup_document(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has downloaded the file : $resourceName from the Workgroup $nameVarious.',
        name: 'audit_action_message_download_workgroup_document',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_upload_workgroup_document(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has upload a new file : $resourceName into the Workgroup : $nameVarious.',
        name: 'audit_action_message_upload_workgroup_document',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_copy_document_from_personal_space(String authorName, String resourceName, String nameVarious, String whose) {
    return Intl.message(
        '$authorName has created the document : $resourceName into $nameVarious, from $whose Personal Space.',
        name: 'audit_action_message_copy_document_from_personal_space',
        args: [authorName, resourceName, nameVarious, whose]
    );
  }

  String audit_action_message_copy_document_from_received_share(String authorName, String resourceName, String nameVarious, String whose) {
    return Intl.message(
        '$authorName has created the document : $resourceName into $nameVarious, from $whose received share.',
        name: 'audit_action_message_copy_document_from_received_share',
        args: [authorName, resourceName, nameVarious, whose]
    );
  }

  String audit_action_message_copy_document_from_shared_space(String authorName, String resourceName) {
    return Intl.message(
        '$authorName has created this file by copying : $resourceName from another Workgroup.',
        name: 'audit_action_message_copy_document_from_shared_space',
        args: [authorName, resourceName]
    );
  }

  String audit_action_message_copy_document_to_personal_space(String authorName, String resourceName, String whose) {
    return Intl.message(
        '$authorName has copied the document : $resourceName into $whose Personal Space.',
        name: 'audit_action_message_copy_document_to_personal_space',
        args: [authorName, resourceName, whose]
    );
  }

  String audit_action_message_copy_document_to_shared_space(String authorName, String nameVarious) {
    return Intl.message(
        '$authorName has created a duplicated of this file into $nameVarious.',
        name: 'audit_action_message_copy_document_to_shared_space',
        args: [authorName, nameVarious]
    );
  }

  String audit_action_message_upload_revision(String resourceName, String nameVarious) {
    return Intl.message(
        'A version of the file $resourceName has been added in the workgroup $nameVarious.',
        name: 'audit_action_message_upload_revision',
        args: [resourceName, nameVarious]
    );
  }

  String audit_action_message_delete_revision(String resourceName, String nameVarious) {
    return Intl.message(
        'The version of the file $resourceName had been removed from the workgroup $nameVarious.',
        name: 'audit_action_message_delete_revision',
        args: [resourceName, nameVarious]
    );
  }

  String audit_action_message_copy_revision_from_shared_space(String resourceName) {
    return Intl.message(
        'The document was restore with the version $resourceName.',
        name: 'audit_action_message_copy_revision_from_shared_space',
        args: [resourceName]
    );
  }

  String audit_action_message_download_revision(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has downloaded the version : $resourceName from the workgroup $nameVarious.',
        name: 'audit_action_message_download_revision',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String get you {
    return Intl.message(
      'You',
      name: 'you',
    );
  }

  String get me {
    return Intl.message(
      'Me',
      name: 'me',
    );
  }

  String get his {
    return Intl.message(
      'his',
      name: 'his',
    );
  }

  String get your {
    return Intl.message(
      'your',
      name: 'your',
    );
  }

  String get second_factor_authentication_is_required_for_your_account {
    return Intl.message(
      'Second factor Authentication is required for your account',
      name: 'second_factor_authentication_is_required_for_your_account',
    );
  }

  String get please_enable_second_factor_authentication_to_continue {
    return Intl.message(
      'Please enable Second factor Authentication to continue',
      name: 'please_enable_second_factor_authentication_to_continue',
    );
  }

  String get go_to_setup {
    return Intl.message(
      'Go to Setup',
      name: 'go_to_setup',
    );
  }

  String get second_factor_authentication {
    return Intl.message(
      'SECOND FACTOR AUTHENTICATION',
      name : 'second_factor_authentication'
    );
  }

  String get input_6_digit_from_free_otp {
    return Intl.message(
      'Input the 6-digit code in your FreeOTP app',
      name : 'input_6_digit_from_free_otp'
    );
  }

  String get submit {
    return Intl.message(
      'Submit',
      name : 'submit'
    );
  }

  String get please_fill_up_all_numbers {
    return Intl.message(
      'Please fill up all numbers',
      name : 'please_fill_up_all_numbers'
    );
  }

  String get invalid_otp {
    return Intl.message(
      'Invalid OTP',
      name : 'invalid_otp'
    );
  }

  String get user_locked_message {
    return Intl.message(
        'Sorry! Your account is locked\nPlease contact the support to unlock!',
        name : 'user_locked_message'
    );
  }


  String get create_new_workgroup {
    return Intl.message(
      'Create new workgroup',
      name: 'create_new_workgroup',
    );
  }

  String get new_workgroup {
    return Intl.message(
      'New Workgroup',
      name: 'new_workgroup',
    );
  }

  String get create {
    return Intl.message(
      'Create',
      name: 'create',
    );
  }

  String rename_node(String nodeName) {
    return Intl.message(
        'Rename $nodeName',
        name: 'rename_node',
        args: [nodeName]
    );
  }

  String get workgroup {
    return Intl.message(
      'Workgroup',
      name: 'workgroup',
    );
  }

  String get file {
    return Intl.message(
      'File',
      name: 'file',
    );
  }

  String get folder {
    return Intl.message(
      'Folder',
      name: 'folder',
    );
  }

  String node_name_not_empty(String nodeName) {
    return Intl.message(
        '$nodeName name cannot be blank',
        name: 'node_name_not_empty',
        args: [nodeName]
    );
  }

  String node_name_already_exists(String nodeName) {
    return Intl.message(
        '$nodeName name already exists',
        name: 'node_name_already_exists',
        args: [nodeName]
    );
  }

  String node_name_contain_special_character(String nodeName) {
    return Intl.message(
        '$nodeName name cannot contain special characters',
        name: 'node_name_contain_special_character',
        args: [nodeName]
    );
  }

  String node_name_contain_last_dot(String nodeName) {
    return Intl.message(
        '$nodeName name cannot finishes by character "."',
        name: 'node_name_contain_last_dot',
        args: [nodeName]
    );
  }

  String get add_team_members {
    return Intl.message(
      'Add team members',
      name: 'add_team_members',
    );
  }

  String existing_members(int nbMembers) {
    return Intl.message(
      '''${Intl.plural(nbMembers,
          one: 'Existing member: ${nbMembers}',
          other: 'Existing members: ${nbMembers}')}''',
      name: 'existing_members',
      args: [nbMembers],
    );
  }

  String get the_file_has_been_successfully_renamed {
    return Intl.message(
      'The file has been successfully renamed',
      name: 'the_file_has_been_successfully_renamed',
    );
  }

  String get the_file_could_not_be_renamed {
    return Intl.message(
      'The file could not be renamed',
      name: 'the_file_could_not_be_renamed',
    );
  }

  String get sender {
    return Intl.message(
      'Sender',
      name: 'sender',
    );
  }

  String get search_in_my_received_shares {
    return Intl.message(
      'Search in Received Shares',
      name: 'search_in_my_received_shares',
    );
  }

  String are_you_sure_you_want_to_delete_member(String memberName, String workspaceName) {
    return Intl.message(
      'Are you sure you want to delete $memberName from $workspaceName?',
      name: 'are_you_sure_you_want_to_delete_member',
      args: [memberName, workspaceName],
    );
  }

  String get user_could_not_be_removed {
    return Intl.message(
      'The user could not be removed',
      name: 'user_could_not_be_removed',
    );
  }

  String get user_is_successfully_removed {
    return Intl.message(
      'The user is successfully removed',
      name: 'user_is_successfully_removed'
    );
  }

  String get expiration {
    return Intl.message(
      'Expiration',
      name: 'expiration',
    );
  }

  String shared_with(int nbContacts) {
    return Intl.message(
      '''${Intl.plural(nbContacts,
          zero: 'Shared with: $nbContacts contact',
          one: 'Shared with: $nbContacts contact',
          other: 'Shared with: $nbContacts contacts')}''',
      name: 'shared_with',
      args: [nbContacts],
    );
  }

  String get modified_by {
    return Intl.message(
      'Modified by',
      name: 'modified_by',
    );
  }

  String get biometric_authentication {
    return Intl.message('Biometric authentication',
        name: 'biometric_authentication');
  }

  String get face_id {
    return Intl.message('Face ID',
        name: 'face_id');
  }

  String get fingerprint {
    return Intl.message('Fingerprint',
        name: 'fingerprint');
  }

  String biometric_authentication_message(String biometricKind) {
    return Intl.message(
        'Allow $biometricKind to secure access to this app',
        name: 'biometric_authentication_message',
        args: [biometricKind]
    );
  }

  String biometric_authentication_not_enrolled(String biometricKind) {
    return Intl.message(
        '$biometricKind must be enabled to turn on biometric authentication',
        name: 'biometric_authentication_not_enrolled',
        args: [biometricKind]
    );
  }

  String get biometric_authentication_localized_reason_enable {
    return Intl.message('Please authenticate to enable biometric authentication for application',
        name: 'biometric_authentication_localized_reason_enable');
  }

  String get biometric_authentication_localized_reason_disable {
    return Intl.message('Please authenticate to disable biometric authentication for application',
        name: 'biometric_authentication_localized_reason_disable');
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi', 'fr', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
