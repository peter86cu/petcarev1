import 'ActividadNegocio.dart';
import 'User.dart';

class Business {
  final String id;
  final String name;
  final String? rut;
  final String phone;
  final String longitud;
  final String latitud;
  final DateTime createdAt;
  final String address;
  final String logoUrl;
  final double rating;
  final User? user;
  final List<ActivityBussines> services;
  final int reviewCount; // Agrega esta propiedad para la cantidad de comentarios

  Business({
    required this.id,
    required this.name,
    required this.phone,
    this.rut,
    required this.createdAt,
    required this.longitud,
    required this.latitud,
    required this.address,
    required this.logoUrl,
    required this.rating,
     this.user,
    required this.services,
    required this.reviewCount,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      rut: json['rut'] ?? '',
      phone: json['phone'] ?? '',
      longitud: json['longitud'] ?? '',
      latitud: json['latitud'] ?? '',
      address: json['address'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      rating: json['averageRating'].toDouble() ?? '',
      user: User.fromJson(json['usuario'] ??{}),
      services: (json['activity'] as List).map((serviceJson) => ActivityBussines.fromJson(serviceJson)).toList(),
      reviewCount: json['reviewCount'] ?? 0,
    );
  }

  // Método para convertir una instancia de Business a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rut': rut,
      'phone': phone,
      'address': address,
      'logoUrl': logoUrl,
      'rating': rating,
      'user': user,
    };
  }

  ActivityBussines? firstWhere(bool Function(dynamic service) param0, {required Null Function() orElse}) {}


}