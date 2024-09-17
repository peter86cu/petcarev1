
import 'package:PetCare/class/Event.dart';
import 'package:intl/intl.dart';

import 'Mascota.dart';
import 'UserRoles.dart';

class User {
  final String userid;
  final String? password;
  final String name;
  final String? phone;
  final String plataforma;
  final List<UserRoles> roles;
  final int state;
  late final String photo;
  final String username;
  final DateTime createdate;
  final DateTime? deletedate; // Puede ser nullable si es opcional
  final List<Mascota>? mascotas;
  final String? documento;

  User({
    required this.userid,
     this.password,
    required this.name,
    this.phone,
    required this.plataforma,
    required this.roles,
    required this.state,
    required this.username,
    required this.createdate,
    this.deletedate,
    required this.photo,
    required this.mascotas,
    this.documento,

  });

  factory User.fromJson(Map<String, dynamic> json) {

    return User(
      userid: json['userid'] ?? '',
      password: json['password'] ?? '',
      name: json['name'] ?? '',
      documento: json['documento'] ?? '',
      phone: json['phone'] ?? '',
      plataforma: json['plataforma'] ?? '',
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((i) => UserRoles.fromJson(i as Map<String, dynamic>))
          .toList(),
      state: json['state'] ?? 0,
      username: json['username'] ?? '',
      createdate: json['createdate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdate'])
          : DateTime.now(),     photo: json['photo'] ?? '',
     //deletedate: DateTime.parse(json['deletedate'] ),
      mascotas: (json['mascotas'] as List<dynamic>? ?? [])
          .map((i) => Mascota.fromJson(i as Map<String, dynamic>))
          .toList(),
    );

  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return {
      'userid': userid,
      'password': password,
      'name': name,
      'phone':phone,
      'plataforma': plataforma,
      'roles': roles,
      'state': state,
      'photo': photo,
      'username': username,
      'createdate': dateFormat.format(createdate) ,
      //'deletedate': deletedate != null ? dateFormat.format(deletedate!) : 'Fecha no disponible',
      'mascotas': mascotas,
    };
  }

  // Método para convertir cadena a DateTime con manejo de errores
  static DateTime _parseDate(int dateString) {
    if (dateString == null ) {
      // Manejo de null o cadena vacía
      print('Date string is null or empty');
      return DateTime.now(); // Valor predeterminado
    }
    try {
      // Convertir milisegundos a DateTime
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dateString);
      // Formatear la fecha en un formato legible
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
      return dateTime; // Usa DateTime.parse directamente si esperas el formato ISO
    } catch (e) {
      // Si falla, devuelve una fecha predeterminada o maneja el error como consideres adecuado
      print('Error parsing date: $e');
      return DateTime.now(); // O alguna otra fecha predeterminada
    }
  }
}
