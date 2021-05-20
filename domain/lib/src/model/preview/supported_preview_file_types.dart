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
// Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
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

class SupportedPreviewFileTypes {
  static const imageMimeTypes = [
    'image/bmp',
    'image/jpeg',
    'image/gif',
    'image/png',];

  static const iOSSupportedTypes = {
    'text/plain' : 'public.plain-text',
    'text/html' : 'public.html',
    'video/x-msvideo' : 'public.avi',
    'video/mpeg' : 'public.mpeg',
    'video/mp4' : 'public.mpeg-4',
    'video/3gpp' : 'public.3gpp',
    'video/quicktime' : 'public.mpeg-4',
    'audio/mpeg' : 'public.mp3',
    'audio/wav' : 'com.microsoft.waveform-​audio',
    'audio/x-ms-wmv' : 'com.microsoft.windows-​media-wmv',
    'image/jpeg' : 'public.jpeg',
    'image/png' : 'public.png',
    'image/gif' : 'com.compuserve.gif',
    'image/bmp' : 'com.microsoft.bmp',
    'image/vnd.microsoft.icon' : 'com.microsoft.ico',
    'application/zip' : 'com.pkware.zip-archive',
    'application/rtf' : 'public.rtf',
    'application/xml' : 'public.xml',
    'application/x-tar' : 'public.tar-archive',
    'application/gzip' : 'org.gnu.gnu-zip-archive',
    'application/x-compressed' : 'org.gnu.gnu-zip-tar-archive',
    'application/msword' : 'com.microsoft.word.doc',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' : 'com.microsoft.word.doc',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' : 'com.microsoft.excel.xls',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' : 'com.microsoft.powerpoint.​ppt',
    'application/pdf' : 'com.adobe.pdf',
    'application/vnd.oasis.opendocument.text' : 'com.microsoft.word.doc',
    'application/vnd.oasis.opendocument.spreadsheet' : 'com.microsoft.excel.xls',
    'application/vnd.oasis.opendocument.presentation' : 'com.microsoft.powerpoint.​ppt',
  };

  static const androidSupportedTypes = [
    'image/bmp',
    'image/jpeg',
    'image/gif',
    'image/png',
    'text/plain',
    'text/html',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.oasis.opendocument.text',
    'application/vnd.oasis.opendocument.spreadsheet',
    'application/vnd.oasis.opendocument.presentation',
    'application/msword',
    'application/vnd.ms-excel',
    'application/vnd.ms-powerpoint',
    'application/vnd.ms-outlook',
    'application/vnd.ms-works',
    'application/vnd.mpohun.certificate',
    'application/vnd.android.package-archive',
    'application/octet-stream',
    'application/x-tar',
    'application/x-gtar',
    'application/x-gzip',
    'application/x-javascript',
    'application/x-compressed',
    'application/x-zip-compressed',
    'application/java-archive',
    'application/pdf',
    'application/rtf',
    'audio/x-mpegurl',
    'video/x-m4v',
    'video/x-ms-asf',
    'video/x-msvideo',
    'audio/x-mpeg',
    'audio/mp4a-latm',
    'video/vnd.mpegurl',
    'video/quicktime',
    'video/mp4',
    'video/3gpp',
    'video/mpeg',
    'audio/mpeg',
    'audio/ogg',
    'audio/x-pn-realaudio',
    'audio/x-wav',
    'audio/x-ms-wma',
    'audio/x-ms-wmv',
  ];
}
