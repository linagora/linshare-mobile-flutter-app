import 'dart:core';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:domain/domain.dart';

class TokenOIDCInterator {
  final AuthenticationOIDCRepository authenticationOIDCRepository;
  final TokenRepository tokenRepository;
  final CredentialRepository credentialRepository;
  final APIRepository apiRepository;

  TokenOIDCInterator(this.authenticationOIDCRepository,
      this.tokenRepository,
      this.credentialRepository,
      this.apiRepository);

  Future<Either<Failure, Success>> execute(Uri baseUrl, TokenOIDC tokenOIDC) async {
    for (var i = 0; i <= APIVersionSupported.values.length; i++) {
      try {
        developer.log('execute(): $baseUrl in ${APIVersionSupported.values[i]}', name: 'CreateTokenOIDCInterator');
        await credentialRepository.saveBaseUrl(baseUrl);
        developer.log('execute(): detected version ${APIVersionSupported.values[i]}', name: 'CreateTokenOIDCInterator');
        await apiRepository.persistAPIVersionSupported(APIVersionSupported.values[i]);
        return Right(AuthenticationOIDCViewState(tokenOIDC, APIVersionSupported.values[i]));
      } catch (e) {
        if (e is UnsupportedAPIVersion) {
          developer.log('execute(): $e', name: 'CreateTokenOIDCInterator');
          continue;
        } else {
          developer.log('execute(): $e', name: 'CreateTokenOIDCInterator');
          return Left(AuthenticationFailure(e));
        }
      }
    }
    developer.log('API Not found!', name: 'CreateTokenOIDCInterator');
    return Left(AuthenticationFailure(ServerNotFound()));
  }
}