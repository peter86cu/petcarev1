import 'User.dart';

class ResponseLogin {
  String token;
  User user;

  ResponseLogin({
    required this.token,
    required this.user,
  });

  // Método para convertir un mapa (JSON) en una instancia de UserData
  factory ResponseLogin.fromJson(Map<String, dynamic> json) {
    return ResponseLogin(
      token: json['token'],
      user: User.fromJson(json['user'] ??{}),
    );
  }

}