import 'package:fit/admin/avance.dart';
import 'package:fit/admin/ver_evidencias.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_admin.dart';
import 'profile_admin.dart';
import '../../generales/actividades.dart';
import 'gestionar_usuarios.dart';
import 'gestionar_activities.dart';
import 'solicitudes_constancias.dart';
import '../../generales/seleccionar_actividad.dart';

class HomeAdmin extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String adminName;
  final String adminId;
  final String adminFirstLastname;
  final String adminSecondLastname;
  final String adminEmail;
  final String adminPhone;

  HomeAdmin({
    required this.adminName,
    required this.adminId,
    required this.adminFirstLastname,
    required this.adminSecondLastname,
    required this.adminEmail,
    required this.adminPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido $adminName'),
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
          '¡Bienvenido, $adminName!',
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
                  'Administrador',
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  '$adminName',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                Text(
                  'ID: $adminId',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.person, 'Perfil', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileAdmin(
                  adminName: adminName,
                  adminId: adminId,
                  adminFirstLastname: adminFirstLastname,
                  adminSecondLastname: adminSecondLastname,
                  adminEmail: adminEmail,
                  adminPhone: adminPhone,
                ),
              ),
            );
          }),
          _buildDrawerItem(Icons.event, 'Actividades', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Actividades()));
          }),
          _buildDrawerItem(Icons.group, 'Gestionar Usuarios', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => GestionarUsuarios()));
          }),
          _buildDrawerItem(Icons.assignment, 'Gestionar Actividades', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => GestionarActivities(adminId: adminId)));
          }),
          _buildDrawerItem(Icons.app_registration, 'Registrar', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SeleccionarActividad()));
          }),
          _buildDrawerItem(Icons.bar_chart, 'Avance', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Avance()));
          }),
          _buildDrawerItem(Icons.assignment_turned_in, 'Solicitudes', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => VerSolicitudesConstancia()));
          }),
          _buildDrawerItem(Icons.image, 'Ver Evidencias', (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>VerEvidencias()));
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

  // Método para cerrar sesión y redirigir al login
  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginAdmin()),
      (Route<dynamic> route) => false,
    );
  }
}
