import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class Evidencias extends StatefulWidget {
  final String studentMatricula;

  Evidencias({required this.studentMatricula});

  @override
  _EvidenciasPageState createState() => _EvidenciasPageState();
}

class _EvidenciasPageState extends State<Evidencias> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Esta función obtiene las actividades del estudiante
  Future<List<Map<String, dynamic>>> _getFilteredActivities() async {
    QuerySnapshot participacionesSnapshot = await _firestore
        .collection('participaciones')
        .where('matricula', isEqualTo: widget.studentMatricula)
        .get();

    List<Map<String, dynamic>> activities = [];
    
    // Iteramos sobre las actividades del estudiante
    for (var doc in participacionesSnapshot.docs) {
      String idActividad = doc['idActividad'];
      var activityDoc = await _firestore.collection('activities').doc(idActividad).get();

      if (activityDoc.exists) {
        // Agregamos la actividad a la lista de actividades
        activities.add({
          'id': idActividad,
          'nombre': activityDoc['nombre'] ?? 'Sin nombre',
        });
      }
    }
    return activities;
  }

  // Función para subir la imagen
  Future<void> _uploadImage(String idActividad) async {
    Uint8List? fileBytes;

    // Detectar si estamos en web o móvil
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        fileBytes = result.files.single.bytes;
      }
    } else {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        fileBytes = await File(pickedFile.path).readAsBytes();
      }
    }

    if (fileBytes != null) {
      try {
        // Generar ruta del archivo con un ID único basado en timestamp
        String filePath =
            'evidencias/$idActividad/${widget.studentMatricula}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Subir la imagen
        UploadTask uploadTask = _storage.ref(filePath).putData(fileBytes);

        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Crear ID personalizado para el documento
        String documentId = '$idActividad-${widget.studentMatricula}-${DateTime.now().millisecondsSinceEpoch}';

        // Guardar URL de la evidencia en Firestore
        await _firestore.collection('evidencias').doc(documentId).set({
          'idActividad': idActividad,
          'matricula': widget.studentMatricula,
          'url': downloadUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Evidencia subida exitosamente')),
        );

        // Refrescar la lista después de subir la evidencia
        setState(() {}); // Refrescar la vista para permitir nuevas cargas
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir evidencia: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evidencias de Actividades'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getFilteredActivities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar actividades'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay actividades registradas'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var activity = snapshot.data![index];
                String activityId = activity['id'];
                String activityName = activity['nombre'];

                return Card(
                  child: ListTile(
                    title: Text(activityName),
                    subtitle: Text('Puede subir evidencias para esta actividad'),
                    trailing: ElevatedButton(
                      onPressed: () => _uploadImage(activityId),
                      child: Text('Subir Imagen'),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
