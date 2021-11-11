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

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:linshare_flutter_app/presentation/model/advance_search_date_state.dart';
import 'package:linshare_flutter_app/presentation/model/advance_search_kind_state.dart';
import 'package:linshare_flutter_app/presentation/redux/states/ui_state.dart';

class AdvanceSearchSetting extends Equatable {

  final List<AdvancedSearchKindState>? listKindState;
  final List<AdvancedSearchDateState>? listModificationDate;

  AdvanceSearchSetting({this.listKindState, this.listModificationDate});

  AdvanceSearchSetting copyWith({List<AdvancedSearchKindState>? newListKindState, List<AdvancedSearchDateState>? newListModificationDate}) {
    return AdvanceSearchSetting(
      listKindState: newListKindState ?? listKindState,
      listModificationDate: newListModificationDate ?? listModificationDate
    );
  }

  static AdvanceSearchSetting fromSearchDestination(SearchDestination searchDestination) {
    switch(searchDestination) {
      case SearchDestination.sharedSpace:
      case SearchDestination.insideDrive:
      case SearchDestination.allSharedSpaces:
      case SearchDestination.mySpace:
      case SearchDestination.receivedShares:
      case SearchDestination.uploadRequestGroups:
      case SearchDestination.uploadRequestInside:
        return AdvanceSearchSetting(
            listKindState: [
              AdvancedSearchKindState(AdvancedSearchRequestKind.DOCUMENT, false),
              AdvancedSearchKindState(AdvancedSearchRequestKind.PDF, false),
              AdvancedSearchKindState(AdvancedSearchRequestKind.SPREADSHEET, false),
              AdvancedSearchKindState(AdvancedSearchRequestKind.IMAGE, false),
              AdvancedSearchKindState(AdvancedSearchRequestKind.AUDIO, false),
              AdvancedSearchKindState(AdvancedSearchRequestKind.ARCHIVE, false),
              AdvancedSearchKindState(AdvancedSearchRequestKind.OTHER, false),
            ], 
            listModificationDate: [
              AdvancedSearchDateState(AdvancedSearchRequestDate.ANY_TIME, true),
              AdvancedSearchDateState(AdvancedSearchRequestDate.PAST_DAY, false),
              AdvancedSearchDateState(AdvancedSearchRequestDate.PAST_WEEK, false),
              AdvancedSearchDateState(AdvancedSearchRequestDate.PAST_MONTH, false),
              AdvancedSearchDateState(AdvancedSearchRequestDate.PAST_YEAR, false),
            ]
        );
    }
  }

  @override
  List<Object?> get props => [listKindState, listModificationDate];
}

