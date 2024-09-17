


import 'package:intl/intl.dart';

import 'Mascota.dart';
import 'User.dart';

class Activity {
  final String actividadid;
  final Mascota mascota;
  final String title;
  final String description;
  final String startime;
  final String endtime;
  final double precio;
  final String fecha;
  final String status;
  final String? note;
  final User? user;
  final int turnos;

  Activity({
    required this.actividadid,
    required this.mascota,
    required this.user,
    required this.title,
    required this.description,
    required this.startime,
    required this.endtime,
    required this.precio,
    required this.fecha,
    this.note,
    required this.status,
    required this.turnos,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    String fechaConvertida = json['fecha'] != null
        ? DateFormat('yyyy-MM-dd').format(
        DateTime.fromMillisecondsSinceEpoch(json['fecha']))
        : DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Activity(
      actividadid: json['actividadid'] ?? '',
      user: User.fromJson(json['usuario'] ?? {}),
      mascota: json['mascota'] != null
          ? Mascota.fromJson(json['mascota'])
          : Mascota(mascotaid: '',
          nombre: '',
          especie: '',
          raza: '',
          edad: 0,
          genero: '',
          color: '',
          tamano: '',
          personalidad: '',
          historialMedico: '',
          necesidadesEspeciales: '',
          comportamiento: '',
          fotos: '',
          usuario: User(userid: '',
              password: '',
              name: '',
              phone: '',
              photo: '',
              plataforma: '',
              roles: List.empty(),
              state: 0,
              username: '',
              createdate: DateTime.now(),
              mascotas: List.empty()),
          vacunas: List.empty(),
          desparasitaciones: List.empty(),
          peso: List.empty(),
          isSelected: false,
          reservedTime: false),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startime: json['startime'] ?? '',
      endtime: json['endtime'] ?? '',
      precio: json['precio'] ?? 0.0,
      fecha: fechaConvertida,
      /*fecha: json['fecha'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['fecha'])
          : DateTime.now(),*/
      status: json['status'] ?? '',
      note: json['note'] ?? '',
      turnos: json['turnos'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return {
      'actividadid': actividadid,
      'usuario': user,
      'mascota': mascota,
      'title': title,
      'description': description,
      'startime': startime,
      'endtime': endtime,
      'precio': precio,
      'fecha': fecha,
      'note': note,
      'status': status,
    };
  }

  Activity copyWith({
    String? actividadid,
    Mascota? mascota,
    String? title,
    String? description,
    String? startime,
    String? endtime,
    double? precio,
    String? fecha,
    String? status,
    String? note,
    User? user,
    int? turnos,
  }) {
    return Activity(
      actividadid: actividadid ?? this.actividadid,
      mascota: mascota ?? this.mascota,
      title: title ?? this.title,
      description: description ?? this.description,
      startime: startime ?? this.startime,
      endtime: endtime ?? this.endtime,
      precio: precio ?? this.precio,
      fecha: fecha ?? this.fecha,
      status: status ?? this.status,
      note: note ?? this.note,
      user: user ?? this.user,
      turnos: turnos ?? this.turnos,
    );
  }
}

