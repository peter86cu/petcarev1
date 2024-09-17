import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../class/User.dart';
import '../class/UserRoles.dart';
import 'Config.dart';
import 'Utiles.dart';


class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscured = true;
  bool _isLoading = false;
  String _nombre = '';
  String _correo = '';
  String _telefono = '';
  String _contrasena = '';
  String _selectedRole = 'Propietario';
  bool _isPasswordEnabled = true; // Define la variable aquí
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  bool _isAccepted = false;
  late bool _isAcceptedError=true;

  Future<void> _registrar() async {

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      //_verificarUsuario();
      setState(() {
        _isLoading = true;
      });
      // Implement your registration logic here
      final Uuid uuid = Uuid();
      int rol=0;

      if(_selectedRole=="Propietario")
        rol=2;
      else if (_selectedRole=="Veterinario")
        rol=3;
      else if (_selectedRole=="Tienda")
        rol=4;
      else if (_selectedRole=="Cuidador")
        rol=5;
      else if (_selectedRole=="Paseador")
        rol=6;
      else if (_selectedRole=="Estilista")
        rol=7;
      else if (_selectedRole=="Albergue")
        rol=8;
      else if (_selectedRole=="Otros")
        rol=9;

        String userId=uuid.v4();
      List<UserRoles> lstRoles = [];
      final objRol= UserRoles(id: 0,userid:userId ,rolid: rol);
      lstRoles.add(objRol);
      String base64Image='';

        base64Image = await Utiles.imageToBase64("imageUrl");

      final persona = User(userid:userId , password: _contrasena, name: _nombre,photo: base64Image, phone: _telefono,  plataforma: "Manual", roles: lstRoles, state: 1, username: _correo, createdate: DateTime.now(), mascotas: null);
      final baseUrl = Config.get('api_base_url');
      final response = await http.post(
        Uri.parse('$baseUrl/create-user'),
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

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        // Show success dialog
          // Aquí va la acción a ejecutar cuando se confirma
          print('Perfil registrado confirmado');
        },);

    }
  }


  Future<void> _verificarUsuario() async {


    try {
      // Hacer la solicitud a la API para verificar si el correo y el teléfono están registrados
      final baseUrl = Config.get('api_base_url');
      final response = await http.get(
        Uri.parse('$baseUrl/validar-username-phone?username=$_correo&phone=$_telefono') );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['existe']==4) {
          // Mostrar el mensaje y opciones al usuario
          bool? continuar = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Datos Registrados'),
                content: Text(
                  'El correo electrónico y/o teléfono ya están registrados con el perfil ${data['rol']} (${data['perfil']}). ¿Desea registrarse con estos datos?',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text('Sí'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('No'),
                  ),
                ],
              );
            },
          );

          if (continuar == true) {
            // Deshabilitar el campo de contraseña si el usuario elige continuar
            setState(() {
              _isPasswordEnabled = false;
              _registrar();
            });
          } else {
            // Limpiar los campos de correo y teléfono si el usuario elige no continuar
            setState(() {
              _correoController.clear();
              _telefonoController.clear();
            });
          }
        } else {
          // Continuar con el registro si el usuario no está registrado
          _registrar();
        }
      } else {
        // Manejar el error de la API
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al verificar el usuario.'),
        ));
      }
    } catch (e) {
      // Manejar la excepción
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al conectar con el servidor.'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      /*appBar: AppBar(
        title: Text('Registrar Perfil'),
      ),*/
      body: SingleChildScrollView(
    child: Container(
    width: screenSize.width, // Usar el ancho de la pantalla
    color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20),
              width: screenSize.width,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('lib/assets/add_mascota.jpeg'),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(20, 20, 20, 87),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Nombre y apellido',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor ingrese su nombre';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _nombre = value!;
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        width: 100,
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Soy un',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            'Propietario',
                            'Tienda',
                            'Estilista',
                            'Cuidador',
                            'Paseador',
                            'Veterinario',
                            'Albergue',
                            'Otro',
                          ].map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedRole = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor seleccione una opción.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: _correoController,
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor ingrese su correo electrónico';
                          }
                          if (!Utiles.isValidEmail(value)) {
                            return 'Correo electrónico no válido';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _correo = value!;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: _telefonoController,
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor ingrese su número de teléfono';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _telefono = value!;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                            ),
                            obscureText: _isPasswordEnabled ? _isObscured : false,
                            validator: (value) {
                              if (_isPasswordEnabled && value!.isEmpty) {
                                return 'Por favor ingrese su contraseña';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _contrasena = value!;
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              _isObscured ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    // Checkbox de políticas y condiciones
                    CheckboxListTile(
                      title: Row(
                        children: [
                          Text(
                            'Aceptar ',
                            style: TextStyle(
                              color: _isAcceptedError ? Colors.red : Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Abre la URL en el navegador
                              launch('http://179.31.2.98/');
                            },
                            child: Text(
                              'Políticas y Condiciones',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      value: _isAccepted,
                      onChanged: (bool? value) {
                        setState(() {
                          _isAccepted = value!;
                          _isAcceptedError = false; // Ocultar el error si el usuario marca el checkbox
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (_isAcceptedError)
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Debes aceptar los términos y condiciones para continuar.',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _verificarUsuario();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0E64D2),
                        padding: EdgeInsets.fromLTRB(11.1, 6, 0, 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        minimumSize: Size(312, 48),
                      ),
                      child: Text(
                        'Registrar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          color: Color(0xE5FFFFFF),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Ya tienes una cuenta?',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Color(0xE5000000),
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: Color(0xFF2300FB),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }


  Widget buildInputField(String labelText, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 37),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0x66FFFDFD)),
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFFFFFFFF),
      ),
      child: SizedBox(
        width: 312,
        height: 48,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: labelText,
              border: InputBorder.none,
            ),
            obscureText: isPassword,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Por favor ingrese $labelText';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}

