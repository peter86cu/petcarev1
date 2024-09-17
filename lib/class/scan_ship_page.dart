import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class ScanChipScreen extends StatefulWidget {
  @override
  _ScanChipScreenState createState() => _ScanChipScreenState();
}

class _ScanChipScreenState extends State<ScanChipScreen> {
  String chipData = '';
  bool isScanning = false;

  Future<void> _scanChip() async {
    setState(() {
      isScanning = true;
      chipData = '';
    });

    try {
      // Iniciar la sesión de escaneo NFC
      NFCTag tag = await FlutterNfcKit.poll();
      // Leer la información del chip
      setState(() {
        chipData = 'Chip ID: ${tag.id}';
        isScanning = false;
      });

      // Aquí puedes hacer una llamada a la API para obtener los datos del perro usando el ID del chip
      // String response = await fetchDogDataFromChip(tag.id);
      // setState(() {
      //   chipData = response; // Muestra los datos del perro en la pantalla
      // });

    } catch (e) {
      setState(() {
        chipData = 'Error al leer el chip: $e';
        isScanning = false;
      });
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear Chip del Perro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Acerca el teléfono al chip del perro para escanear.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            isScanning
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: _scanChip,
              icon: Icon(Icons.nfc),
              label: Text('Escanear Chip'),
            ),
            SizedBox(height: 30),
            Text(
              chipData.isEmpty ? 'No se ha escaneado ningún chip' : chipData,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
