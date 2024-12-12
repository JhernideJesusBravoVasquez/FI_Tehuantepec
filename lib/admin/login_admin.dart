import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_admin.dart';
import '../main.dart';
import 'package:flutter/services.dart';

class LoginAdmin extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginAdmin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login Administrativo'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Campo para ingresar el correo electrónico
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            SizedBox(height: size.height * 0.02),

            // Campo para ingresar el ID del administrador (solo alfanumérico)
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'CURP',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              obscureText: _obscureText,
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+$')),
              ],
            ),
            SizedBox(height: size.height * 0.04),

            _isLoading
                ? CircularProgressIndicator()
                : SizedBox(
                    width: 200,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _loginWithEmailAndId,
                      child: Text('Iniciar Sesión'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Método para realizar login con Firebase usando correo e ID
  void _loginWithEmailAndId() async {
    String email = _emailController.text.trim();
    String id = _passwordController.text.trim();

    // Validar que los campos no estén vacíos antes de proceder
    if (email.isEmpty || id.isEmpty) {
      _showErrorDialog('Por favor, completa todos los campos.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verifica si el administrador existe en Firestore
      var adminDoc = await _firestore.collection('admin').doc(id).get();

      if (adminDoc.exists && adminDoc.data()?['correo'] == email) {
        // Si el administrador existe y el correo coincide, obtener la información
        String adminId = adminDoc.data()?['id'];
        String adminName = adminDoc.data()?['nombre'];
        String adminFirstLastname = adminDoc.data()?['primerApellido'];
        String adminSecondLastname = adminDoc.data()?['segundoApellido'];
        String adminEmail = adminDoc.data()?['correo'];
        String adminPhone = adminDoc.data()?['telefono'];

        // Iniciar sesión con Firebase
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: id,
        );

        // Navegar a la página de bienvenida del administrador
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeAdmin(
              adminName: adminName,
              adminId: adminId,
              adminFirstLastname: adminFirstLastname,
              adminSecondLastname: adminSecondLastname,
              adminEmail: adminEmail,
              adminPhone: adminPhone,
            ),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Correo o ID incorrectos.');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.message ?? 'Error desconocido');
    }
  }

  // Método para mostrar un cuadro de diálogo de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error de autenticación'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
