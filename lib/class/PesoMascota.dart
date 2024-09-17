import 'package:intl/intl.dart';

class PesoMascota {
  final int pesoid;
  final String mascotaid;
  final DateTime fecha;
  final double peso;
  final String um;



  PesoMascota({
    required this.pesoid,
    required this.mascotaid,
    required this.fecha,
    required this.peso,
    required this.um,

  });

  factory PesoMascota.fromJson(Map<String, dynamic> json) {
    return PesoMascota(
      pesoid: json['pesoid'] ?? 0, // Proporciona un valor predeterminado si el valor es nulo
      mascotaid: json['mascotaid'] ?? '',
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
      'mascotaid': mascotaid,
      'fecha': dateFormat.format(fecha), // Convertir DateTime a cadena
      'peso': peso,
      'um': um,
    };
  }
}