import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AgregarProfesor extends StatefulWidget {
  @override
  _AddTeacherPageState createState() => _AddTeacherPageState();
}

class _AddTeacherPageState extends State<AgregarProfesor> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstLastController = TextEditingController();
  final TextEditingController _secondLastController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _addTeacher() async {
    if (!_formKey.currentState!.validate()) {
      return; // Si el formulario no es válido, no proceder
    }

    String id = _idController.text.trim();
    String nombre = _nameController.text.trim();
    String primerApellido = _firstLastController.text.trim();
    String segundoApellido = _secondLastController.text.trim();
    String email = _emailController.text.trim();
    String telefono = _phoneController.text.trim();

    try {
      // Verificar si el profesor ya existe en Firestore
      var teacherDoc = await FirebaseFirestore.instance.collection('teacher').doc(id).get();

      if (teacherDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El ID ya está registrado')),
        );
      } else {
        // Registrar al profesor en Firestore
        await FirebaseFirestore.instance.collection('teacher').doc(id).set({
          'nombre': nombre,
          'primerApellido': primerApellido,
          'segundoApellido': segundoApellido,
          'correo': email,
          'id': id,
          'telefono': telefono,
        });

        // Crear el usuario en Firebase Authentication
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: id, // Usar ID como contraseña
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profesor agregado exitosamente')),
        );

        _clearFields();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar profesor: $e')),
      );
    }
  }

  // Limpiar los campos después de guardar
  void _clearFields() {
    _nameController.clear();
    _firstLastController.clear();
    _secondLastController.clear();
    _emailController.clear();
    _idController.clear();
    _phoneController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Profesor'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: size.height * 0.05),

                // ID
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(labelText: 'ID'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+$')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa el ID';
                    }
                    return null;
                  },
                ),

                // Nombre
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

                // Primer Apellido
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

                // Segundo Apellido
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

                // Correo
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

                // Teléfono
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 10) {
                      return 'Por favor, ingresa un teléfono válido';
                    }
                    return null;
                  },
                ),

                SizedBox(height: size.height * 0.03),

                // Botón para guardar
                ElevatedButton(
                  onPressed: _addTeacher,
                  child: Text('Guardar Profesor'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
