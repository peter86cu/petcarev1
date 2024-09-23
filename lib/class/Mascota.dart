

import 'package:PetCare/class/MascotaAddress.dart';

import 'Event.dart';
import 'PesoMascota.dart';
import 'User.dart';
import 'Vacunas.dart';
import 'desparasitaciones.dart';

class Mascota {
  String mascotaid;
  String nombre;
  String especie;
  String raza;
  int? edad;
  String? genero;
  String? color;
  String? tamano;
  String? personalidad;
  String? historialMedico;
  String? necesidadesEspeciales;
  String? comportamiento;
  String fotos;
  String? fechaNacimiento;
  User usuario;
  List<Vacunas>? vacunas;
  List<Desparasitaciones>? desparasitaciones;
  List<PesoMascota>? peso;
  bool isSelected;
  bool reservedTime;
  double? servicePrice;
  String? actividadId;
  late final List<Event>? eventos;
  String? microchip;
  DateTime? fechaRegistroChip;
  MascotaAddress? direccion;
  String? castrado;

  Mascota({
    required this.mascotaid,
    required this.nombre,
    required this.especie,
    required this.raza,
    this.edad,
     this.genero,
     this.color,
     this.tamano,
     this.personalidad,
     this.historialMedico,
     this.necesidadesEspeciales,
     this.comportamiento,
    required this.fotos,
     required this.usuario,
     this.vacunas,
     this.desparasitaciones,
     this.peso,
    this.fechaNacimiento,
     required this.isSelected,
     required this.reservedTime,
    this.servicePrice,
    this.actividadId,
    this.eventos,
    this.microchip,
    this.fechaRegistroChip,
    this.direccion,
    this.castrado
  });



  factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      mascotaid: json['mascotaid'] ?? '', // Proporciona un valor predeterminado si el valor es nulo
      nombre: json['nombre'] ?? '',
      especie: json['especie'] ?? '',
      raza: json['raza'] ?? '',
      castrado: json['castrado'] ?? '',
      edad: json['edad'] ?? 0,
      genero: json['genero'] ?? '',
      color: json['color'] ?? '',
      tamano: json['tamano'] ?? '',
      personalidad: json['personalidad'] ?? '',
      historialMedico: json['historial_medico'] ?? '',
      necesidadesEspeciales: json['necesidades_especiales'] ?? '',
      comportamiento: json['comportamiento'] ?? '',
      fotos: json['fotos'] ?? '',
      fechaNacimiento: json['fechanacimiento'] ?? '',
      usuario: User.fromJson(json['usuario'] ??{}) ,
      // Manejo de las listas que pueden ser nulas
      vacunas: json['vacunas'] != null
          ? (json['vacunas'] as List).map((i) => Vacunas.fromJson(i)).toList()
          : [],

      desparasitaciones: json['desparasitaciones'] != null
          ? (json['desparasitaciones'] as List).map((i) => Desparasitaciones.fromJson(i)).toList()
          : [],

      eventos: json['eventos'] != null
          ? (json['eventos'] as List).map((i) => Event.fromJson(i)).toList()
          : [],

      peso: json['pesoMascota'] != null
          ? (json['pesoMascota'] as List).map((i) => PesoMascota.fromJson(i)).toList()
          : [],
      isSelected:false,
      reservedTime: false,
      microchip: json['microchip'] ?? '',
      fechaRegistroChip: json['fechaRegistroChip'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['fechaRegistroChip'])
          : DateTime.now(),
      direccion: MascotaAddress.fromJson(json['direccion'] ??{}) ,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mascotaid': mascotaid,
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'edad': edad,
      'genero': genero,
      'color': color,
      'tamano': tamano,
      'personalidad': personalidad,
      'historial_medico': historialMedico,
      'necesidades_especiales': necesidadesEspeciales,
      'comportamiento': comportamiento,
      'pesoMascota': peso?.map((p) => p.toJson()).toList(),
      'fotos': fotos,
      'fechanacimiento':fechaNacimiento,
      'usuario': usuario,
      'vacunas': vacunas?.map((v) => v.toJson()).toList(),
      'desparasitaciones': desparasitaciones?.map((d) => d.toJson()).toList(),

    };
  }
}