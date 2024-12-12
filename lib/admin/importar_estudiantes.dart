import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'dart:io' if (dart.library.io) 'dart:io';

class ImportarEstudiantes extends StatefulWidget {
  @override
  _ImportarEstudiantes createState() => _ImportarEstudiantes();
}

class _ImportarEstudiantes extends State<ImportarEstudiantes> {
  String _statusMessage = '';

  Future<void> _importarEstudiantesDeCsv() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        Uint8List? fileBytes;

        if (result.files.first.bytes != null) {
          fileBytes = result.files.first.bytes;
        } else if (!kIsWeb && result.files.first.path != null) {
          final file = File(result.files.first.path!);
          fileBytes = await file.readAsBytes();
        }

        if (fileBytes != null) {
          final csvContent = utf8.decode(fileBytes);
          List<String> rows = csvContent.split('\n');
          StringBuffer errorMessages = StringBuffer();
          bool allImportsSuccessful = true;

          // Validación y registro
          for (int i = 1; i < rows.length; i++) {
            if (rows[i].trim().isEmpty) continue;

            List<String> row = rows[i].split(',');
            if (row.length < 7 || row.any((field) => field.trim().isEmpty)) {
              errorMessages.writeln("Fila ${i + 1}: campos vacíos.");
              allImportsSuccessful = false;
              continue;
            }

            String matricula = row[0].trim();
            String idDocumento =
                matricula.length == 5 ? '0$matricula' : matricula;
            String nombre = row[1].trim();
            String primerApellido = row[2].trim();
            String segundoApellido = row[3].trim();
            String correo = row[4].trim();
            String telefono = row[5].trim();
            String carrera = row[6].trim();

            // Verificar si el estudiante ya existe en Firestore
            var estudianteDoc = await FirebaseFirestore.instance
                .collection('students')
                .doc(idDocumento)
                .get();

            if (!estudianteDoc.exists) {
              try {
                await FirebaseFirestore.instance
                    .collection('students')
                    .doc(idDocumento)
                    .set({
                  'nombre': nombre,
                  'primerApellido': primerApellido,
                  'segundoApellido': segundoApellido,
                  'correo': correo,
                  'matricula': matricula,
                  'telefono': telefono,
                  'carrera': carrera,
                });

                // Verificar si el correo ya existe en Firebase Authentication
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: correo,
                    password: idDocumento,
                  );
                } on FirebaseAuthException catch (authError) {
                  if (authError.code == 'email-already-in-use') {
                    errorMessages.writeln(
                        "Fila ${i + 1}: El correo ya está en uso en otra cuenta.");
                    allImportsSuccessful = false;
                  } else {
                    errorMessages.writeln(
                        "Fila ${i + 1}: Error al crear usuario - ${authError.message}");
                    allImportsSuccessful = false;
                  }
                }
              } catch (e) {
                errorMessages.writeln(
                    "Fila ${i + 1}: Error al registrar estudiante - $e");
                allImportsSuccessful = false;
              }
            } else {
              errorMessages.writeln(
                  "Fila ${i + 1}: La matrícula ya está registrada.");
              allImportsSuccessful = false;
            }

            // Agregar un retraso entre solicitudes para evitar bloqueos por actividad inusual
            await Future.delayed(Duration(milliseconds: 1000));
          }

          // Mostrar mensaje de éxito o error
          setState(() {
            _statusMessage = allImportsSuccessful
                ? 'Estudiantes importados exitosamente.'
                : 'Errores encontrados:\n$errorMessages';
          });
        }
      } else {
        setState(() {
          _statusMessage = 'No se seleccionó ningún archivo.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al importar estudiantes: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Importar Estudiantes desde CSV'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _importarEstudiantesDeCsv,
              child: Text('Seleccionar archivo CSV e importar'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _statusMessage.contains('Error')
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
