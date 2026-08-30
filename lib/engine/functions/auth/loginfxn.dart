import '../../network/auth/login.dart';

final _signInService = SignInService();

Future<SignInResponse> login({
  required String phoneNumber,
  required String password,
}) async {
  return _signInService.signIn(
    mainServerId: 'server_1',
    phoneNumber: phoneNumber,
    password: password,
  );
}