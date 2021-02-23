/*
 * LinShare is an open source filesharing software, part of the LinPKI software
 * suite, developed by Linagora.
 *
 * Copyright (C) 2021 LINAGORA
 *
 * This program is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Affero General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version,
 * provided you comply with the Additional Terms applicable for LinShare software by
 * Linagora pursuant to Section 7 of the GNU Affero General Public License,
 * subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
 * display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
 * the words “You are using the Free and Open Source version of LinShare™, powered by
 * Linagora © 2009–2021. Contribute to Linshare R&D by subscribing to an Enterprise
 * offer!”. You must also retain the latter notice in all asynchronous messages such as
 * e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
 * http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
 * infringing Linagora intellectual property rights over its trademarks and commercial
 * brands. Other Additional Terms apply, see
 * <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
 * for more details.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
 * more details.
 * You should have received a copy of the GNU Affero General Public License and its
 * applicable Additional Terms for LinShare along with this program. If not, see
 * <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
 *  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
 *  the Additional Terms applicable to LinShare software.
 */

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';
import 'package:http_parser/http_parser.dart';

final RECIPIENT_1 = GenericUser(
    'user3@linshare.org',
    lastName: optionOf('John'),
    firstName: optionOf('Doe')
);

final RECIPIENT_2 = GenericUser(
    'user4@linshare.org',
    lastName: optionOf('Foo'),
    firstName: optionOf('Bar')
);

final receivedShare1 = ReceivedShare(
    ShareId('6c0e1f35-89e5-432e-a8d4-17c8d2c3b5fa'),
    'document.txt',
    DateTime.fromMillisecondsSinceEpoch(1604482138181),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604482928398),
    '',
    RECIPIENT_1,
    MediaType.parse('image/png'),
    GenericUser('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane')),
    3,
    29832983
);

final receivedShare2 = ReceivedShare(
    ShareId('6c0e1f35-89e5-6bc3-a8d4-156ec8074beb'),
    'document.txt',
    DateTime.fromMillisecondsSinceEpoch(1604482138181),
    DateTime.fromMillisecondsSinceEpoch(1604482138188),
    DateTime.fromMillisecondsSinceEpoch(1604418921982),
    '',
    RECIPIENT_2,
    MediaType.parse('image/png'),
    GenericUser('user1@linshare.org', lastName: optionOf('Smith'), firstName: optionOf('Jane')),
    5,
    289323
);
