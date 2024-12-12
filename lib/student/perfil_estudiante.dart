import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PerfilEstudiante extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String studentName;
  final String studentMatricula;
  final String studentFirstLastname;
  final String studentSecondLastname;
  final String studentEmail;
  final String studentPhone;
  final String studentCarrera;

  PerfilEstudiante({
    required this.studentName,
    required this.studentMatricula,
    required this.studentFirstLastname,
    required this.studentSecondLastname,
    required this.studentEmail,
    required this.studentPhone,
    required this.studentCarrera,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información del Estudiante',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildInfoCard('Nombre', studentName),
              SizedBox(height: 10),
              _buildInfoCard('Primer Apellido', studentFirstLastname),
              SizedBox(height: 10),
              _buildInfoCard('Segundo Apellido', studentSecondLastname),
              SizedBox(height: 10),
              _buildInfoCard('Matrícula', studentMatricula),
              SizedBox(height: 10),
              _buildInfoCard('Carrera', studentCarrera),
              SizedBox(height: 10),
              _buildInfoCard('Correo', studentEmail),
              SizedBox(height: 10),
              _buildInfoCard('Teléfono', studentPhone),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (value.length > 30) {
                    // Si el texto es demasiado largo, se muestra en múltiples líneas
                    return Text(
                      value,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    );
                  } else {
                    // Si el texto es corto, se muestra en una sola línea con puntos suspensivos
                    return Text(
                      value,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
