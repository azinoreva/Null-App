import '../../network/auth/login.dart';

final _signInService = SignInService();

Future<SignInResponse> login({
  required String phoneNumber,
  required String password,
}) async {
  return _signInService.signIn(
    phoneNumber: phoneNumber,
    password: password,
  );
}