import 'package:PetCare/class/Mascota.dart';
import 'package:intl/intl.dart';

class Vacunas {
  final int vacunaid;
  final Mascota? mascota;
  final String nombreVacuna;
  final DateTime fechaAdministracion;
  final DateTime proximaFechaVacunacion;
  final String? veterinarioResponsable;
  final String? clinicaVeterinaria;
  final String loteVacuna;
  final String? observaciones;


  Vacunas({
    required this.vacunaid,
     this.mascota,
    required this.nombreVacuna,
    required this.fechaAdministracion,
    required this.proximaFechaVacunacion,
    this.veterinarioResponsable,
    this.clinicaVeterinaria,
    required this.loteVacuna,
    this.observaciones,

  });

  factory Vacunas.fromJson(Map<String, dynamic> json) {
    return Vacunas(
      vacunaid: json['vacunaid'] ?? 0, // Proporciona un valor predeterminado si el valor es nulo

      nombreVacuna: json['nombreVacuna'] ?? '',
      fechaAdministracion: json['fechaAdministracion'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['fechaAdministracion'])
          : DateTime.now(),
      proximaFechaVacunacion: json['proximaFechaVacunacion'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['proximaFechaVacunacion'])
          : DateTime.now(),
      veterinarioResponsable: json['veterinarioResponsable'] ?? '',
      clinicaVeterinaria: json['clinicaVeterinaria'] ?? '',
      loteVacuna: json['loteVacuna'] ?? '',
      observaciones: json['observaciones'] ?? '',

    );
  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return {
      'vacunaid': vacunaid,
      'mascota': mascota,
      'nombreVacuna': nombreVacuna,
      'fechaAdministracion': dateFormat.format(fechaAdministracion) ,
      'proximaFechaVacunacion': dateFormat.format(proximaFechaVacunacion) ,
      'veterinarioResponsable': veterinarioResponsable,
      'clinicaVeterinaria': clinicaVeterinaria,
      'loteVacuna': loteVacuna,
      'observaciones': observaciones,
    };
  }
}