
import 'package:PetCare/pages/registrar_persona.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';
import 'dart:convert';

import '../class/PesoMascota.dart';
import '../class/ResponseLogin.dart';
import '../class/SessionProvider.dart';
import '../class/UserRoles.dart';
import '../class/User.dart' as NewUser;
import 'Config.dart';
import 'Utiles.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_auth/local_auth.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  bool _isObscured = true; // Estado para manejar la visibilidad de la contraseña
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  String _plataforma='nok';
  String _loginPlataforma='';
  bool _isLoadingLogin = false;
  bool _isLoadingGoogle = false;
  bool _isLoadingFaceID = false;

  late FirebaseMessaging messaging;
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }



  // Método para inicializar Firebase y obtener el token FCM
  void initializeFirebase() async {
    messaging = FirebaseMessaging.instance;

    // Solicitar permisos para iOS (si es necesario)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // Obtén el token de FCM para el dispositivo actual
      fcmToken = await messaging.getToken();
      print("FCM Token: $fcmToken");

      // Manejar notificaciones mientras la app está en primer plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received a message while in foreground: ${message.notification}');
        if (message.notification != null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(message.notification!.title ?? "No title"),
              content: Text(message.notification!.body ?? "No body"),
            ),
          );
        }
      });

      // Manejar cuando la aplicación se abre desde una notificación (cuando está en segundo plano)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('App opened from notification: ${message.notification}');
        // Aquí puedes navegar a una pantalla específica si la app se abrió desde una notificación
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }


  Future<void> _loginWithGoogle() async {
    try {

      // Cerrar sesión de cualquier cuenta anterior de Google para forzar la selección de cuenta
      await GoogleSignIn().signOut();

      // Iniciar el flujo de inicio de sesión de Google
      final GoogleSignInAccount?  googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        return;
      }else{
        Utiles.logUserInteraction(googleUser.id,'_loginWithGoogle',additionalData: {'login': 'Google','user':googleUser.email});
        _plataforma='internet';
       if(await _checkUserInDatabase(googleUser.email)){
         _username=googleUser.email;
        _loginPlataforma='Google';
        _login();
       }else{
         _showRegisterPrompt(googleUser.id, googleUser.displayName.toString(), googleUser.email, googleUser.photoUrl!);
       }


      }

    } catch (e) {
      print("Error al iniciar sesión con Google: $e");
      // Manejo de errores, puedes mostrar un diálogo o snackbar aquí
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar sesión con Google")),
      );
    }
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }


  Future<void> _authenticateWithFaceID() async {
    try {
      bool isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'Por favor, autentifícate usando Face ID para continuar',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        // Handle successful authentication here
        print("Face ID authentication successful");
      } else {
        print("Face ID authentication failed");
      }
    } catch (e) {
      print("Face ID authentication error: $e");
    }
  }


  Future<bool> _checkUserInDatabase(String email) async {
    // Lógica para verificar si el usuario existe en la base de datos
    // Ejemplo:
    final baseUrl = Config.get('api_base_url');
    final response = await http.get(
        Uri.parse('$baseUrl/api/user/validar-google/$email'));
    return response.statusCode == 200;
  }


  void _showRegisterPrompt(String id,String name, String email, String photo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Usuario no registrado"),
          content: Text(
              "El usuario $email no está registrado. ¿Deseas registrarte?"),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Registrar"),
              onPressed: () {
                Navigator.of(context).pop();
                _showRoleNewUser(id, name, email,photo);
              },
            ),
          ],
        );
      },
    );
  }

  void _showRoleNewUser(String id,String name, String email, String photo) {
    String? selectedRole;
    List<String> roles = ["Propietario", "Estilista", "Vendedor", "Albergue"];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Selecciona un rol"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Rol",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedRole,
                    items: roles.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedRole = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor selecciona un rol';
                      }
                      return null;
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Guardar"),
              onPressed: () {
                if (selectedRole != null) {
                  Navigator.of(context).pop();
                  _registerUser(id,name, email, selectedRole!, photo);
                } else {
                  // Mostrar un mensaje de error si no se ha seleccionado un rol
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Por favor selecciona un rol."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _registerUser(String id,String name, String email, String _selectedRole, String imageUrl) async {

    int rol=0;

    if(_selectedRole=="Propietario")
      rol=2;
    else if (_selectedRole=="Veterinario")
      rol=3;
    else if (_selectedRole=="Tienda")
      rol=4;
    else if (_selectedRole=="Guarderia")
      rol=5;
    else if (_selectedRole=="Paseador")
      rol=6;
    else if (_selectedRole=="Estilista")
      rol=7;
    else if (_selectedRole=="Albergue")
      rol=8;
    else if (_selectedRole=="Otros")
      rol=9;

    List<UserRoles> lstRoles = [];
    final objRol= UserRoles(id: 0,userid:id ,rolid: rol);
    lstRoles.add(objRol);
    String base64Image='';
    if(_plataforma.contains("internet")){
       base64Image = await Utiles.imageToBase64(imageUrl);
    }


    final persona =NewUser.User(userid:id , password: '', name: name, phone: '',  plataforma: _plataforma, roles: lstRoles, state: 1, username: email, createdate: DateTime.now(), mascotas: null,photo: base64Image,fcToken: fcmToken);
    final baseUrl = Config.get('api_base_url');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/create-user'),
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode(persona.toJson()),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        Utiles.showConfirmationDialog(context:context, title:'Registro exitoso', content:'Su perfil ha sido registrado exitosamente.',onConfirm: () {
          Navigator.pushReplacementNamed(context, '/login');

        });
      } else
      {
        Utiles.showErrorDialog(context:context, title:'Error', content: jsonDecode(response.body) );
      }


    } catch (e) {
      // Manejar errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al registrar usuario."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    //OBTENGO EL TOKEN FCM PARA NOTIFICACIONES
    late FirebaseMessaging messaging;


    try {
      final baseUrl = Config.get('api_base_url');
      final url = Uri.parse('$baseUrl/api/autenticator/login'); // URL de tu API
      final headers = {'Content-Type': 'application/json',
        'fcmToken': fcmToken!};
      final body = json.encode({'username': _username,'password':_password,'plataforma':_plataforma});
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final userData = ResponseLogin.fromJson(responseData);

        //Obtener pesos de mascotas
        /*if (userData.user.mascotas != null) {
          for (var mascota in userData.user.mascotas!) {
            final baseUrl = Config.get('api_base_url');

            var url = Uri.parse(
                '$baseUrl/api/pet/peso-mascota'); // Reemplaza con la URL de tu API

            // Agrega los parámetros a la URL
            final params = {
              'id': mascota.mascotaid
            };

            // Construye la URL con los parámetros
            final uri = Uri.http(url.authority, url.path, params);

            var responsePeso = await http.get(
              uri,
              headers: {
                'Authorization': 'Bearer ' + userData.token!,
                // Reemplaza 'tu_token_aqui' con tu token real
                'Content-Type': 'application/json',
                // Ejemplo de otro encabezado opcional
              },
            );

            if (responsePeso.statusCode == 200) {
              final responseData = jsonDecode(utf8.decode(responsePeso.bodyBytes));
              List<PesoMascota> peso = (responseData as List)
                  .map((item) => PesoMascota.fromJson(item))
                  .toList();
              mascota.peso = peso;
            }
          }
        } else {
          print('La lista de mascotas es null');
        }*/

        if(userData.user.fcToken=="" || userData.user.fcToken != fcmToken){
          final baseUrl = Config.get('api_base_url');
          final url = '$baseUrl/api/user/fc/${userData.user.userid}/update/$fcmToken';

          final responseFC = await http.post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer ${userData.token}',
              'Content-Type': 'application/json',
            },
          );
            if(responseFC.statusCode==200){
              setState(() {
                userData.user.fcToken=fcmToken;
              });
            }else{
              print('Ocurrio un error en actualizar el FC del usuario '+userData.user.username);
            }

        }

        final sessionProvider = Provider.of<SessionProvider>(
            context, listen: false);
        await sessionProvider.login(userData.user, userData.token);
        final roles = userData.user.roles; // Obtener los roles del usuario

        /*if(userData.user.rol==2 || userData.user.rol==1)
        Navigator.pushReplacementNamed(context, '/home_propietario');
        if(userData.user.rol==7)
        Navigator.pushReplacementNamed(context, '/home_estilista');*/

        if (roles.length > 1) {
          // Mostrar modal si hay más de un rol
          _showRoleSelectionDialog(roles,sessionProvider);
        } else if (roles.length == 1) {
          // Redirigir automáticamente si solo hay un rol
          _navigateToHome(roles.first.rolid,sessionProvider);
        }else{
          Utiles.showErrorDialog(context: context, title: 'Error', content: 'El usuario '+sessionProvider.user!.username +' no tiene asignado un perfil de acceso. Por favor contactar a un administrador.\n info@firuapp.com.uy.');
        }
      } else if (response.statusCode == 204) {
        //Obtener mensaje del response
        // final errorData = json.decode(response.body);
        // Manejar el error de la API
        Utiles.showInfoDialog(context: context,
            title: 'Login',
            message: 'Usuario o contraseña incorrecta.');
      } else if (response.statusCode == 502) {
        Utiles.showErrorDialog(context: context,
            title: 'Error',
            content: 'Servicio en mantenimiento.');
      } else if (response.statusCode == 404) {
        Utiles.showInfoDialog(context: context,
            title: 'Notificación',
            message: 'Debe confirmar el correo para poder acceder.');
      }else if (response.statusCode == 406) {
        Utiles.showInfoDialog(context: context,
            title: 'Notificación',
            message: 'El usuario '+_username +' no esta registrado en '+ _loginPlataforma +' intente desde otro acceso.');
      }
      else if (response.statusCode == 400) {
        Utiles.showErrorDialog(context: context,
            title: 'Error',
            content: 'Usuario no autorizado.');
      }



    } catch (error) {
      Utiles.showErrorDialog(context: context,
          title: 'A ocurrido un error',
          content: error.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  Icon _getRoleIcon(int role) {
    switch (role) {
      case 1:
        return Icon(Icons.person, color: Colors.blue); // Icono para Propietario
      case 2:
        return Icon(
            Icons.directions_walk, color: Colors.green); // Icono para Paseador
      case 4:
        return Icon(
            Icons.shop, color: Colors.green); // Icono para Tienda mascota
      case 7:
        return Icon(Icons.cut, color: Colors.purple); // Icono para Estilista
      default:
        return Icon(Icons.help, color: Colors.grey); // Icono predeterminado
    }
  }

  void _showRoleSelectionDialog(List<UserRoles> roles, SessionProvider sessionProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecciona tu perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: roles.map((role) {
              return ListTile(
                leading: _getRoleIcon(role.rolid),
                title: Text(_getRoleName(role.rolid)),
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToHome(role.rolid,sessionProvider);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getRoleName(int role) {
    switch (role) {
      case 1:
        return 'Administrador';
      case 2:
        return 'Propietario de Mascota';
      case 4:
        return 'Tienda mascota';
      case 7:
        return 'Estilista';
      default:
        return 'Rol desconocido';
    }
  }

  void _navigateToHome(int role, SessionProvider sessionProvider, ) {
    switch (role) {
      case 1:
        Navigator.pushReplacementNamed(context, '/home_propietario');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/home_propietario');
        break;
      case 7:
        sessionProvider.rolAcceso=role;
        Navigator.pushReplacementNamed(context, '/home_estilista');
        break;
      default:
      // Manejo de rol desconocido
        Utiles.showInfoDialog(
            context: context, title: 'Error', message: 'Rol en desarrollo.');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screenSize.width, // Usar el ancho de la pantalla
          color: Colors.white,
          child: Column(
            children: [
              // Encabezado con la imagen
              Container(
                width: screenSize.width,
                height: screenSize.height * 0.35, // Usar 35% de la altura de la pantalla
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('lib/assets/pets_371573312801.jpeg'),
                  ),
                ),
              ),
              // Contenido del formulario
              Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20), // Padding ajustado
                child: Form(
                  key: _formKey,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Obtener el ancho disponible para los campos de texto
                      final fieldWidth = constraints.maxWidth;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // Campo de Usuario
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Correo electrónico',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.mail),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu usuario';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _username = value!;
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          // Campo de Contraseña
                          SizedBox(
                            width: fieldWidth,
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscured ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isObscured = !_isObscured;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _isObscured,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu contraseña';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _password = value!;
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          // Botón de Login
                          _isLoadingLogin
                              ? CircularProgressIndicator()
                              : SizedBox(
                            width: fieldWidth, // Usar el mismo ancho que los campos
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isLoadingLogin = true;
                                });
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  _plataforma = 'manual';
                                  _loginPlataforma='Correo/Contraseña';
                                  _login().then((_) {
                                    setState(() {
                                      _isLoadingLogin = false;
                                    });
                                  });
                                } else {
                                  setState(() {
                                    _isLoadingLogin = false;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0E64D2),
                                padding: EdgeInsets.symmetric(vertical: 14), // Padding ajustado
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24,
                                  color: Color(0xE5FFFFFF),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Botón para Google
                          _isLoadingGoogle
                              ? CircularProgressIndicator()
                              : SizedBox(
                            width: fieldWidth, // Usar el mismo ancho que los campos
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isLoadingGoogle = true;
                                });
                                _loginWithGoogle().then((_) {
                                  setState(() {
                                    _isLoadingGoogle = false;
                                  });
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              icon: Image.asset(
                                'lib/assets/logos/google_logo.png',
                                height: 30.0,
                                width: 30.0,
                              ),
                              label: Text(
                                'Login con Google',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24,
                                  color: Color(0xE5FFFFFF),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Botón para Face ID
                          _isLoadingFaceID
                              ? CircularProgressIndicator()
                              : SizedBox(
                            width: fieldWidth, // Usar el mismo ancho que los campos
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isLoadingFaceID = true;
                                });
                                _authenticateWithFaceID().then((_) {
                                  setState(() {
                                    _isLoadingFaceID = false;
                                  });
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              icon: Icon(Icons.face, color: Colors.white),
                              label: Text(
                                'Login con Face ID',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24,
                                  color: Color(0xE5FFFFFF),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          // Link para registrarse
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    '¿No tienes una cuenta?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      color: Color(0xCC000000),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => RegisterPage()),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      'Registrarte',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                        color: Color(0xFF1703FC),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

