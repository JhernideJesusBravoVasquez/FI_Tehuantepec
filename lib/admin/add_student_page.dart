import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'importar_estudiantes.dart';
import 'package:flutter/services.dart';

class AddStudentPage extends StatefulWidget {
  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstLastController = TextEditingController();
  final TextEditingController _secondLastController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedCarrera;
  final _formKey = GlobalKey<FormState>();

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String matricula = _matriculaController.text.trim();
    String idDocumento = matricula.length == 5 ? '0$matricula' : matricula;
    String nombre = _nameController.text.trim();
    String primerApellido = _firstLastController.text.trim();
    String segundoApellido = _secondLastController.text.trim();
    String email = _emailController.text.trim();
    String telefono = _phoneController.text.trim();

    try {
      var studentDoc = await FirebaseFirestore.instance.collection('students').doc(idDocumento).get();

      if (studentDoc.exists) {
        _showErrorDialog('La matrícula ya está registrada.');
      } else {
        await FirebaseFirestore.instance.collection('students').doc(idDocumento).set({
          'nombre': nombre,
          'primerApellido': primerApellido,
          'segundoApellido': segundoApellido,
          'correo': email,
          'matricula': matricula,
          'telefono': telefono,
          'carrera': _selectedCarrera,
        });

        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: idDocumento,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estudiante agregado exitosamente')),
        );

        _clearFields();
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog('Error al crear cuenta: ${e.message}');
    } catch (e) {
      _showErrorDialog('Error al agregar estudiante: $e');
    }
  }

  void _clearFields() {
    _nameController.clear();
    _firstLastController.clear();
    _secondLastController.clear();
    _emailController.clear();
    _matriculaController.clear();
    _phoneController.clear();
    setState(() {
      _selectedCarrera = null;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Estudiante'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: keyboardOpen ? 20 : size.height * 0.1),
                TextFormField(
  controller: _matriculaController,
  decoration: InputDecoration(labelText: 'Matrícula'),
  keyboardType: TextInputType.number,
  maxLength: 6,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
  ],
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa la matrícula';
    }
    if (value.length < 5 || value.length > 6) {
      return 'La matrícula debe tener 5 o 6 dígitos';
    }
    return null;
  },
),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZñÑáéíóúÁÉÍÓÚ\s]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa el nombre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _firstLastController,
                  decoration: InputDecoration(labelText: 'Primer Apellido'),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZñÑáéíóúÁÉÍÓÚ\s]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa el primer apellido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _secondLastController,
                  decoration: InputDecoration(labelText: 'Segundo Apellido'),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZñÑáéíóúÁÉÍÓÚ\s]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa el segundo apellido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Correo electrónico'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa el correo';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Por favor, ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10)
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                DropdownButton<String>(
                  hint: Text("Carrera"),
                  value: _selectedCarrera,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCarrera = newValue;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'Lic. en Enseñanza de Idiomas',
                      child: Text('Lic. en Enseñanza de Idiomas'),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
            SizedBox(
              width: 200,
              height: 40,
              child: ElevatedButton(
                onPressed: _addStudent,
                child: Text('Guardar Estudiante'),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            SizedBox(
              width: 200,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ImportarEstudiantes()),
                  );
                },
                child: Text('Importar Estudiantes'),
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
