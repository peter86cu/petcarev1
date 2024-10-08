import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../class/Mascota.dart';
import '../class/PesoMascota.dart';
import '../class/SessionProvider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart'; // Para formatear la fecha
import 'package:http/http.dart' as http;

import 'Config.dart';
import 'Utiles.dart';


class PesoPage extends StatefulWidget {
  final Mascota mascota;

  PesoPage({required this.mascota});

  @override
  _PesoPageState createState() => _PesoPageState();


}


class _PesoPageState extends State<PesoPage> {
  final _pesoController = TextEditingController();
  String _unidadSeleccionada = 'kg'; // Unidad predeterminada
  StompClient? stompClient;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = Provider.of<SessionProvider>(context, listen: false);
      session.checkTokenValidity(context);
      _connectWebSocket();
    });
  }

  void _connectWebSocket() {
    final baseUrlWS = Config.get('api_ws_url');
    stompClient = StompClient(
      config: StompConfig(
        url: '$baseUrlWS/ws',
        onConnect: _onWebSocketConnected,
        onWebSocketError: (dynamic error) => print('WebSocket error: $error'),
        onDisconnect: (frame) => print('WebSocket disconnected'),
      ),
    );
    stompClient?.activate();
  }

  void _onWebSocketConnected(StompFrame frame) {
    stompClient?.subscribe(
      destination: '/topic/mascota-peso',
      callback: (StompFrame frame) {
        setState(() {
          if (frame.body != null) {
            // Parse the incoming JSON data
            final newPeso = jsonDecode(frame.body!);

           // PesoMascota newPeso = newPesoData.fromJson(json);

            // Update the events list of the selected mascota
            setState(() {
              // Iterate over the new events
              // Iterate over the new events

                // Find the index of the event if it exists
                final existingPesoIndex = widget.mascota.peso
                  ?.indexWhere((peso) => peso.pesoid == newPeso.peso);

                if (existingPesoIndex != null && existingPesoIndex != -1) {
                  // If the event exists, replace it
                  widget.mascota.peso?[existingPesoIndex] = newPeso;
                } else {
                  // If the event does not exist, add it
                  widget.mascota.peso?.add(newPeso);
                }

            });
          }        });
      },
    );
  }


  @override
  void dispose() {
    _pesoController.dispose();
    stompClient?.deactivate();
    super.dispose();
  }


  Future<void> _agregarPeso() async {
    final sessionProvider = Provider.of<SessionProvider>(
        context, listen: false);

    final double? peso = double.tryParse(_pesoController.text);
    if (peso != null) {
      final nuevoPeso = PesoMascota(
        pesoid: 0,
        mascotaid: widget.mascota.mascotaid,
        fecha: DateTime.now(),
        peso: peso,
        um: _unidadSeleccionada,
      );

      try {
        //await guardarPeso(nuevoPeso);

        int status = await sessionProvider.addPesoMascota(nuevoPeso);
        if (status == 200) {
          Utiles.showConfirmationDialog(context: context,
              title: 'Registro exitoso',
              content: 'Peso registrado correctamente.',
              onConfirm: () {
                setState(() {
                  widget.mascota.peso?.add(nuevoPeso);
                  _pesoController.clear();
                });
              });
        } else {
          Utiles.showErrorDialog(context: context,
              title: 'Error',
              content: "Ocurrio un error. Intente mas tarde.");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el peso: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingrese un peso válido')),
      );
    }
  }

  // Filtrar los datos del último mes
  List<PesoMascota>? _filtrarDatosUltimoMes() {
    final ahora = DateTime.now();
    final inicioDelMes = DateTime(ahora.year, ahora.month - 1, ahora.day);
    return widget.mascota.peso?.where((peso) {
      return peso.fecha.isAfter(inicioDelMes) && peso.fecha.isBefore(ahora);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Ensure the list is not null
    final pesoList = widget.mascota.peso ?? [];

    // Generar puntos para la gráfica de barras
    List<BarChartGroupData>? _generarDatosGrafica() {
      // Use the non-null list
      return pesoList.map((peso) {
        return BarChartGroupData(
          x: peso.fecha.day,
          barRods: [
            BarChartRodData(
              toY: peso.peso,
              color: Colors.blue,
              width: 15, // Ajusta el ancho de las barras
            ),
          ],
        );
      }).toList();
    }

    // Obtener los valores máximos y mínimos del eje Y
    double? _getMaxY() {
      if (pesoList.isEmpty) return 0;
      return pesoList.map((peso) => peso.peso).reduce((a, b) => a > b ? a : b);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Pesos' + " de " + widget.mascota.nombre),
      ),
      body: SingleChildScrollView( // Agregar el SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen en el encabezado
              Container(
                width: double.infinity,
                height: 250.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/assets/pesamascota.jpg'),
                    // Reemplaza con la ruta de tu imagen
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              // Campo de Peso y DropdownButton en el mismo Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pesoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Peso',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _unidadSeleccionada,
                      items: <String>['kg', 'lbs'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _unidadSeleccionada = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _agregarPeso,
                child: Text('Agregar Peso'),
              ),
              SizedBox(height: 25.0),
              // Gráfica de línea
              Container(
                height: 250.0,
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            final datosFiltrados = _filtrarDatosUltimoMes();
                            if (index < datosFiltrados!.length) {
                              final peso = datosFiltrados[index];
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  dateFormat.format(peso.fecha),
                                  style: TextStyle(fontSize: 12, color: Colors.black),
                                ),
                              );
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(""),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                value.toString(),
                                style: TextStyle(fontSize: 12, color: Colors.black),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    barGroups: _generarDatosGrafica(),
                    alignment: BarChartAlignment.spaceAround,
                    minY: 0,
                    maxY: _getMaxY(),
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