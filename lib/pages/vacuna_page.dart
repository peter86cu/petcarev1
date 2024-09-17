import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../class/Mascota.dart';
import '../class/SessionProvider.dart';
import '../class/Vacunas.dart';
import 'Config.dart';
import 'Utiles.dart';

class VaccinationPage extends StatefulWidget {
  final Mascota mascota;

  VaccinationPage({required this.mascota});

  @override
  _VaccinationPageState createState() => _VaccinationPageState();
}

class _VaccinationPageState extends State<VaccinationPage> {
  late List<Vacunas> _vaccinations;

  @override
  void initState() {
    super.initState();
    _vaccinations = widget.mascota.vacunas!;
  }

  bool _isNearExpiry(DateTime nextDate) {
    return nextDate.isBefore(DateTime.now().add(Duration(days: 7)));
  }

  void _showAddVaccinationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return AddVaccinationModal(widget.mascota);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vacunas de ${widget.mascota.nombre}'),
      ),
      body: Column(
        children: [
          Image.asset('lib/assets/mascotavacuna.png'), // Cambia a la ruta de tu imagen
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Nombre')),
                 // DataColumn(label: Text('Lote')),
                  DataColumn(label: Text('Administración')),
                  DataColumn(label: Text('Próxima')),
                ],
                rows: widget.mascota.vacunas!.map((vac) {
                  final nextDate = vac.proximaFechaVacunacion;
                  return DataRow(
                    cells: [
                      DataCell(Text(vac.nombreVacuna)),
                     // DataCell(Text(vac.loteVacuna)),
                      DataCell(Text(DateFormat.yMd().format(vac.fechaAdministracion))),
                      DataCell(Text(DateFormat.yMd().format(vac.proximaFechaVacunacion))),
                    ],
                    color: MaterialStateProperty.resolveWith<Color>((states) {
                      if (_isNearExpiry(nextDate)) {
                        return Colors.yellow.withOpacity(0.3);
                      }
                      return Colors.white;
                    }),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddVaccinationModal(context),
      ),
    );
  }
}

class AddVaccinationModal extends StatefulWidget {

  final Mascota mascota;

  AddVaccinationModal(this.mascota);

  @override
  _AddVaccinationModalState createState() => _AddVaccinationModalState();


}

class _AddVaccinationModalState extends State<AddVaccinationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _batchController = TextEditingController();
  late DateTime _selectedDate=DateTime.now();  // Inicializamos a null
  late Future<List<String>> _vaccinesFuture;

  late String _nombreVacuna="";
  late String _lote="";


  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Inicializamos la fecha aquí

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vaccinesFuture =  _fetchVaccines(widget.mascota.especie);

  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }


  Future<List<String>> _fetchVaccines(String query) async {
    //try {
      final session = Provider.of<SessionProvider>(context);
      final baseUrl = Config.get('api_base_url');
      String? token =session.token;
      var url = Uri.parse('$baseUrl/api/parameters/listado-vacunas'); // Reemplaza con la URL de tu API

      // Agrega los parámetros a la URL
      final params = {
        'tipo': query
      };

      // Construye la URL con los parámetros
      final uri = Uri.http(url.authority, url.path, params);


      var response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer '+token!, // Reemplaza 'tu_token_aqui' con tu token real
          'Content-Type': 'application/json', // Ejemplo de otro encabezado opcional
        },
      );

      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        List<dynamic> data = jsonDecode(response.body);
        final List vaccines = json.decode(response.body);
        return vaccines.map((vaccine) => vaccine['vacuna'] as String).toList();

      } else {
        throw Exception('Error al cargar las razas desde la API');
      }
    /*} catch (e) {
      print('Error: $e');
      // Manejar errores de la petición HTTP
    }
    return _vacunas;*/
  }

  Future<void> _submitData() async {

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final enteredBatch = _batchController.text;
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

      if (_nombreVacuna.isEmpty || enteredBatch.isEmpty || _selectedDate == null) {
        return;
      }

      final nuevaVacuna = Vacunas(vacunaid: 0, mascota: widget.mascota, nombreVacuna: _nombreVacuna, fechaAdministracion: DateTime.now(), proximaFechaVacunacion: _selectedDate, loteVacuna: enteredBatch);

      int status=await sessionProvider.addVacunaMascota( nuevaVacuna) as int;

      if(status==200){
        Utiles.showConfirmationDialog(context:context, title:'Registro exitoso', content:'Vacuna registrada correctamente.',onConfirm: () {
          setState(() {
            widget.mascota.vacunas?.add(nuevaVacuna);
            _nameController.clear();
            _batchController.clear();
          });

          Navigator.of(context).pop();

        });
      }else{
        Utiles.showErrorDialog(context:context, title:'Error', content: "Ocurrio un error. Intente mas tarde." );

      }


    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
    child: Form(
    key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          FutureBuilder<List<String>>(
            future: _fetchVaccines(widget.mascota.especie), // Pasar el tipo de mascota seleccionado
            builder: (context, snapshot) {
              /*  if (snapshot.connectionState == ConnectionState.waiting ) {
            return Center(child: CircularProgressIndicator());
          } else */if (snapshot.hasError) {
                return Center(child: Text('Error al cargar listado vacunas.'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No se encontraron vacunas.'));
              } else {
                List<String> razas = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    SizedBox(height: 20),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        // Filtrar opciones según el texto ingresado
                        return razas.where((raza) =>
                            raza.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (String selectedVacuna) {
                        setState(() {
                          _nombreVacuna = selectedVacuna; // Establecer la raza seleccionada
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
                            labelText: 'Nombre vacuna',
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
          SizedBox(height: 30),
          TextFormField(
            controller: _batchController, // Asignar el TextEditingController
            decoration: InputDecoration(
              labelText: 'Lote',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Por favor entre un número de lote.';
              }
              return null;
            },
            onSaved: (value) {
              _lote= _batchController.text;
            },
          ),

          Container(
            height: 70,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Sin fecha elegida!'
                        : 'Próxima Fecha: ${DateFormat.yMd().format(_selectedDate)}',
                  ),
                ),
                TextButton(
                  child: Text(
                    'Elige fecha',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: _presentDatePicker,
                ),
              ],
            ),
          ),
          ElevatedButton(
            child: Text('Guardar Vacuna'),
            onPressed: _submitData,
          ),
        ],
      ),
     ),
    );
  }
}
