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
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    return Intl.message('Log in',
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

  String file_has_been_successfully_shared(int sharesNumber) {
    return Intl.message(
      '''${Intl.plural(sharesNumber,
          one: 'The file has been successfully shared',
          other: 'The files have been successfully shared')}''',
      name: 'file_has_been_successfully_shared',
      args: [sharesNumber],
    );
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
    return Intl.message('Unexpected error occurs\nPlease reload or try again later',
        name: 'common_error_occured_message');
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

  String get the_files_could_not_be_copied_to_my_space {
    return Intl.message(
      'The files could not be copied to My Space',
      name: 'the_files_could_not_be_copied_to_my_space',
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
      'Create folder',
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

  String audit_action_message_create_workgroup_self(String resourceName) {
    return Intl.message(
        'You have created a new Workgroup : $resourceName.',
        name: 'audit_action_message_create_workgroup_self',
        args: [resourceName]
    );
  }

  String audit_action_message_create_workgroup_other(String authorName, String resourceName) {
    return Intl.message(
        '$authorName has created a new Workgroup : $resourceName.',
        name: 'audit_action_message_create_workgroup_other',
        args: [authorName, resourceName]
    );
  }

  String audit_action_message_delete_workgroup_self(String resourceName) {
    return Intl.message(
        'You have deleted the Workgroup : $resourceName.',
        name: 'audit_action_message_delete_workgroup_self',
        args: [resourceName]
    );
  }

  String audit_action_message_delete_workgroup_other(String authorName, String resourceName) {
    return Intl.message(
        '$authorName has deleted the Workgroup : $resourceName.',
        name: 'audit_action_message_delete_workgroup_other',
        args: [authorName, resourceName]
    );
  }

  String audit_action_message_update_workgroup_self(String resourceName) {
    return Intl.message(
        'You have edited the Workgroup : $resourceName.',
        name: 'audit_action_message_update_workgroup_self',
        args: [resourceName]
    );
  }

  String audit_action_message_update_workgroup_other(String authorName, String resourceName) {
    return Intl.message(
        '$authorName has edited the Workgroup : $resourceName.',
        name: 'audit_action_message_update_workgroup_other',
        args: [authorName, resourceName]
    );
  }

  String audit_action_message_add_member_self(String resourceName, String nameVarious) {
    return Intl.message(
        'You have added a new member : $resourceName to the Workgroup : $nameVarious.',
        name: 'audit_action_message_add_member_self',
        args: [resourceName, nameVarious]
    );
  }

  String audit_action_message_add_member_other(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has added a new member : $resourceName to the Workgroup : $nameVarious.',
        name: 'audit_action_message_add_member_other',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_delete_member_self(String resourceName, String nameVarious) {
    return Intl.message(
        'You have removed the member : $resourceName from the Workgroup : $nameVarious.',
        name: 'audit_action_message_delete_member_self',
        args: [resourceName, nameVarious]
    );
  }

  String audit_action_message_delete_member_other(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has removed the member : $resourceName from the Workgroup : $nameVarious.',
        name: 'audit_action_message_delete_member_other',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_update_member_self(String resourceName, String nameVarious) {
    return Intl.message(
        'You have edited the member : $resourceName from the Workgroup : $nameVarious.',
        name: 'audit_action_message_update_member_self',
        args: [resourceName, nameVarious]
    );
  }

  String audit_action_message_update_member_other(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has edited the member : $resourceName from the Workgroup : $nameVarious.',
        name: 'audit_action_message_update_member_other',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_create_folder_self(String resourceName, String nameVarious) {
    return Intl.message(
        'You have created a new folder : $resourceName into the Workgroup $nameVarious.',
        name: 'audit_action_message_create_folder_self',
        args: [resourceName, nameVarious]
    );
  }

  String audit_action_message_create_folder_other(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has created a new folder : $resourceName into the Workgroup $nameVarious.',
        name: 'audit_action_message_create_folder_other',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_delete_folder_self(String resourceName, String nameVarious) {
    return Intl.message(
        'You have deleted the folder : $resourceName from the Workgroup : $nameVarious.',
        name: 'audit_action_message_delete_folder_self',
        args: [resourceName, nameVarious]
    );
  }

  String audit_action_message_delete_folder_other(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has deleted the folder : $resourceName from the Workgroup : $nameVarious.',
        name: 'audit_action_message_delete_folder_other',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_update_folder_self(String resourceName, String nameVarious) {
    return Intl.message(
        'You have edited the folder : $resourceName from the Workgroup : $nameVarious.',
        name: 'audit_action_message_update_folder_self',
        args: [resourceName, nameVarious]
    );
  }

  String audit_action_message_update_folder_other(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has edited the folder : $resourceName from the Workgroup : $nameVarious.',
        name: 'audit_action_message_update_folder_other',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_download_folder_self(String resourceName, String nameVarious) {
    return Intl.message(
        'You have downloaded the folder : $resourceName from the Workgroup : $nameVarious.',
        name: 'audit_action_message_download_folder_self',
        args: [resourceName, nameVarious]
    );
  }

  String audit_action_message_download_folder_other(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has downloaded the folder : $resourceName from the Workgroup : $nameVarious.',
        name: 'audit_action_message_download_folder_other',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_delete_workgroup_document_self(String resourceName, String nameVarious) {
    return Intl.message(
        'You have deleted the file : $resourceName from the Workgroup $nameVarious.',
        name: 'audit_action_message_delete_workgroup_document_self',
        args: [resourceName, nameVarious]
    );
  }

  String audit_action_message_delete_workgroup_document_other(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has deleted the file : $resourceName from the Workgroup $nameVarious.',
        name: 'audit_action_message_delete_workgroup_document_other',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_update_workgroup_document_self(String resourceName, String nameVarious) {
    return Intl.message(
        'You have edited the file : $resourceName from the Workgroup $nameVarious.',
        name: 'audit_action_message_update_workgroup_document_self',
        args: [resourceName, nameVarious]
    );
  }


  String audit_action_message_update_workgroup_document_other(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has edited the file : $resourceName from the Workgroup $nameVarious.',
        name: 'audit_action_message_update_workgroup_document_other',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_download_workgroup_document_self(String resourceName, String nameVarious) {
    return Intl.message(
        'You have downloaded the file : $resourceName from the Workgroup $nameVarious.',
        name: 'audit_action_message_download_workgroup_document_self',
        args: [resourceName, nameVarious]
    );
  }

  String audit_action_message_download_workgroup_document_other(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has downloaded the file : $resourceName from the Workgroup $nameVarious.',
        name: 'audit_action_message_download_workgroup_document_other',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_upload_workgroup_document_self(String resourceName, String nameVarious) {
    return Intl.message(
        'You have uploaded a new file : $resourceName into the Workgroup : $nameVarious.',
        name: 'audit_action_message_upload_workgroup_document_self',
        args: [resourceName, nameVarious]
    );
  }

  String audit_action_message_upload_workgroup_document_other(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has uploaded a new file : $resourceName into the Workgroup : $nameVarious.',
        name: 'audit_action_message_upload_workgroup_document_other',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_copy_document_from_personal_space_self(String resourceName, String nameVarious) {
    return Intl.message(
        'You have created the document : $resourceName into $nameVarious, from your Personal Space.',
        name: 'audit_action_message_copy_document_from_personal_space_self',
        args: [resourceName, nameVarious]
    );
  }

  String audit_action_message_copy_document_from_personal_space_other(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has created the document : $resourceName into $nameVarious, from his Personal Space.',
        name: 'audit_action_message_copy_document_from_personal_space_other',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_copy_document_from_received_share_self(String resourceName, String nameVarious) {
    return Intl.message(
        'You have created the document : $resourceName into $nameVarious, from your received shares.',
        name: 'audit_action_message_copy_document_from_received_share_self',
        args: [resourceName, nameVarious]
    );
  }

  String audit_action_message_copy_document_from_received_share_other(String authorName, String resourceName, String nameVarious) {
    return Intl.message(
        '$authorName has created the document : $resourceName into $nameVarious, from his received shares.',
        name: 'audit_action_message_copy_document_from_received_share_other',
        args: [authorName, resourceName, nameVarious]
    );
  }

  String audit_action_message_copy_document_from_shared_space_self(String resourceName) {
    return Intl.message(
        'You have created this file by copying : $resourceName from another Workgroup.',
        name: 'audit_action_message_copy_document_from_shared_space_self',
        args: [resourceName]
    );
  }

  String audit_action_message_copy_document_from_shared_space_other(String authorName, String resourceName) {
    return Intl.message(
        '$authorName has created this file by copying : $resourceName from another Workgroup.',
        name: 'audit_action_message_copy_document_from_shared_space_other',
        args: [authorName, resourceName]
    );
  }

  String audit_action_message_copy_document_to_personal_space_self(String resourceName) {
    return Intl.message(
        'You have copied the document : $resourceName into your Personal Space.',
        name: 'audit_action_message_copy_document_to_personal_space_self',
        args: [resourceName]
    );
  }


  String audit_action_message_copy_document_to_personal_space_other(String authorName, String resourceName) {
    return Intl.message(
        '$authorName has copied the document : $resourceName into his Personal Space.',
        name: 'audit_action_message_copy_document_to_personal_space_other',
        args: [authorName, resourceName]
    );
  }

  String audit_action_message_copy_document_to_shared_space_self(String nameVarious) {
    return Intl.message(
        'You have created a duplicated of this file into $nameVarious.',
        name: 'audit_action_message_copy_document_to_shared_space_self',
        args: [nameVarious]
    );
  }

  String audit_action_message_copy_document_to_shared_space_other(String authorName, String nameVarious) {
    return Intl.message(
        '$authorName has created a duplicated of this file into $nameVarious.',
        name: 'audit_action_message_copy_document_to_shared_space_other',
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

  String get me {
    return Intl.message(
      'Me',
      name: 'me',
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
          one: 'Existing member: $nbMembers',
          other: 'Existing members: $nbMembers')}''',
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

  String get manage_version {
    return Intl.message(
      'Manage version',
      name: 'manage_version',
    );
  }

  String version(int version) {
    return Intl.message(
      'Version $version',
      name: 'version',
      args: [version],
    );
  }

  String get face {
    return Intl.message('Face',
        name: 'face');
  }

  String get touch_id {
    return Intl.message('TouchID',
        name: 'touch_id');
  }

  String get touch_id_or_face_id {
    return Intl.message(
        'TouchID or FaceID',
        name: 'touch_id_or_face_id'
    );
  }

  String get fingerprint_or_face {
    return Intl.message(
        'Fingerprint or Face',
        name: 'fingerprint_or_face'
    );
  }

  String biometric_authentication_localized_reason(String biometricKind) {
    return Intl.message(
        'Scan your $biometricKind to authentication',
        name: 'biometric_authentication_localized_reason',
        args: [biometricKind]
    );
  }

  String biometric_disabled_in_setting_app(String biometricKind) {
    return Intl.message(
        'Please enable $biometricKind in the Settings app on your phone to use biometric authentication',
        name: 'biometric_disabled_in_setting_app',
        args: [biometricKind]
    );
  }

  String open_with_biometric(String biometricKind) {
    return Intl.message(
        'Open with $biometricKind',
        name: 'open_with_biometric',
        args: [biometricKind]
    );
  }

  String get or {
    return Intl.message('Or',
        name: 'or');
  }

  String get go_to_sign_in {
    return Intl.message('Go to Sign-In',
        name: 'go_to_sign_in');
  }

  String get biometric_authentication_is_locked {
    return Intl.message('Biometric authentication is locked due to exceeded number of attempts.',
        name: 'biometric_authentication_is_locked');
  }

  String get duplicate {
    return Intl.message('Duplicate',
        name: 'duplicate');
  }

  String get files_have_been_successfully_duplicated {
    return Intl.message(
      'Files have been successfully duplicated',
      name: 'files_have_been_successfully_duplicated',
    );
  }

  String get files_could_not_be_duplicated {
    return Intl.message(
      'The files could not be duplicated',
      name: 'files_could_not_be_duplicated',
    );
  }

  String get some_files_could_not_be_duplicated {
    return Intl.message(
      'Some files could not be duplicated',
      name: 'some_files_could_not_be_duplicated',
    );
  }

  String get restore {
    return Intl.message(
      'Restore',
      name: 'restore',
    );
  }

  String get available_offline {
    return Intl.message('Available offline',
        name: 'available_offline');
  }

  String get files_will_be_made_available_for_offline_use {
    return Intl.message('The files will be made available for offline use.',
        name: 'files_will_be_made_available_for_offline_use');
  }

  String get files_will_no_longer_be_usable_without_be_network {
    return Intl.message('The files will no longer be usable without the network.',
        name: 'files_will_no_longer_be_usable_without_be_network');
  }

  String get file_cannot_be_switched_to_offline_mode {
    return Intl.message('This file cannot be switched to offline mode',
        name: 'file_cannot_be_switched_to_offline_mode');
  }

  String get login_sso_button {
    return Intl.message(
      'Login with SSO',
      name: 'login_sso_button',
    );
  }

  String get login_sso_failed {
    return Intl.message(
      'Login failed',
      name: 'login_sso_failed',
    );
  }

  String get upload_requests {
    return Intl.message(
      'Upload Requests',
      name: 'upload_requests',
    );
  }

  String get pending {
    return Intl.message(
      'Pending',
      name: 'pending',
    );
  }

  String get active_closed {
    return Intl.message(
      'Active / Closed',
      name: 'active_closed',
    );
  }

  String get archived {
    return Intl.message(
      'Archived',
      name: 'archived',
    );
  }

  String get create_upload_requests_here {
    return Intl.message(
      'Create upload requests here',
      name: 'create_upload_requests_here',
    );
  }

  String activated_date(String date) {
    return Intl.message(
        'Activated $date',
        name: 'activated_date',
        args: [date]
    );
  }

  String archived_date(String date) {
    return Intl.message(
        'Archived $date',
        name: 'archived_date',
        args: [date]
    );
  }

  String get active {
    return Intl.message(
      'Active',
      name: 'active',
    );
  }

  String get expired_closed {
    return Intl.message(
      'Expired / Closed',
      name: 'expired_closed',
    );
  }

  String get add_new_upload_request {
    return Intl.message(
      'Add new upload request',
      name: 'add_new_upload_request',
    );
  }

  String get collective_upload {
    return Intl.message(
      'Collective \nUpload',
      name: 'collective_upload',
    );
  }

  String get individual_upload {
    return Intl.message(
      'Individual \nUpload',
      name: 'individual_upload',
    );
  }

  String get create_collective_upload_request_title {
    return Intl.message(
      'Collective Upload',
      name: 'create_collective_upload_request_title',
    );
  }

  String get create_individual_upload_request_title {
    return Intl.message(
      'Individual Upload',
      name: 'create_individual_upload_request_title',
    );
  }

  String get create_upload_request_button {
    return Intl.message(
      'Create Upload Request',
      name: 'create_upload_request_button',
    );
  }

  String get email_subject {
    return Intl.message(
        'Email subject',
        name: 'email_subject'
    );
  }

  String get email_message {
    return Intl.message(
      'Email message',
      name: 'email_message'
    );
  }

  String get settings {
    return Intl.message(
        'Settings',
        name: 'settings'
    );
  }

  String get advanced_options {
    return Intl.message(
        'Advanced options',
        name: 'advanced_options'
    );
  }

  String get show_less {
    return Intl.message(
        'Show less',
        name: 'show_less'
    );
  }

  String get activation_date {
    return Intl.message(
        'Activation date',
        name: 'activation_date'
    );
  }

  String get expiration_date {
    return Intl.message(
        'Expiration date',
        name: 'expiration_date'
    );
  }

  String get reminder_date {
    return Intl.message(
        'Reminder date',
        name: 'reminder_date'
    );
  }

  String get max_number_of_files {
    return Intl.message(
        'Max number of files',
        name: 'max_number_of_files'
    );
  }

  String get max_size_of_a_file {
    return Intl.message(
        'Max size of a file',
        name: 'max_size_of_a_file'
    );
  }

  String get allow_deletion {
    return Intl.message(
        'Allow deletion',
        name: 'allow_deletion'
    );
  }

  String get allow_closure {
    return Intl.message(
        'Allow closure',
        name: 'allow_closure'
    );
  }

  String get notification_language {
    return Intl.message(
        'Notification Language',
        name: 'notification_language'
    );
  }

  String get max_number_files_error {
    return Intl.message(
        'Max number of files must be set and smaller than 1000',
        name: 'max_number_files_error'
    );
  }

  String get max_file_size_error {
    return Intl.message(
        'Max size of a file must be set and smaller than 100 GB',
        name: 'max_file_size_error'
    );
  }

  String get upload_requests_root_back_title {
    return Intl.message(
        'Back to Upload Requests',
        name: 'upload_requests_root_back_title'
    );
  }

  String get upload_requests_no_files_uploaded {
    return Intl.message(
        'No files uploaded yet',
        name: 'upload_requests_no_files_uploaded'
    );
  }

  String get status {
    return Intl.message(
        'Status',
        name: 'status'
    );
  }

  String get type {
    return Intl.message(
        'Type',
        name: 'type'
    );
  }

  String get search_in_upload_request_groups {
    return Intl.message(
      'Search in Upload Request Groups',
      name: 'search_in_upload_request_groups',
    );
  }

  String get total_size_of_files {
    return Intl.message(
        'Total size of files',
        name: 'total_size_of_files'
    );
  }

  String get password_protected {
    return Intl.message(
        'Password protected',
        name: 'password_protected'
    );
  }

  String get total_file_size_error {
    return Intl.message(
        'Total size of files must be set and smaller than 100 GB',
        name: 'total_file_size_error'
    );
  }

  String get add {
    return Intl.message('Add',
        name: 'add');
  }

  String get confirm_add_recipients_title {
    return Intl.message('You are about to add a recipient to this upload request ! Beware, this action cannot be undone',
        name: 'confirm_add_recipients_title');
  }

  String get recipients_have_been_successfully_added {
    return Intl.message(
      'Recipients have been successfully added',
      name: 'recipients_have_been_successfully_added'
    );
  }

  String confirm_cancel_multiple_upload_request(int numberOfItems, String singleItemName) {
    return Intl.message(
      '''${Intl.plural(numberOfItems,
          one: 'Are you sure you want to cancel \"$singleItemName\"?',
          other: 'Are you sure you want to cancel $numberOfItems items?')}''',
      name: 'confirm_cancel_multiple_upload_request',
      args: [numberOfItems, singleItemName],
    );
  }

  String get upload_request_proceed_button {
    return Intl.message(
      'Proceed',
      name: 'upload_request_proceed_button',
    );
  }

  String get upload_request_has_been_updated {
    return Intl.message(
      'Upload request has been updated',
      name: 'upload_request_has_been_updated',
    );
  }

  String get some_upload_requests_have_been_updated {
    return Intl.message(
      'Some upload requests have been updated',
      name: 'some_upload_requests_have_been_updated',
    );
  }

  String get upload_request_could_not_be_updated {
    return Intl.message(
      'Upload request could not be updated',
      name: 'upload_request_could_not_be_updated',
    );
  }

  String get some_upload_requests_could_not_be_updated {
    return Intl.message(
      'Some upload requests could not be updated',
      name: 'some_upload_requests_could_not_be_updated',
    );
  }


  String get archive {
    return Intl.message('Archive',
        name: 'archive');
  }

  String confirm_archive_multiple_upload_request(int numberOfItems, String singleItemName) {
    return Intl.message(
      '''${Intl.plural(numberOfItems,
          one: 'Are you sure you want to archive \"$singleItemName\"?',
          other: 'Are you sure you want to archive $numberOfItems items?')}''',
      name: 'confirm_archive_multiple_upload_request',
      args: [numberOfItems, singleItemName],
    );
  }

  String get copy_before_archiving {
    return Intl.message(
      'Copy all files to my personal space before archiving',
      name: 'copy_before_archiving',
    );
  }

  String get close {
    return Intl.message('Close',
        name: 'close');
  }

  String confirm_close_multiple_upload_request(int numberOfItems, String singleItemName) {
    return Intl.message(
      '''${Intl.plural(numberOfItems,
          one: 'Are you sure you want to close \"$singleItemName\"?',
          other: 'Are you sure you want to close $numberOfItems items?')}''',
      name: 'confirm_close_multiple_upload_request',
      args: [numberOfItems, singleItemName],
    );
  }

  String get search_in_upload_request_entries {
    return Intl.message(
      'Search in Upload Requests Entries',
      name: 'search_in_upload_request_entries',
    );
  }

  String get biometric_timeout_title {
    return Intl.message(
      'Set timeout',
      name: 'biometric_timeout_title',
    );
  }

  String biometric_timeout_second(int numberOfItems) {
    return Intl.message(
      '''${Intl.plural(numberOfItems,
          one: '$numberOfItems second',
          other: '$numberOfItems seconds')}''',
      name: 'biometric_timeout_second',
      args: [numberOfItems],
    );
  }

  String biometric_timeout_minute(int numberOfItems) {
    return Intl.message(
      '''${Intl.plural(numberOfItems,
          one: '$numberOfItems minute',
          other: '$numberOfItems minutes')}''',
      name: 'biometric_timeout_minute',
      args: [numberOfItems],
    );
  }

  String biometric_timeout_hour(int numberOfItems) {
    return Intl.message(
      '''${Intl.plural(numberOfItems,
          one: '$numberOfItems hour',
          other: '$numberOfItems hours')}''',
      name: 'biometric_timeout_hour',
      args: [numberOfItems],
    );
  }

  String search_in(String node) {
    return Intl.message(
      'Search in $node',
      name: 'search_in',
      args: [node]
    );
  }

  String get move {
    return Intl.message(
      'Move',
      name: 'move',
    );
  }

  String get move_here {
    return Intl.message(
      'Move here',
      name: 'move_here',
    );
  }

  String get versioning_enable {
    return Intl.message('Versioning enable',
        name: 'versioning_enable');
  }

  String get are_you_sure_want_to_remove_this_version {
    return Intl.message(
      'Are you sure want to remove this version? Beware, this action cannot be undone.',
      name: 'are_you_sure_want_to_remove_this_version',
    );
  }

  String advance_search_setting() {
    return Intl.message(
      'Advanced search settings',
      name: 'advance_search_setting',
    );
  }

  String advance_search_type_document() {
    return Intl.message(
      'Document',
      name: 'advance_search_type_document',
    );
  }

  String advance_search_type_pdf() {
    return Intl.message(
      'PDF',
      name: 'advance_search_type_pdf',
    );
  }

  String advance_search_type_spreadsheet() {
    return Intl.message(
      'Spreadsheet',
      name: 'advance_search_type_spreadsheet',
    );
  }

  String advance_search_type_image() {
    return Intl.message(
      'Image',
      name: 'advance_search_type_image',
    );
  }

  String advance_search_type_audio() {
    return Intl.message(
      'Audio',
      name: 'advance_search_type_audio',
    );
  }

  String advance_search_type_archive() {
    return Intl.message(
      'Archive',
      name: 'advance_search_type_archive',
    );
  }

  String advance_search_type_other() {
    return Intl.message(
      'Other',
      name: 'advance_search_type_other',
    );
  }

  String advance_search_date_any_time() {
    return Intl.message(
      'Any time',
      name: 'advance_search_date_any_time',
    );
  }

  String advance_search_date_past_day() {
    return Intl.message(
      'Past day',
      name: 'advance_search_date_past_day',
    );
  }

  String advance_search_date_past_week() {
    return Intl.message(
      'Past week',
      name: 'advance_search_date_past_week',
    );
  }

  String advance_search_date_past_month() {
    return Intl.message(
      'Past month',
      name: 'advance_search_date_past_month',
    );
  }

  String advance_search_date_past_year() {
    return Intl.message(
      'Past year',
      name: 'advance_search_date_past_year',
    );
  }

  String advance_search_button_reset() {
    return Intl.message(
      'Reset',
      name: 'advance_search_button_reset',
    );
  }

  String advance_search_button_apply() {
    return Intl.message(
      'Apply',
      name: 'advance_search_button_apply',
    );
  }

  String get this_feature_not_supported {
    return Intl.message('This feature is not currently supported',
        name: 'this_feature_not_supported');
  }

  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
    );
  }

  String get save {
    return Intl.message(
      'Save',
      name: 'save',
    );
  }

  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
    );
  }

  String get no {
    return Intl.message(
      'No',
      name: 'no',
    );
  }

  String get the_upload_request_has_been_updated_successfully {
    return Intl.message(
      'The upload request has been updated successfully!',
      name: 'the_upload_request_has_been_updated_successfully',
    );
  }

  String get the_upload_request_has_been_updated_failed {
    return Intl.message(
      'The upload request has been updated failed',
      name: 'the_upload_request_has_been_updated_failed',
    );
  }

  String get drive {
    return Intl.message('Drive',
        name: 'drive');
  }

  String get loading {
    return Intl.message(
      'Loading',
      name: 'loading',
    );
  }

  String get canceled {
    return Intl.message('Canceled',
        name: 'canceled');
  }

  String get back {
    return Intl.message(
        'Back',
        name: 'back'
    );
  }

  String get login_message_center {
    return Intl.message(
        'Join +10000 active users using LinShare to store and share files with ease',
        name: 'login_message_center'
    );
  }

  String get login_message_bottom {
    return Intl.message(
        'By default you connect to Linagora servers. If you are not sure about this setting, please contact your technical specialist.',
        name: 'login_message_bottom'
    );
  }

  String get create_an_account {
    return Intl.message(
        'Create an account',
        name: 'create_an_account'
    );
  }

  String get login_user_own_server_message_center {
    return Intl.message(
        'Before you can proceed, please choose a\n default server connection',
        name: 'login_user_own_server_message_center'
    );
  }

  String get checkbox_text_login_with_sso {
    return Intl.message(
        'My server is using a single sign-on(SSO)',
        name: 'checkbox_text_login_with_sso'
    );
  }

  String get login_email_title {
    return Intl.message('Email',
        name: 'login_email_title');
  }

  String get login_password_title {
    return Intl.message('Password',
        name: 'login_password_title');
  }

  String get hint_input_password_login {
    return Intl.message('Enter your password',
        name: 'hint_input_password_login');
  }

  String get hint_input_email_login {
    return Intl.message('Enter your email',
        name: 'hint_input_email_login');
  }

  String get email_is_required {
    return Intl.message('Email is required',
        name: 'email_is_required');
  }

  String get password_is_required {
    return Intl.message('Password is required',
        name: 'password_is_required');
  }

  String get url_is_invalid {
    return Intl.message('URL is invalid',
        name: 'url_is_invalid');
  }

  String get email_is_invalid {
    return Intl.message('Email is invalid',
        name: 'email_is_invalid');
  }

  String get password_is_invalid {
    return Intl.message('Password is invalid',
        name: 'password_is_invalid');
  }

  String get use_your_own_server {
    return Intl.message('Use your own server',
        name: 'use_your_own_server');
  }

  String get create_drive {
    return Intl.message(
        'Create Drive',
        name: 'create_drive'
    );
  }

  String get create_workgroup {
    return Intl.message(
        'Create Workgroup',
        name: 'create_workgroup'
    );
  }

  String get create_new_drive {
    return Intl.message(
      'Create new drive',
      name: 'create_new_drive',
    );
  }

  String get new_drive {
    return Intl.message(
      'New drive',
      name: 'new_drive',
    );
  }

  String get add_a_member {
    return Intl.message(
      'Add a member',
      name: 'add_a_member',
    );
  }

  String get add_team_members_with_roles {
    return Intl.message(
      'Add team members with roles',
      name: 'add_team_members_with_roles',
    );
  }

  String get role_in_this_drive {
    return Intl.message(
      'Role in this drive',
      name: 'role_in_this_drive',
    );
  }

  String get default_role_in_workgroups {
    return Intl.message(
      'Default role in workgroups',
      name: 'default_role_in_workgroups',
    );
  }

  String get member_default_role_of_all_workgroups_inside_this_drive {
    return Intl.message(
      'Member\'s default role of all workgroups inside this drive',
      name: 'member_default_role_of_all_workgroups_inside_this_drive',
    );
  }

  String get drive_admin {
    return Intl.message('Drive Admin',
        name: 'drive_admin');
  }

  String get drive_reader {
    return Intl.message('Drive Reader',
        name: 'drive_reader');
  }

  String get drive_writer {
    return Intl.message('Drive Writer',
        name: 'drive_writer');
  }

  String get workgroup_admin {
    return Intl.message('Workgroup Admin',
        name: 'workgroup_admin');
  }

  String get workgroup_reader {
    return Intl.message('Workgroup Reader',
        name: 'workgroup_reader');
  }

  String get workgroup_writer {
    return Intl.message('Workgroup Writer',
        name: 'workgroup_writer');
  }

  String get workgroup_contributor {
    return Intl.message(
      'Workgroup Contributor',
      name: 'workgroup_contributor',
    );
  }

  String are_you_sure_you_want_to_delete_drive_member(String memberName, String driveName) {
    return Intl.message(
      'Are you sure you want to delete $memberName from the drive $driveName and all related workgroups?',
      name: 'are_you_sure_you_want_to_delete_drive_member',
      args: [memberName, driveName],
    );
  }

  String get name_is_required {
    return Intl.message('Name is required',
        name: 'name_is_required');
  }

  String get surname_is_required {
    return Intl.message('Surname is required',
        name: 'surname_is_required');
  }

  String get sign_up_continue {
    return Intl.message('Continue',
        name: 'sign_up_continue');
  }

  String get sign_up_send_me_a_password {
    return Intl.message('Send me a password',
        name: 'sign_up_send_me_a_password');
  }

  String get sign_up_name_title {
    return Intl.message('Name',
        name: 'sign_up_name_title');
  }

  String get sign_up_surname_title {
    return Intl.message('Surname',
        name: 'sign_up_surname_title');
  }

  String get hint_input_sign_up_name {
    return Intl.message('Enter your name',
        name: 'hint_input_sign_up_name');
  }

  String get hint_input_sign_up_surname {
    return Intl.message('Enter your surname',
        name: 'hint_input_sign_up_surname');
  }

  String get sign_up_completed_title_center {
    return Intl.message(
        'Done, check your inbox',
        name: 'sign_up_completed_title_center'
    );
  }

  String sign_up_completed_message_center(String email) {
    return Intl.message(
        'A password has been sent to your email $email, check your email and\n continue login',
        name: 'sign_up_completed_message_center',
        args: [email]
    );
  }

  String get email_is_not_available{
    return Intl.message('Email is not available',
        name: 'email_is_not_available');
  }

  String get drive_member {
    return Intl.message(
        'Drive member',
        name: 'drive_member');
  }

  String get external_member {
    return Intl.message(
        'External member',
        name: 'external_member');
  }

  String get files {
    return Intl.message(
        'Files',
        name: 'files'
    );
  }

  String get recipient {
    return Intl.message(
        'Recipient',
        name: 'recipient'
    );
  }

  String get recipients {
    return Intl.message(
        'Recipients',
        name: 'recipients'
    );
  }

  String get meta_data {
    return Intl.message(
        'Meta-data',
        name: 'meta_data'
    );
  }

  String number_of_uploaded_files(int count) {
    return Intl.message(
        '$count file uploaded',
        name: 'number_of_uploaded_files',
        args: [count]
    );
  }

  String upload_request_group_modification_date(String date) {
    return Intl.message(
        'Updated at $date',
        name: 'upload_request_group_modification_date',
        args: [date]
    );
  }

  String get owner {
    return Intl.message(
        'Owner',
        name: 'owner'
    );
  }

  String get view {
    return Intl.message(
      'View',
      name: 'view',
    );
  }

  String get created_at {
    return Intl.message(
      'Created at',
      name: 'created_at',
    );
  }

  String get activated_at {
    return Intl.message(
      'Activated at',
      name: 'activated_at',
    );
  }

  String get collective {
    return Intl.message(
      'Collective',
      name: 'collective',
    );
  }

  String get max_total_file_size {
    return Intl.message(
      'Max total file size',
      name: 'max_total_file_size',
    );
  }

  String get max_size_per_file {
    return Intl.message(
      'Max size per file',
      name: 'max_size_per_file',
    );
  }

  String get notification_language_meta_data {
    return Intl.message(
      'Notification language',
      name: 'notification_language_meta_data',
    );
  }

  String get override_this_role_for_all_existing_workgroups {
    return Intl.message(
      'Override this role for all existing workgroups',
      name: 'override_this_role_for_all_existing_workgroups',
    );
  }

  String get update {
    return Intl.message(
      'Update',
      name: 'update',
    );
  }

  String get edit_default_workgroup_role {
    return Intl.message(
      'Edit default workgroup role',
      name: 'edit_default_workgroup_role',
    );
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
