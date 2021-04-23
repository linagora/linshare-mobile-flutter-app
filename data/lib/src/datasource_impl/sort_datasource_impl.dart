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

class SortDataSourceImpl implements SortDataSource {
  final SharedPreferences _sharedPreferences;

  SortDataSourceImpl(this._sharedPreferences);

  @override
  Future<Sorter> getSorter(OrderScreen orderScreen) {
    return Future.sync(() async {
      final orderByStr = _sharedPreferences
          .getString('sort_file_order_by_${orderScreen.toString()}') ??
          OrderBy.modificationDate.toString();
      final orderTypeStr = _sharedPreferences
          .getString('sort_file_order_type_${orderScreen.toString()}') ??
          OrderType.descending.toString();
      final orderBy = OrderBy.modificationDate.getOrderBy(orderByStr);
      final orderType = orderTypeStr == OrderType.descending.toString()
          ? OrderType.descending
          : OrderType.ascending;

      return Sorter(orderScreen, orderBy, orderType);
    });
  }

  @override
  Future<List<T>> sortFiles<T>(List<T> listFiles, Sorter sorter) {
    return Future.sync(() async {
      if (listFiles is List<Document>) {
        listFiles.cast<Document>().sortFiles(sorter.orderBy, sorter.orderType);
      } else if (listFiles is List<WorkGroupNode>) {
        if (sorter.orderBy == OrderBy.fileSize) {
          final listWorkGroupFolder = listFiles.whereType<WorkGroupFolder>().toList();
          final listWorkGroupDocument = listFiles.whereType<WorkGroupDocument>().toList()
            ..sortFiles(sorter.orderBy, sorter.orderType);

          listFiles = (sorter.orderType == OrderType.descending
                  ? [listWorkGroupDocument, listWorkGroupFolder]
                  : [listWorkGroupFolder, listWorkGroupDocument])
              .expand((workGroupNode) => workGroupNode)
              .cast<T>()
              .toList();
        } else {
          listFiles.cast<WorkGroupNode>().sortFiles(sorter.orderBy, sorter.orderType);
        }
      } else if (listFiles is List<ReceivedShare>) {
        listFiles.cast<ReceivedShare>().sortFiles(sorter.orderBy, sorter.orderType);
      } else if (listFiles is List<SharedSpaceNodeNested>) {
        listFiles.cast<SharedSpaceNodeNested>().sortFiles(sorter.orderBy, sorter.orderType);
      }

      return listFiles;
    });
  }

  @override
  Future<Sorter> saveSorter(Sorter sorter) async {
    return Future.wait([
      _sharedPreferences.setString(
          'sort_file_order_by_${sorter.orderScreen.toString()}',
          sorter.orderBy.toString()),
      _sharedPreferences.setString(
          'sort_file_order_type_${sorter.orderScreen.toString()}',
          sorter.orderType.toString())
    ]).then((value) => sorter);
  }
}
