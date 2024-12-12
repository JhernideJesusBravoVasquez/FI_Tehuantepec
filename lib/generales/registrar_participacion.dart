import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'; // Paquete para móvil
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Para detectar si es web

class RegistrarParticipacion extends StatefulWidget {
  final String idActividad;

  RegistrarParticipacion({required this.idActividad});

  @override
  _RegistrarParticipacionState createState() => _RegistrarParticipacionState();
}

class _RegistrarParticipacionState extends State<RegistrarParticipacion> {
  bool _participacionRegistrada = false;
  String _mensaje = '';

  // Escaneo QR
  Future<void> escanearQR() async {
    if (kIsWeb) {
      // Para navegadores web
      await _escanearEnWeb();
    } else {
      // Para móvil
      await _escanearEnMovil();
    }
  }

  // Escaneo en navegador web
  Future<void> _escanearEnWeb() async {
    try {
      TextEditingController qrController = TextEditingController();
      String? resultado = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Ingresar Matrícula Manualmente'),
            content: TextField(
              controller: qrController,
              decoration: InputDecoration(labelText: 'Matrícula'),
            ),
            actions: [
              TextButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
              ),
              TextButton(
                child: Text('Aceptar'),
                onPressed: () {
                  Navigator.of(context).pop(qrController.text);
                },
              ),
            ],
          );
        },
      );

      if (resultado != null && resultado.isNotEmpty) {
        await _registrarParticipacion(resultado);
      } else {
        setState(() {
          _mensaje = 'Código QR no válido o escaneo cancelado.';
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error al escanear en web: $e';
      });
    }
  }

  // Escaneo en móvil
  Future<void> _escanearEnMovil() async {
    try {
      String qrResultado = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Color del escáner
        'Cancelar', // Texto del botón de cancelar
        true, // Cambiar cámara
        ScanMode.QR, // Modo de escaneo QR
      );

      if (qrResultado != '-1') {
        await _registrarParticipacion(qrResultado);
      } else {
        setState(() {
          _mensaje = 'Escaneo cancelado o no válido.';
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error al escanear QR: $e';
      });
    }
  }

  // Registrar participación
  Future<void> _registrarParticipacion(String matricula) async {
    String idActividad = widget.idActividad;

    try {
      DocumentSnapshot estudianteSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(matricula)
          .get();

      if (!estudianteSnapshot.exists) {
        setState(() {
          _mensaje = 'La matrícula del estudiante no existe.';
        });
        return;
      }

      QuerySnapshot participacionExistente = await FirebaseFirestore.instance
          .collection('participaciones')
          .where('matricula', isEqualTo: matricula)
          .where('idActividad', isEqualTo: idActividad)
          .get();

      if (participacionExistente.docs.isNotEmpty) {
        setState(() {
          _mensaje = 'El estudiante ya está registrado en esta actividad.';
        });
        return;
      }

      await FirebaseFirestore.instance.collection('participaciones').add({
        'matricula': matricula,
        'idActividad': idActividad,
        'fechaRegistro': Timestamp.now(),
      });

      setState(() {
        _participacionRegistrada = true;
        _mensaje = 'Participación registrada exitosamente.';
      });
    } catch (e) {
      setState(() {
        _mensaje = 'Error al registrar la participación: $e';
      });
    }
  }

  // Importar matrículas desde archivo CSV
  Future<void> _importarMatriculasDesdeCsv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        Uint8List? fileBytes;
        if (result.files.first.bytes != null) {
          fileBytes = result.files.first.bytes;
        } else if (result.files.first.path != null) {
          final file = File(result.files.first.path!);
          fileBytes = await file.readAsBytes();
        }

        if (fileBytes != null) {
          final csvContent = utf8.decode(fileBytes);
          List<String> rows = csvContent.split('\n');

          for (int i = 1; i < rows.length; i++) {
            if (rows[i].trim().isEmpty) continue;
            List<String> row = rows[i].split(',');

            if (row.isNotEmpty) {
              String matricula = row[0].trim();

              var participacionDoc = await FirebaseFirestore.instance
                  .collection('participaciones')
                  .where('matricula', isEqualTo: matricula)
                  .where('idActividad', isEqualTo: widget.idActividad)
                  .get();

              if (participacionDoc.docs.isEmpty) {
                await FirebaseFirestore.instance.collection('participaciones').add({
                  'matricula': matricula,
                  'idActividad': widget.idActividad,
                  'fechaRegistro': Timestamp.now(),
                });
              }
            }
          }

          setState(() {
            _mensaje = 'Matrículas importadas exitosamente.';
          });
        }
      } else {
        setState(() {
          _mensaje = 'No se seleccionó ningún archivo.';
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error al importar matrículas: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Participación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID de la Actividad: ${widget.idActividad}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: escanearQR,
              child: Text('Escanear Código QR'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _importarMatriculasDesdeCsv,
              child: Text('Importar matrículas desde CSV'),
            ),
            SizedBox(height: 16),
            Text(
              _mensaje,
              style: TextStyle(
                color: _participacionRegistrada ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
