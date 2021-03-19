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
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SorterDataSourceImpl implements SorterDataSource {
  final SharedPreferences _sharedPreferences;

  SorterDataSourceImpl(this._sharedPreferences);

  @override
  Future<List<Sorter>> generateSorterList(OrderScreen orderScreen) {
    var sorterList = <Sorter>[];

    switch (orderScreen) {
      case OrderScreen.mySpace:
        sorterList = <Sorter>[
          Sorter(orderScreen, OrderBy.modificationDate, OrderType.descending),
          Sorter(orderScreen, OrderBy.creationDate, OrderType.descending),
          Sorter(orderScreen, OrderBy.fileSize, OrderType.descending),
          Sorter(orderScreen, OrderBy.name, OrderType.descending),
          Sorter(orderScreen, OrderBy.shared, OrderType.descending)
        ];
        break;
      case OrderScreen.sharedSpace:
        break;
      case OrderScreen.sharedSpaceDocument:
        break;
      case OrderScreen.receivedShare:
        break;
    }

    return Future.sync(() async {
      return sorterList;
    }).catchError((error) {
      throw UnknownError(error.response.statusMessage);
    });
  }

  @override
  Future<Sorter> getSorter(OrderScreen orderScreen) {
    final orderByStore = _sharedPreferences
        .getString('sort_file_order_by_${orderScreen.toString()}');
    final orderTypeStore = _sharedPreferences
        .getString('sort_file_order_type_${orderScreen.toString()}');

    var orderBy = OrderBy.modificationDate;
    if (orderByStore == OrderBy.creationDate.toString()) {
      orderBy = OrderBy.creationDate;
    } else if (orderByStore == OrderBy.fileSize.toString()) {
      orderBy = OrderBy.fileSize;
    } else if (orderByStore == OrderBy.name.toString()) {
      orderBy = OrderBy.name;
    } else if (orderByStore == OrderBy.shared.toString()) {
      orderBy = OrderBy.shared;
    }
    final orderType = orderTypeStore == OrderType.ascending.toString()
        ? OrderType.ascending
        : OrderType.descending;

    return Future.sync(() async {
      return Sorter(orderScreen, orderBy, orderType);
    }).catchError((error) {
      throw UnknownError(error.response.statusMessage);
    });
  }
}
