import '../../network/auth/login.dart';

final _signInService = SignInService();

Future<SignInResponse> login({
  required String phoneNumber,
  required String password,
  String? userId,
  int? saltVersion,
  String? securityToken,
}) async {
  return _signInService.signIn(
    phoneNumber: phoneNumber,
    password: password,
    userId: userId,
    saltVersion: saltVersion,
    securityToken: securityToken,
  );
}