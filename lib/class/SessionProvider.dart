import 'dart:convert';

import 'package:PetCare/pages/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;


import '../pages/Config.dart';
import '../pages/Utiles.dart';
import 'PesoMascota.dart';
import 'User.dart';
import 'Vacunas.dart';

class SessionProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _token;
  User? _user;
  int _rolAcceso=0;
 // List<Mascota>? _mascotas; // Lista de Mascota que puede ser nula


  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  User? get user => _user;
  int get rolAcceso => _rolAcceso;
  //List<Mascota>? get mascota => _mascotas;

  Future<void>  login(User user, String token) async {
    _isLoggedIn = true;
    _user = user;
    _token = token;
    notifyListeners();
    //await fetchMascotas();
  }

  set rolAcceso(int value) {
    _rolAcceso = value;
    notifyListeners();  // Notify listeners if you're using Provider for state management
  }

  /*Future<void> fetchMascotas() async {
    if (_user == null) return;

    final response = await http.get(
      Uri.parse('http://192.168.0.154:8080/perfil-mascota?id=${_user!.id}'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> mascotasJson = json.decode(response.body);
      _mascotas = mascotasJson.map((json) => Mascota.fromJson(json)).toList();
    } else {
      _mascotas = [];
    }
    notifyListeners();
  }*/

  Future<int> addPesoMascota( PesoMascota nuevoPeso) async {
    if (_user == null) return 0;

    final fcToken=_user!.fcToken;
    final baseUrl = Config.get('api_base_url');
    final response = await http.post(
      Uri.parse('$baseUrl/api/pet/add-peso-mascota'),
      headers: {
        'Authorization': 'Bearer $_token',
        'fcmToken': '$fcToken',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(nuevoPeso),
    );
      return response.statusCode;
    /*if (response.statusCode == 200) {
      print('Peso guardado exitosamente');
    } else {
      print('Error al guardar el peso: ${response.statusCode}');
      throw Exception('Error al guardar el peso');
    }*/
    notifyListeners();
  }

  Future<int> addVacunaMascota( Vacunas nuevaVacuna) async {
    if (_user == null) return 0;
    final baseUrl = Config.get('api_base_url');

    final response = await http.post(
      Uri.parse('$baseUrl/api/pet/add-vacuna-mascota'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(nuevaVacuna),
    );
 return response.statusCode;
   /* if (response.statusCode == 200) {
      //print('Peso guardado exitosamente');


    } else {
      print('Error al guardar el peso: ${response.statusCode}');
      throw Exception('Error al guardar el peso');
    }*/
    notifyListeners();
  }

  // Add this method to update the user's photo
  void updateUserPhoto(String base64Photo) {
    if (_user != null) {
      user!.photo = base64Photo; // Update the photo property
      notifyListeners(); // Notify listeners to rebuild UI
    }
  }
  Future<void> registrarUsuario( User nuevUser) async {
    if (_user == null) return;
    final baseUrl = Config.get('api_base_url');
    final response = await http.post(
      Uri.parse('$baseUrl/api/user/create-user'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(nuevUser),
    );

    if (response.statusCode == 200) {
      print('Peso guardado exitosamente');
    } else {
      print('Error al guardar el peso: ${response.statusCode}');
      throw Exception('Error al guardar el peso');
    }
    notifyListeners();
  }

  Future<void> checkTokenValidity(BuildContext context) async {
    if (_token == null) return;
    final baseUrl = Config.get('api_base_url');
    final response = await http.get(
      Uri.parse('$baseUrl/api/autenticator/check-token'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if(data['valido']==false){
        logout(context);
      }

    }else{
      logout(context);
    }

  }
  // Función para cerrar sesión google
  Future<void> _logoutGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      await _googleSignIn.signOut();
      print("Sesión cerrada con Google");
      // Aquí puedes redirigir al usuario a la pantalla de inicio de sesión o realizar otras acciones.
    } catch (error) {
      print("Error al cerrar sesión: $error");
    }
  }

  void logout(BuildContext context) async {
    //if(_user!.plataforma.contains("internet"))
      _logoutGoogle();
    _isLoggedIn = false;
    _user = null;
    _token = null;
   // _mascotas = null;
    notifyListeners();

      // Redirigir al usuario a la pantalla de inicio de sesión
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()), // Cambia `LoginScreen()` por tu pantalla de inicio de sesión
      );
  }
}