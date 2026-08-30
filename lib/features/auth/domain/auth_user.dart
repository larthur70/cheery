import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

@freezed
abstract class AuthUser with _$AuthUser {
  const AuthUser._();

  const factory AuthUser({
    required String id,
    required String email,
    @Default(<String>[]) List<String> identityProviders,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  /// Password signup identity (`email`). Google/Apple emails are owned by the IdP.
  bool get hasEmailIdentity => identityProviders.contains('email');

  bool get canChangeEmail => hasEmailIdentity;

  bool get canSetPassword => hasEmailIdentity;

  String? get linkedOAuthLabel {
    if (identityProviders.contains('google')) return 'Google';
    if (identityProviders.contains('apple')) return 'Apple';
    return null;
  }
}
