import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit/profesor/login_profesor.dart';
import 'perfil_profesor.dart';
import 'package:fit/generales/actividades.dart';
import '../../generales/seleccionar_actividad.dart';

class HomeProfesor extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String teacherName;
  final String teacherId;
  final String teacherFirstLastname;
  final String teacherSecondLastname;
  final String teacherEmail;
  final String teacherPhone;

  HomeProfesor({
    required this.teacherName,
    required this.teacherId,
    required this.teacherFirstLastname,
    required this.teacherSecondLastname,
    required this.teacherEmail,
    required this.teacherPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido Profesor'),
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
          '¡Bienvenido, $teacherName!',
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
                  'Profesor',
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '$teacherName',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                Text(
                  'ID: $teacherId',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person, 'Perfil', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PerfilProfesor(
                  teacherName: teacherName,
                  teacherId: teacherId,
                  teacherFirstLastname: teacherFirstLastname,
                  teacherSecondLastname: teacherSecondLastname,
                  teacherEmail: teacherEmail,
                  teacherPhone: teacherPhone,
                ),
              ),
            );
          }),
          _buildDrawerItem(Icons.event, 'Actividades', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Actividades()));
          }),
          _buildDrawerItem(Icons.app_registration, 'Registrar Participación', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SeleccionarActividad()));
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
                Navigator.of(context).pop();
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
      MaterialPageRoute(builder: (context) => LoginProfesor()),
      (Route<dynamic> route) => false,
    );
  }
}
