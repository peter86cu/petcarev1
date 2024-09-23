import 'package:intl/intl.dart';

import 'Mascota.dart';

class PesoMascota {
  final String pesoid;
  final Mascota? mascota;
  final DateTime fecha;
  final double peso;
  final String um;



  PesoMascota({
    required this.pesoid,
     this.mascota,
    required this.fecha,
    required this.peso,
    required this.um,

  });

  factory PesoMascota.fromJson(Map<String, dynamic> json) {
    return PesoMascota(
      pesoid: json['pesoid'] ?? '', // Proporciona un valor predeterminado si el valor es nulo
      //mascota: json['mascota'] ?? '',
      fecha: json['fecha'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['fecha'])
          : DateTime.now(),
      peso: json['peso'] ?? 0.0,
      um: json['um'] ?? '',


    );
  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return {
      'pesoid': pesoid,
      'mascota': mascota,
      'fecha': dateFormat.format(fecha), // Convertir DateTime a cadena
      'peso': peso,
      'um': um,
    };
  }
}