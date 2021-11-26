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
// <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf
//
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses
// for the GNU Affero General Public License version
//
// 3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf
// for
//
// the Additional Terms applicable to LinShare software.

import 'package:flutter/material.dart';

class RichTextBuilder {

  final String _textOrigin;
  final String _wordToStyle;
  final TextStyle _styleOrigin;
  final TextStyle _styleWord;

  Key? _key;
  int? _maxLines;
  TextOverflow? _overflow;

  RichTextBuilder(
    this._textOrigin,
    this._wordToStyle,
    this._styleOrigin,
    this._styleWord,
  );

  void key(Key key) {
    _key = key;
  }

  void maxLines(int? maxLines) {
    _maxLines = maxLines;
  }

  void setOverflow(TextOverflow? textOverflow) {
    _overflow = textOverflow;
  }

  RichText build() {
    return RichText(
      key: _key,
      textAlign: TextAlign.center,
      maxLines: _maxLines ?? 1,
      overflow: _overflow ?? TextOverflow.ellipsis,
      text: TextSpan(
        style: _styleOrigin,
        children: _getSpans(_textOrigin, _wordToStyle, _styleWord)));
  }

  List<TextSpan> _getSpans(String text, String matchWord, TextStyle style) {
    var spans = <TextSpan>[];
    var spanBoundary = 0;
    do {
      // look for the next match
      final startIndex = text.toLowerCase().indexOf(matchWord.toLowerCase(), spanBoundary);
      // if no more matches then add the rest of the string without style
      if (startIndex == -1) {
        spans.add(TextSpan(text: text.substring(spanBoundary)));
        return spans;
      }
      // add any unStyled text before the next match
      if (startIndex > spanBoundary) {
        spans.add(TextSpan(text: text.substring(spanBoundary, startIndex)));
      }
      // style the matched text
      final endIndex = startIndex + matchWord.length;
      final spanText = text.substring(startIndex, endIndex);
      spans.add(TextSpan(text: spanText, style: style));
      // mark the boundary to start the next search from
      spanBoundary = endIndex;
      // continue until there are no more matches
    } while (spanBoundary < text.length);

    return spans;
  }
}