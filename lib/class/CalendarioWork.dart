import 'package:intl/intl.dart';

import 'User.dart';

class Calendariowork {
  final String id;
  final User? user;
  final String startTime;
  final String endTime;



  Calendariowork({
    required this.id,
    required this.user,
    required this.startTime,
    required this.endTime,

  });

  factory Calendariowork.fromJson(Map<String, dynamic> json) {
    return Calendariowork(
      id: json['id'] ?? '', // Proporciona un valor predeterminado si el valor es nulo
      user: User.fromJson(json['user'] ??{}),
      startTime: json['starttime'] ?? '',
      endTime: json['endtime'] ?? '',


    );
  }

  Map<String, dynamic> toJson() {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return {
      'id': id,
      'user': user,
      'starttime': startTime,
      'endtime': endTime,
    };
  }
}