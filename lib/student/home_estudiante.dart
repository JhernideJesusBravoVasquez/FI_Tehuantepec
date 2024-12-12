import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'perfil_estudiante.dart'; 
import 'package:fit/generales/actividades.dart';
import 'inscribirse_actividad.dart';
import 'avance_estudiante.dart';
import 'solicitar_constancia.dart';
import 'student_login.dart';
import 'evidencias.dart';

class HomeEstudiante extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String studentName;
  final String studentMatricula;
  final String studentFirstLastname;
  final String studentSecondLastname;
  final String studentEmail;
  final String studentPhone;
  final String studentCarrera;

  HomeEstudiante({
    required this.studentMatricula,
    required this.studentName,
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
        title: Text('Bienvenido Estudiante'),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: _buildDrawer(context),
      body: Center(
        child: Text(
          '¡Bienvenido, $studentName!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Método para construir el Drawer
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estudiante',
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '$studentName',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                Text(
                  'Matrícula: $studentMatricula',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person, 'Perfil', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PerfilEstudiante(
                  studentName: studentName,
                  studentMatricula: studentMatricula,
                  studentFirstLastname: studentFirstLastname,
                  studentSecondLastname: studentSecondLastname,
                  studentEmail: studentEmail,
                  studentPhone: studentPhone,
                  studentCarrera: studentCarrera,
                ),
              ),
            );
          }),
          _buildDrawerItem(Icons.event, 'Actividades', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Actividades()));
          }),
          _buildDrawerItem(Icons.app_registration, 'Inscribirse', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InscribirseActividad(
                  studentMatricula: studentMatricula,
                  studentName: studentName,
                  studentFirstLastname: studentFirstLastname,
                  studentSecondLastname: studentSecondLastname,),
              ),
            );
          }),
          _buildDrawerItem(Icons.assignment, 'Avance', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AvanceEstudiante(studentMatricula: studentMatricula),
              ),
            );
          }),
          _buildDrawerItem(Icons.school, 'Solicitar Constancia', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SolicitarConstancia(studentMatricula: studentMatricula),
              ),
            );
          }),
          _buildDrawerItem(Icons.image, 'Evidencias',(){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Evidencias(studentMatricula: studentMatricula))
              );
          }),
          Divider(),
          _buildDrawerItem(Icons.logout, 'Cerrar Sesión', () {
            _showLogoutConfirmation(context);
          }),
        ],
      ),
    );
  }

  // Método para crear elementos del Drawer
  ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  // Método para mostrar una alerta de confirmación de cierre de sesión
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
              },
            ),
            TextButton(
              child: Text('Cerrar Sesión'),
              onPressed: () {
                _signOut(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Método para cerrar sesión en Firebase
  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => StudentLoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}
