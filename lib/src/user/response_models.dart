import 'package:meta/meta.dart';

/// Data associated with a successful login.
@immutable
class LoginSuccessResponse {
  final String idToken;
  final String accessToken;

  /// Token used to extend a user session.
  final String refreshToken;

  const LoginSuccessResponse(
      {required this.idToken,
      required this.accessToken,
      required this.refreshToken});

  factory LoginSuccessResponse.fromJson(Map<String, dynamic> json) {
    return LoginSuccessResponse(
      idToken: json['idtoken'],
      accessToken: json['accesstoken'],
      refreshToken: json['refreshtoken'],
    );
  }
}

/// Data associated with a successful login without a password.
@immutable
class LoginWithoutPassword {
  final String status;
  final String description;
  final String session;

  const LoginWithoutPassword(
      {required this.status,
        required this.description,
        required this.session});

  factory LoginWithoutPassword.fromJson(Map<String, dynamic> json) {
    return LoginWithoutPassword(
      status: json['status'],
      description: json['description'],
      session: json['session'],
    );
  }
}

/// Data associated with a successful session extension.
@immutable
class ExtendSuccessResponse {
  final String idToken;

  /// The token necessary for the authenticated API calls.
  ///
  /// Store this token for later use.
  final String accessToken;

  const ExtendSuccessResponse(
      {required this.idToken, required this.accessToken});

  factory ExtendSuccessResponse.fromJson(Map<String, dynamic> json) {
    return ExtendSuccessResponse(
      idToken: json['idtoken'],
      accessToken: json['accesstoken'],
    );
  }
}

/// Data associated with a user in the Rainmaker server.
@immutable
class UserData {
  final String id;
  final String userName;
  final String? name;
  final bool isSuperAdmin;
  final String? pictureUrl;
  final String? phoneNumber;
  final bool mfa;

  const UserData({
    required this.id,
    required this.userName,
    required this.mfa,
    this.isSuperAdmin = false,
    this.name,
    this.pictureUrl,
    this.phoneNumber,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['user_id'],
      isSuperAdmin: json['super_admin'] ?? false,
      name: json['name'],
      pictureUrl: json['picture_url'],
      userName: json['user_name'],
      mfa: json['mfa'],
      phoneNumber: json['phone_number'],
    );
  }

  @override
  String toString() {
    return 'UserData(Id: $id, '
        'UserName: $userName, '
        'IsSuperAdmin: $isSuperAdmin, '
        'Name: $name, '
        'Pic URL: $pictureUrl, '
        'MFA: $mfa, PhoneNumber: $phoneNumber)';
  }
}
