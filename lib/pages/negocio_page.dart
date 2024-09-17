
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';

import '../class/Direccion.dart';
import '../class/Localidades.dart';
import '../class/Negocio.dart';
import '../class/SessionProvider.dart';

class RegisterBusinessPage extends StatefulWidget {
  @override
  _RegisterBusinessPageState createState() => _RegisterBusinessPageState();
}

class _RegisterBusinessPageState extends State<RegisterBusinessPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _rutController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetNumberController = TextEditingController();
  final _localityController = TextEditingController();
  File? _logo;
  final _picker = ImagePicker();
  final _defaultLogoUrl = 'https://example.com/default-logo.png'; // URL del logo por defecto

  final List<String> _departments = [
    'Montevideo',
    'Canelones',
    'Maldonado',
    // Añade más departamentos aquí
  ];
  String? _selectedDepartment;
  List<String> _localities = [];
  bool _isValidAddress = false;

  Future<void> _pickLogo() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        final session = Provider.of<SessionProvider>(context, listen: false);

        session.checkTokenValidity(context);
        _logo = File(pickedFile.path);
      });
    }
  }

  Future<void> _registerBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final name = _nameController.text;
    final rut = _rutController.text;
    final phone = _phoneController.text;
    final streetNumber = _streetNumberController.text;
    final locality = _localityController.text;
    final department = _selectedDepartment ?? '';
    final logoUrl = _logo != null ? await _uploadLogo(_logo!) : _defaultLogoUrl;
    final Uuid uuid = Uuid();
    final business = Business(
      id:uuid.v4(),
      name: name,
      rut: rut,
      longitud: '',
      latitud: '',
      createdAt: DateTime.now(),
      phone: phone,
      address: streetNumber+' , '+ locality +' , '+department,
      logoUrl: logoUrl,
      rating:0.0,
      user: null,
      services: [],
      reviewCount: 0
    );

    final response = await http.post(
      Uri.parse('https://your-api-url.com/register-business'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode(business.toJson()),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Business registered successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to register business')));
    }
  }

  Future<String> _uploadLogo(File logo) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://your-api-url.com/upload-logo'),
    );

    request.files.add(await http.MultipartFile.fromPath('logo', logo.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseData);
      return data['logoUrl'];
    } else {
      throw Exception('Failed to upload logo');
    }
  }

  Future<void> _fetchLocalities(String department) async {
    final response = await http.get(
      Uri.parse('https://direcciones.ide.uy/api/v0/geocode/localidades?alias=true&departamento=$department'),
    );

    if (response.statusCode == 200) {
      //final data = jsonDecode(response.body) as List;
      List<dynamic> data = jsonDecode(response.body);
      final List vaccines = json.decode(response.body);

      setState(() {
        _localities = vaccines.map((vaccine) => vaccine['nombre'] as String).toList();
        _localityController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load localities')));
    }
  }

  Future<void> _validateAddress(String address) async {
   String localidad= _localityController.text;
    final response = await http.get(
      Uri.parse('https://direcciones.ide.uy/api/v0/geocode/BusquedaDireccion?calle=$address&departamento=$_selectedDepartment&localidad=$localidad'),
    );

    if (response.statusCode == 200) {
      final data1 = jsonDecode(response.body);
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
       List<Direccion> direccions= data.map((json) => Direccion.fromJson(json)).toList();


      setState(() {
        bool econtre=false;
        for (int i = 0; i < direccions.length; i++) {
          Direccion direccion = direccions[i];
          if(direccion.error!.isEmpty){
            econtre=true;
            break;
          }
        }
      if(econtre){
        _isValidAddress = true;

      }else{
        _isValidAddress = false;

      }

      });
      if (!_isValidAddress) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid address')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to validate address')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registar Negocio'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.27, // Ajusta la altura de la imagen según tus necesidades
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('lib/assets/mascotaempresa.jpg'),
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
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del negocio',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter the business name';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: _rutController,
                        decoration: InputDecoration(
                          labelText: 'RUT (opcional)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter the RUT';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Número de teléfono',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter the phone number';
                          }
                          return null;
                        },
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Departamento',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedDepartment,
                        items: _departments.map((department) {
                          return DropdownMenuItem(
                            value: department,
                            child: Text(department),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartment = value;
                            _fetchLocalities(value!);
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a department';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Localidad',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        value: _localityController.text.isEmpty ? null : _localityController.text,
                        items: _localities.map((locality) {
                          return DropdownMenuItem(
                            value: locality,
                            child: Text(locality),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _localityController.text = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a locality';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: TextFormField(
                        controller: _streetNumberController,
                        decoration: InputDecoration(
                          labelText: 'Calle y número',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Entre una calle y número.';
                          }
                          if (!_isValidAddress) {
                            return 'Direccón no encontrada.';
                          }
                          return null;
                        },
                        onFieldSubmitted: (value) {
                          _validateAddress(value);
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: _pickLogo,
                      child: Text('Pick Logo'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _registerBusiness,
                      child: Text('Registar Negocio'),
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

