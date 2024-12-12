import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_estudiante.dart';
import '../main.dart';
import 'package:flutter/services.dart'; // Importa para usar inputFormatters

class StudentLoginPage extends StatefulWidget {
  @override
  _StudentLoginPageState createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login Estudiante'),
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
            // Campo de correo electrónico
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            SizedBox(height: size.height * 0.02),

            // Campo de matrícula (solo números)
            TextField(
              controller: _matriculaController,
              decoration: InputDecoration(
                labelText: 'Matrícula',
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
              keyboardType: TextInputType.number, // Establece el teclado numérico
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Permite solo números
              ],
            ),
            SizedBox(height: size.height * 0.04),

            _isLoading
                ? CircularProgressIndicator()
                : SizedBox(
                    width: 200,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _loginWithEmailAndMatricula,
                      child: Text('Iniciar Sesión'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Método para realizar login con Firebase usando correo y matrícula
  void _loginWithEmailAndMatricula() async {
    String email = _emailController.text.trim();
    String matricula = _matriculaController.text.trim();

    // Validar que los campos no estén vacíos antes de proceder
    if (email.isEmpty || matricula.isEmpty) {
      _showErrorDialog('Por favor, completa todos los campos.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var studentDoc = await _firestore.collection('students').doc(matricula).get();

      if (studentDoc.exists && studentDoc.data()?['correo'] == email) {
        String studentMatricula = studentDoc.data()?['matricula'];
        String studentName = studentDoc.data()?['nombre'];
        String studentFirstLastname = studentDoc.data()?['primerApellido'];
        String studentSecondLastname = studentDoc.data()?['segundoApellido'];
        String studentEmail = studentDoc.data()?['correo'];
        String studentPhone = studentDoc.data()?['telefono'];
        String studentCarrera = studentDoc.data()?['carrera'];

        await _auth.signInWithEmailAndPassword(
          email: email,
          password: matricula,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeEstudiante(
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
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Correo o matrícula incorrectos.');
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
