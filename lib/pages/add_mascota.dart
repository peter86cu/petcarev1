import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../class/Mascota.dart';
import '../class/PesoMascota.dart';
import '../class/SessionProvider.dart';
import '../class/User.dart';
import 'Config.dart';
import 'Utiles.dart';

class AddMascotaPage extends StatefulWidget {
   final User user;
   final String? token;
  AddMascotaPage({required this.user,required this.token});

  @override
  _AgregarMascotaPageState createState() => _AgregarMascotaPageState();
}

class _AgregarMascotaPageState extends State<AddMascotaPage> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nombreController = TextEditingController();
  TextEditingController _razaController = TextEditingController();
  String _tipoMascotaSeleccionado = 'Perro';
  bool _siguienteHabilitado = false; // Estado para habilitar/deshabilitar el botón de siguiente
  String _colorSeleccionado = '';
  String _tipoPesoSeleccionado = '';
  String _pesoSeleccionado = '';
  File? _imagenMascota;
  bool _isLoading = false;
  String _unidadSeleccionada = 'kg';

  late String _nombreMascota='';
  late String _tipoMascota = '';
  late String _raza = '';
  late String _sexo = '';
  late String _fechaNacimiento = '';
  late int _edad = 0;
  late String _color = '';
  late String _tamano = '';
  late double _peso = 0;
  late String _unidadPeso = 'Kg';
  String _imagenBase64 = '';

  List<String> _razas = [];

  List<String> coloresDisponibles = [
    'Blanco',
    'Negro',
    'Gris',
    'Marrón',
    'Rojo',
    'Amarillo',
    'Verde',
    'Azul',
    'Naranja',
    'Rosa',
    'Morado',
    'Beige',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = Provider.of<SessionProvider>(context, listen: false);
      //session.checkTokenValidity();
    });
   // _fetchRazas(_tipoMascotaSeleccionado);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _razaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenMascota = File(pickedFile.path);

        // Convertir la imagen a base64
        final bytes = File(pickedFile.path).readAsBytesSync();
        _imagenBase64 = base64Encode(bytes);
      });
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Función para hacer la petición GET y obtener las razas desde la API
  Future<List<String>> _fetchRazas(String tipoMascota) async {
    try {
      final session = Provider.of<SessionProvider>(context);
      final baseUrl = Config.get('api_base_url');

      String? token = session.token;
      var url = Uri.parse(
          '$baseUrl/api/parameters/listado-tipo-raza'); // Reemplaza con la URL de tu API

      // Agrega los parámetros a la URL
      final params = {
        'tipo': tipoMascota
      };

      // Construye la URL con los parámetros
      final uri = Uri.http(url.authority, url.path, params);


      var response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ' + token!,
          // Reemplaza 'tu_token_aqui' con tu token real
          'Content-Type': 'application/json',
          // Ejemplo de otro encabezado opcional
        },
      );

      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _razas = data.map((razas) => razas['nombre'] as String)
              .toList(); // Convertir a List<String>
        });
      } else {
        throw Exception('Error al cargar las razas desde la API');
      }
    } catch (e) {
      print('Error: $e');
      // Manejar errores de la petición HTTP
    }
    return _razas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Mascota'),
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _buildNombrePage(),
            _buildTipoPage(),
            _buildRazaPage(),
            _buildSexoPage(),
            _buildFechaNacimientoPage(),
            //_buildEdadPage(),
            _buildColorPage(),
            _buildTamanoPage(),
            _buildPesoPage(),
            _buildFotoPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildNombrePage() {
    return _buildPage(
      title: 'Nombre de la Mascota',
      onNext: () {
        if (_formKey.currentState!.validate()) {
          _goToPage(1);
        }
      },
      body: TextFormField(
        controller: _nombreController, // Asignar el TextEditingController
        decoration: InputDecoration(
          labelText: 'Nombre de la Mascota',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Por favor ingrese el nombre de la mascota';
          }
          return null;
        },
        onSaved: (value) {
          _nombreMascota = value!;
        },
      ),
    );
  }


  Widget _buildRazaPage() {
    return _buildPage(
      title: 'Seleccione la raza',
      onBack: () => _goToPage(1),
      onNext: () {
        if (_formKey.currentState!.validate()) {
          _goToPage(3);
        }
      },
      body: FutureBuilder<List<String>>(
        future: _fetchRazas(_tipoMascotaSeleccionado),
        // Pasar el tipo de mascota seleccionado
        builder: (context, snapshot) {
          /*  if (snapshot.connectionState == ConnectionState.waiting ) {
            return Center(child: CircularProgressIndicator());
          } else */ if (snapshot.hasError) {
            return Center(child: Text('Error al cargar las razas'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No se encontraron razas'));
          } else {
            List<String> razas = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Seleccione la raza'),
                SizedBox(height: 20),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    // Filtrar opciones según el texto ingresado
                    return razas.where((raza) =>
                        raza.toLowerCase().contains(textEditingValue.text
                            .toLowerCase()));
                  },
                  onSelected: (String selectedRaza) {
                    setState(() {
                      _raza = selectedRaza; // Establecer la raza seleccionada
                    });
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      onFieldSubmitted: (String value) {
                        onFieldSubmitted();
                      },
                      decoration: InputDecoration(
                        labelText: 'Raza',
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return 'Por favor ingrese la raza';
                        }
                        return null;
                      },
                    );
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildTipoPage() {
    return _buildPage(
      title: 'Seleccione el tipo de mascota',
      onBack: () => _goToPage(0),
      onNext: () {
        if (_siguienteHabilitado) {
          _goToPage(2);
        }
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Seleccione el tipo de mascota'),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _tipoMascotaSeleccionado,
            items: [
              DropdownMenuItem(
                value: 'Perro',
                child: Row(
                  children: [
                    Image.asset(
                      'lib/assets/perro.png', // Ruta de la imagen para Perro
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: 10),
                    Text('Perro'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'Gato',
                child: Row(
                  children: [
                    Image.asset(
                      'lib/assets/gato.png', // Ruta de la imagen para Gato
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: 10),
                    Text('Gato'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'Ave',
                child: Row(
                  children: [
                    Image.asset(
                      'lib/assets/ave.png', // Ruta de la imagen para Ave
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: 10),
                    Text('Ave'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'Otro',
                child: Row(
                  children: [
                    Image.asset(
                      'lib/assets/otro.png', // Ruta de la imagen para Otro
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: 10),
                    Text('Otro'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _tipoMascotaSeleccionado = value!;
                _siguienteHabilitado = true;
              });
            },
            decoration: InputDecoration(
              labelText: 'Tipo de mascota',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSexoPage() {
    return _buildPage(
      title: 'Seleccione el sexo',
      onBack: () => _goToPage(2),
      onNext: () {
        if (_sexo == "") {
          // Mostrar mensaje de error si no se ha seleccionado un sexo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Debe seleccionar un sexo'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          _goToPage(
              4); // Avanzar a la siguiente página si se ha seleccionado un sexo
        }
      },
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Seleccione el sexo'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _sexo = 'Macho'; // Establece el sexo seleccionado
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _sexo == 'Macho' ? Colors.blue : Colors.grey,
              ),
              child: Text('Macho'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _sexo = 'Hembra'; // Establece el sexo seleccionado
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _sexo == 'Hembra' ? Colors.blue : Colors.grey,
              ),
              child: Text('Hembra'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFechaNacimiento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _fechaNacimiento = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget _buildFechaNacimientoPage() {
    return _buildPage(
      title: 'Fecha de Nacimiento',
      onBack: () => _goToPage(3),
      onNext: () => _goToPage(5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Fecha de Nacimiento'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _selectFechaNacimiento(context),
            child: Text('Seleccionar Fecha de Nacimiento'),
          ),
          SizedBox(height: 20),
          Text(
            _fechaNacimiento.isEmpty
                ? 'No se ha seleccionado ninguna fecha'
                : 'Fecha seleccionada: $_fechaNacimiento',
          ),
        ],
      ),
    );
  }


  Widget _buildColorPage() {
    return _buildPage(
      title: 'Seleccione el color',
      onBack: () => _goToPage(5),
      onNext: () => _goToPage(7),
      body: Expanded(
        child: Column(
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return coloresDisponibles.where((String color) {
                  return color.toLowerCase().contains(
                      textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                print('Color seleccionado: $selection');
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode, VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Escribe un color',
                    border: OutlineInputBorder(),
                  ),
                );
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.8,
                      child: ListView.builder(
                        padding: EdgeInsets.all(8.0),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return ListTile(
                            title: Text(option),
                            onTap: () {
                              onSelected(option);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTamanoPage() {
    return _buildPage(
      title: 'Tamaño',
      onBack: () => _goToPage(6),
      onNext: () => _goToPage(8),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tamaño'),
          // Implementa la selección del tamaño (como en tu ejemplo anterior)
        ],
      ),
    );
  }

  Widget _buildPesoPage() {
    return _buildPage(
      title: 'Peso',
      onBack: () => _goToPage(7),
      onNext: () => _goToPage(9),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Ingrese el peso de su mascota'),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Peso',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _pesoSeleccionado = value;  // Actualiza el peso seleccionado
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese un valor de peso';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Unidad',
              border: OutlineInputBorder(),
            ),
            value: _unidadSeleccionada,
            items: ['kg', 'lb'].map((String unidad) {
              return DropdownMenuItem<String>(
                value: unidad,
                child: Text(unidad),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _unidadSeleccionada = newValue!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFotoPage() {
    return _buildPage(
      title: 'Foto de la Mascota',
      onBack: () => _goToPage(8),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _imagenMascota == null
              ? IconButton(
            icon: Icon(Icons.camera_alt),
            iconSize: 50,
            onPressed: _pickImage,
          )
              : CircleAvatar(
            radius: 80,
            backgroundImage: FileImage(
              File(_imagenMascota!.path),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }


  Widget _buildPage({
    required String title,
    VoidCallback? onBack,
    VoidCallback? onNext,
    required Widget body,
  }) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 20),
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height * 0.1,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('lib/assets/add_mascota.jpeg'),
              ),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          body,
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onBack != null)
                ElevatedButton(
                  onPressed: onBack,
                  child: Text('Atrás'),
                ),
              if (onNext != null)
                ElevatedButton(
                  onPressed: onNext,
                  child: Text('Siguiente'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  int calcularEdad(String fechaNacimiento) {
    DateTime fechaNacimientoDT = DateTime.parse(fechaNacimiento);
    DateTime fechaActual = DateTime.now();

    int edad = fechaActual.year - fechaNacimientoDT.year;

    // Comprueba si el cumpleaños aún no ha ocurrido este año
    if (fechaActual.month < fechaNacimientoDT.month ||
        (fechaActual.month == fechaNacimientoDT.month &&
            fechaActual.day < fechaNacimientoDT.day)) {
      edad--;
    }

    return edad;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      final session = Provider.of<SessionProvider>(context, listen: false);
      
      final Uuid uuid = Uuid();
      String mascotaId = uuid.v4();
      _peso = double.tryParse(_pesoSeleccionado)!;
      final mascotaTem= Mascota(mascotaid: mascotaId,
          nombre: '',
          especie: '',
          raza: '',
          edad: 0,
          genero: '',
          color: '',
          tamano: '',
          personalidad: '',
          historialMedico: '',
          necesidadesEspeciales: '',
          comportamiento: '',
          fotos: "",
          usuario: widget.user!,
          vacunas: null,
          desparasitaciones: null,
          peso: null,
           isSelected: false,
           reservedTime: false);

      List<PesoMascota> lstPeso = [];
      if (_peso != null) {
        final nuevoPeso = PesoMascota(
          pesoid: 0,
          mascotaid: mascotaTem.mascotaid,
          fecha: DateTime.now(),
          peso: _peso,
          um: _unidadSeleccionada,
        );
        lstPeso.add(nuevoPeso);
      }
      if ( _fechaNacimiento!="") {
        _edad = calcularEdad(_fechaNacimiento);
      }

      final mascotaNew = Mascota(mascotaid: mascotaId,
          nombre: _nombreController.text,
          especie: _tipoMascotaSeleccionado,
          raza: _raza,
          edad: _edad,
          genero: _sexo,
          color: _colorSeleccionado,
          tamano: '',
          personalidad: '',
          historialMedico: '',
          fechaNacimiento: _fechaNacimiento,
          necesidadesEspeciales: '',
          comportamiento: '',
          fotos: _imagenBase64,
          usuario: widget.user,
          vacunas: null,
          desparasitaciones: null,
          peso: lstPeso,
           isSelected: false,
      reservedTime: false);
      final baseUrl = Config.get('api_base_url');
      String? token =  widget.token;

      final response = await http.post(
        Uri.parse('$baseUrl/api/pet/add-mascota'),
        headers: {
          'Authorization': 'Bearer '+ token!,
          'Content-Type': 'application/json'
        },
        body: jsonEncode(mascotaNew.toJson()),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        Mascota mascota = Mascota.fromJson(responseData);
        session.user?.mascotas?.add(mascota);

        Utiles.showConfirmationDialog(context:context, title:'Registro exitoso', content:'Mascota registrada exitosamente.',onConfirm: () {
          Navigator.pushReplacementNamed(context, '/home_propietario');

        });
      } else
      {
        Utiles.showErrorDialog(context:context, title:'Error', content: jsonDecode(response.body) );
      }


    } else {

    }
  }
}
