import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Config.dart';
import 'Utiles.dart';
import 'login_page.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final  _formKey  = GlobalKey<FormState>();
  late String _email ='';
  bool _isLoading = false;


  Future<void> _recoverPassword() async {

    setState(() {
      _isLoading = true;
    });

    //Utiles.showLoadingDialog(context: context);

    // Simulate a network call
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      // Handle the login logic here
    });

   // Utiles.hideLoadingDialog(context);


    if (_formKey.currentState!.validate()) {


      try{
        final baseUrl = Config.get('api_base_url');
        final url = Uri.parse('$baseUrl/resetear-password'); // URL de tu API
        final headers = {'Content-Type': 'application/json'};

        // Agrega los parámetros a la URL
        final params = {
          'email': _email
        };

        // Construye la URL con los parámetros
        final uri = Uri.http(url.authority, url.path, params);

        // Realiza la solicitud GET
        final response = await http.get(uri, headers: headers);

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);

         //Mensaje de confirmacion OK
          Utiles.showConfirmationDialog(context: context,title: 'Confirmación',content: responseData,onConfirm: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          );

        } else {
          final responseData = json.decode(response.body);
          //Mensaje de warining
          Utiles.showInfoDialog(context: context,title: 'Mensaje', message: responseData,);
        }
      }catch (error){
        Utiles.showErrorDialog(context: context, title: 'Error', content: error.toString());
      }finally {
        setState(() {
          _isLoading = false;
        });
      }

     // Navigator.of(context).pop(); // Cerrar la pantalla de recuperación de contraseña
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recuperar Contraseña'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.3, // Ajusta la altura de la imagen según tus necesidades
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('lib/assets/mascota_recupera.jpeg'),
                ),
              ),
            ),
            Container(
              color: Colors.white, // Fondo blanco para toda la pantalla
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
                          _email = value!;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _recoverPassword();
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
                        'Recuperar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          color: Color(0xE5FFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}
