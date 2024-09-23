

import 'dart:convert';
import 'dart:typed_data';

import 'package:PetCare/class/Mascota.dart';
import 'package:intl/intl.dart';

class Album {
  final String id;
  final String name;
  final Mascota pet; // ID de la mascota asociada
  final List<Photo> photos;
  final DateTime fechaCreado;
  bool isSelected; // Nuevo campo para manejar la selección
  int  likeCount;
  bool isLiked;
  bool isShared;

  Album({
    required this.id,
    required this.name,
    required this.pet,
    required this.photos,
    required this.fechaCreado,
    this.isSelected = false,
    this.isLiked=false,
    this.isShared=false,
    required this.likeCount,

  });

  // Método para convertir de JSON a objeto Album
  factory Album.fromJson(Map<String, dynamic> json) {
    /*List<Photo> photos = (json['photos'] as List)
        .map((photoJson) => Photo.fromJson(photoJson))
        .toList();*/

    return Album(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      pet: Mascota.fromJson(json['mascota'] ??{}) ,
      photos: json['photos'] != null
          ? (json['photos'] as List).map((i) => Photo.fromJson(i)).toList()
          : [],
      fechaCreado: json['fechaCreado'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['fechaCreado'])
          : DateTime.now(),
      isSelected: false, // Siempre false al crear un álbum desde JSON
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['liked'] ?? false,
      isShared: json['selected'] ?? false,
    );
  }

  // Método para convertir un objeto Album a JSON
  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return {
      'id': id,
      'name': name,
      'mascota': pet.toJson(),
      'photos': photos.map((photo) => photo.toJson()).toList(),
      'fechaCreado': dateFormat.format(fechaCreado),
      'likeCount': likeCount,
      'liked': isLiked,
    };
  }
}


// Clase Photo para representar una foto individual
class Photo {
  final String photoId; // ID de la foto en la base de datos
  final Album album; // ID del álbum al que pertenece la foto
  final Uint8List data; // Contenido de la foto en BLOB
  final DateTime fechaCreado;
  final String mediaType;

  Photo({
    required this.photoId,
    required this.album,
    required this.data,
    required this.fechaCreado,
    required this.mediaType,
  });

  // Método para convertir de JSON a objeto Photo
  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      photoId: json['photoid'] as String,
      album: Album.fromJson(json['album'] ??{}),
      data: base64Decode(json['photo'] as String), // Decodificar la foto en BLOB
      fechaCreado: json['fechaCreado'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['fechaCreado'])
          : DateTime.now(),
      mediaType: json['mediaType'] as String
    );
  }

  // Método para convertir un objeto Photo a JSON
  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return {
      'photoid': photoId,
      'album': album.toJson(),
      'photo': base64Encode(data), // Codificar la foto en Base64 para enviarla como JSON
      'fechaCreado': dateFormat.format(fechaCreado),
      'mediaType': mediaType
    };
  }
}