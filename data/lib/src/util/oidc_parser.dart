
import 'package:domain/domain.dart';

class OIDCParser {

  OIDCConfiguration? parseOIDCConfiguration(String oidcString) {
    final regExp = RegExp('mobileOidcSetting:.*.\n.*\n.*\n.*\n.*\n.*\n.*\n.*');

    final matchString = regExp.stringMatch(oidcString) ?? '';
    if (matchString.isNotEmpty) {
      final regexOidcType = RegExp('(oidcToken:)(.\')(.\*)(\')');
      final regExpAuthority = RegExp('(authority:)(.\')(.\*)(\')');
      final regExpClientId = RegExp('(client_id:)(.\')(.\*)(\')');
      final regExpRedirectUrl = RegExp('(redirect_url:)(.\')(.\*)(\')');
      final regExpPostLogoutRedirectUri = RegExp('(post_logout_redirect_uri:)(.\')(.\*)(\')');
      final regExpResponseType = RegExp('(response_type:)(.\')(.\*)(\')');
      final regExpScope = RegExp('(scope:)(.\')(.\*)(\')');

      final oidcTypeMatch = regexOidcType.allMatches(matchString).first.group(3) ?? '';
      final authorityMatch = regExpAuthority.allMatches(matchString).first.group(3) ?? '';
      final clientIdMatch = regExpClientId.allMatches(matchString).first.group(3) ?? '';
      final _ = regExpRedirectUrl.allMatches(matchString).first.group(3) ?? '';
      final logoutUrlMatch = regExpPostLogoutRedirectUri.allMatches(matchString).first.group(3) ?? '';
      final scopeMatch = regExpScope.allMatches(matchString).first.group(3) ?? '';
      final responseTypeMatch = regExpResponseType.allMatches(matchString).first.group(3) ?? '';

      String oidcTokenType = DomainConstant.opaqueOidc;
      if (oidcTypeMatch == 'Oidc-Jwt') {
        oidcTokenType = DomainConstant.jwtOidc;
      }

      return OIDCConfiguration(
        authority: authorityMatch,
        clientId: clientIdMatch,
        logoutRedirectUri: logoutUrlMatch,
        responseType: responseTypeMatch,
        oidcTokenType: oidcTokenType,
        scopes: scopeMatch.split(' '),
      );
    }

    return null;
  }
}