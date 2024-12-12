import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ModificarProfesor extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> documentData;
  String collectionName = 'teacher';
  final VoidCallback onDelete;

  ModificarProfesor({
    required this.documentId,
    required this.documentData,
    required this.collectionName,
    required this.onDelete
  });

  @override
  _ModificarProfesorState createState() => _ModificarProfesorState();
}

class _ModificarProfesorState extends State<ModificarProfesor> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _primerApellidoController = TextEditingController();
  final TextEditingController _segundoApellidoController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.documentData['nombre'] ?? '';
    _primerApellidoController.text = widget.documentData['primerApellido'] ?? '';
    _segundoApellidoController.text = widget.documentData['segundoApellido'] ?? '';
    _idController.text = widget.documentData['id'] ?? '';
    _correoController.text = widget.documentData['correo'] ?? '';
    _telefonoController.text = widget.documentData['telefono'] ?? '';
  }

  Future<void> updateDocument() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.documentId)
          .update({
        'nombre': _nombreController.text.trim(),
        'primerApellido': _primerApellidoController.text.trim(),
        'segundoApellido': _segundoApellidoController.text.trim(),
        'id': _idController.text.trim(),
        'correo': _correoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
      });

      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Información del profesor actualizada exitosamente')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el profesor: $e')),
      );
    }
  }

  Future<void> eliminarDocumento() async{
    try{
      await FirebaseFirestore.instance.collection('teacher').doc(widget.documentId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estudiante eliminado exitosamente')),
        );

        widget.onDelete();
        Navigator.of(context).pop();
    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el documento: $e')),
        );
    }
  }
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar a este profesor? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop();
                eliminarDocumento();
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Modificar Información del Profesor'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: size.height * 0.05),

                // ID
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(labelText: 'ID (Usado como contraseña)'),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+$'))],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa el ID';
                    }
                    return null;
                  },
                ),

                // Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZñÑáéíóúÁÉÍÓÚ\s]'))],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa el nombre';
                    }
                    return null;
                  },
                ),

                // Primer Apellido
                TextFormField(
                  controller: _primerApellidoController,
                  decoration: InputDecoration(labelText: 'Primer Apellido'),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZñÑáéíóúÁÉÍÓÚ\s]'))],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa el primer apellido';
                    }
                    return null;
                  },
                ),

                // Segundo Apellido
                TextFormField(
                  controller: _segundoApellidoController,
                  decoration: InputDecoration(labelText: 'Segundo Apellido'),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZñÑáéíóúÁÉÍÓÚ\s]'))],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa el segundo apellido';
                    }
                    return null;
                  },
                ),

                // Correo
                TextFormField(
                  controller: _correoController,
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
                  controller: _telefonoController,
                  decoration: InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 10) {
                      return 'Por favor, ingresa un teléfono válido';
                    }
                    return null;
                  },
                ),

                SizedBox(height: size.height * 0.03),

                // Botón de guardar
                _isUpdating
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: updateDocument,
                        child: Text('Guardar Cambios'),
                      ),
                      SizedBox(height: size.height * 0.02),
                // Botón para eliminar estudiante
                ElevatedButton(
                  onPressed: _showDeleteConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Eliminar Estudiante'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
