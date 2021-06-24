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

import 'package:domain/domain.dart';
import 'package:test/test.dart';
import 'package:testshared/fixture/my_space_fixture.dart';
import 'package:testshared/testshared.dart';

void main() {
  group('preview_extension_test', () {
    test('isAndroidSupportedPreview() should return true with supported mime type', () {
      expect(true, document1.mediaType.isAndroidSupportedPreview());
    });

    test('isAndroidSupportedPreview() should return false with unsupported mime type', () {
      expect(false, document4.mediaType.isAndroidSupportedPreview());
    });

    test('isIOSSupportedPreview() should return true with supported mime type', () {
      expect(true, document1.mediaType.isIOSSupportedPreview());
    });

    test('isIOSSupportedPreview() should return false with unsupported mime type', () {
      expect(false, document4.mediaType.isIOSSupportedPreview());
    });

    test('isImageFile() should return true with valid mime type', () {
      expect(true, document1.mediaType.isImageFile());
    });

    test('isImageFile() should return false with invalid mime type', () {
      expect(false, document4.mediaType.isImageFile());
    });

    group('document_extension_tests', () {
      test('getDocumentUti() should return uti with supported mime type', () {
        final validUti = DocumentUti('public.png');
        expect(validUti, document1.mediaType.getDocumentUti());
      });

      test('getDocumentUti() should return null with unsupported mime type', () {
        expect(DocumentUti(null), document4.mediaType.getDocumentUti());
      });
    });
  });
}
