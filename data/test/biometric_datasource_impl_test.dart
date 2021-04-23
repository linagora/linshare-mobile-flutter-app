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

import 'package:data/src/datasource_impl/biometric_datasource_impl.dart';
import 'package:data/src/util/constant.dart';
import 'package:domain/domain.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:data/src/extensions/biometric_type_extension.dart';

import 'fixture/mock/mock_fixtures.dart';

void main() {
  isAvailable();
  getAvailableBiometric();
  getBiometricSetting();
  saveBiometricSetting();
  authenticate();
}

void isAvailable() {
  group('biometric_data_source_impl isAvailable test', () {
    BiometricDataSourceImpl _biometricDataSourceImpl;
    MockLocalBiometricService _localBiometricService;
    MockBiometricExceptionThrower _biometricExceptionThrower;
    SharedPreferences _sharedPreferences;

    Future _initDataSource() async {
      SharedPreferences.setMockInitialValues({});

      _sharedPreferences = await SharedPreferences.getInstance();
      _localBiometricService = MockLocalBiometricService();
      _biometricExceptionThrower = MockBiometricExceptionThrower();
      _biometricDataSourceImpl = BiometricDataSourceImpl(_localBiometricService, _biometricExceptionThrower, _sharedPreferences);
    }

    test('isAvailable should return success with valid data', () async {
      await _initDataSource();

      when(_localBiometricService.isAvailable()).thenAnswer((_) async => true);

      final isAvailable = await _biometricDataSourceImpl.isAvailable();

      expect(isAvailable, true);
    });

    test('isAvailable should throw PlatformException when _localBiometricService response error', () async {
      await _initDataSource();

      final error = PlatformException(
          code: 'NotAvailable',
          message: 'NotAvailable'
      );

      when(_localBiometricService.isAvailable()).thenThrow(error);

      await _biometricDataSourceImpl.isAvailable()
          .catchError((error) => expect(error, isA<BiometricNotAvailable>()));
    });
  });
}

void getAvailableBiometric() {
  group('biometric_data_source_impl getAvailableBiometrics test', () {
    BiometricDataSourceImpl _biometricDataSourceImpl;
    MockLocalBiometricService _localBiometricService;
    MockBiometricExceptionThrower _biometricExceptionThrower;
    SharedPreferences _sharedPreferences;

    Future _initDataSource() async {
      SharedPreferences.setMockInitialValues({});

      _sharedPreferences = await SharedPreferences.getInstance();
      _localBiometricService = MockLocalBiometricService();
      _biometricExceptionThrower = MockBiometricExceptionThrower();
      _biometricDataSourceImpl = BiometricDataSourceImpl(_localBiometricService, _biometricExceptionThrower, _sharedPreferences);
    }

    test('getAvailableBiometrics should return success with valid data', () async {
      await _initDataSource();

      when(_localBiometricService.getAvailableBiometrics()).thenAnswer((_) async => [BiometricKind.faceId, BiometricKind.fingerprint]);

      final biometricKinds = await _biometricDataSourceImpl.getAvailableBiometrics();

      expect(biometricKinds, [BiometricKind.faceId, BiometricKind.fingerprint]);
    });

    test('getAvailableBiometrics should throw PlatformException when _localBiometricService response error', () async {
      await _initDataSource();

      final error = PlatformException(
          code: 'NotEnrolled',
          message: 'NotEnrolled'
      );

      when(_localBiometricService.getAvailableBiometrics()).thenThrow(error);

      await _biometricDataSourceImpl.getAvailableBiometrics()
          .catchError((error) => expect(error, isA<BiometricNotEnrolled>()));
    });
  });
}

void getBiometricSetting() {
  group('biometric_data_source_impl getBiometricSetting test', () {
    BiometricDataSourceImpl _biometricDataSourceImpl;
    MockLocalBiometricService _localBiometricService;
    MockBiometricExceptionThrower _biometricExceptionThrower;
    SharedPreferences _sharedPreferences;

    Future _initDataSource() async {
      SharedPreferences.setMockInitialValues({
        Constant.biometricSettingState: BiometricState.enabled.value
      });

      _sharedPreferences = await SharedPreferences.getInstance();
      _localBiometricService = MockLocalBiometricService();
      _biometricExceptionThrower = MockBiometricExceptionThrower();
      _biometricDataSourceImpl = BiometricDataSourceImpl(_localBiometricService, _biometricExceptionThrower, _sharedPreferences);
    }

    test('getBiometricSetting return success with BiometricState is saved', () async {
      await _initDataSource();

      final biometricState = await _biometricDataSourceImpl.getBiometricSetting();

      expect(biometricState.value, _sharedPreferences.getString(Constant.biometricSettingState));
    });
  });
}

void saveBiometricSetting() {
  group('biometric_data_source_impl saveBiometricSetting test', () {
    BiometricDataSourceImpl _biometricDataSourceImpl;
    MockLocalBiometricService _localBiometricService;
    MockBiometricExceptionThrower _biometricExceptionThrower;
    SharedPreferences _sharedPreferences;

    Future _initDataSource() async {
      SharedPreferences.setMockInitialValues({});

      _sharedPreferences = await SharedPreferences.getInstance();
      _localBiometricService = MockLocalBiometricService();
      _biometricExceptionThrower = MockBiometricExceptionThrower();
      _biometricDataSourceImpl = BiometricDataSourceImpl(_localBiometricService, _biometricExceptionThrower, _sharedPreferences);
    }

    test('saveBiometricSetting return success with BiometricState is saved', () async {
      await _initDataSource();

      await _sharedPreferences.setString(Constant.biometricSettingState, BiometricState.enabled.value);
      
      await _biometricDataSourceImpl.saveBiometricSetting(BiometricState.enabled);

      expect(BiometricState.enabled.value, _sharedPreferences.getString(Constant.biometricSettingState));
    });
  });
}

void authenticate() {
  group('biometric_data_source_impl authenticate test', () {
    BiometricDataSourceImpl _biometricDataSourceImpl;
    MockLocalBiometricService _localBiometricService;
    MockBiometricExceptionThrower _biometricExceptionThrower;
    SharedPreferences _sharedPreferences;

    Future _initDataSource() async {
      SharedPreferences.setMockInitialValues({});

      _sharedPreferences = await SharedPreferences.getInstance();
      _localBiometricService = MockLocalBiometricService();
      _biometricExceptionThrower = MockBiometricExceptionThrower();
      _biometricDataSourceImpl = BiometricDataSourceImpl(_localBiometricService, _biometricExceptionThrower, _sharedPreferences);
    }

    test('authenticate should return success with valid data', () async {
      await _initDataSource();

      when(_localBiometricService.authenticate('Please authenticate to open app')).thenAnswer((_) async => true);

      final isAvailable = await _biometricDataSourceImpl.authenticate('Please authenticate to open app');

      expect(isAvailable, true);
    });

    test('authenticate should throw PlatformException when _localBiometricService response error', () async {
      await _initDataSource();

      final error = PlatformException(
          code: 'NotEnrolled',
          message: 'NotEnrolled'
      );

      when(_localBiometricService.authenticate('Please authenticate to open app')).thenThrow(error);

      await _biometricDataSourceImpl.authenticate('Please authenticate to open app')
          .catchError((error) => expect(error, isA<BiometricNotEnrolled>()));
    });
  });
}