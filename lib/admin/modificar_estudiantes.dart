import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ModificarEstudiantes extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> documentData;
  final VoidCallback onDelete;

  ModificarEstudiantes({required this.documentId, required this.documentData, required this.onDelete});

  @override
  _ModificarEstudiantesState createState() => _ModificarEstudiantesState();
}

class _ModificarEstudiantesState extends State<ModificarEstudiantes> {
  late TextEditingController _nombreController;
  late TextEditingController _primerApellidoController;
  late TextEditingController _segundoApellidoController;
  late TextEditingController _matriculaController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;

  String? _selectedCarrera;
  final _formKey = GlobalKey<FormState>();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.documentData['nombre']);
    _primerApellidoController = TextEditingController(text: widget.documentData['primerApellido']);
    _segundoApellidoController = TextEditingController(text: widget.documentData['segundoApellido']);
    _matriculaController = TextEditingController(text: widget.documentData['matricula']);
    _correoController = TextEditingController(text: widget.documentData['correo']);
    _telefonoController = TextEditingController(text: widget.documentData['telefono']);
    _selectedCarrera = widget.documentData['carrera'];
  }

  bool _isValidEmail(String email) {
    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  Future<void> updateDocument() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await FirebaseFirestore.instance.collection('students').doc(widget.documentId).update({
        'nombre': _nombreController.text.trim(),
        'primerApellido': _primerApellidoController.text.trim(),
        'segundoApellido': _segundoApellidoController.text.trim(),
        'matricula': _matriculaController.text.trim(),
        'correo': _correoController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'carrera': _selectedCarrera,
      });

      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Documento actualizado exitosamente')),
      );

      // Regresar a la ventana de "Gestionar Usuarios"
      Navigator.of(context).pop(); // Cierra la ventana actual y regresa a la anterior
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el documento: $e')),
      );
    }
  }

  Future<void> eliminarDocumento() async{
    try{
      await FirebaseFirestore.instance.collection('students').doc(widget.documentId).delete();

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
          content: Text('¿Estás seguro de que deseas eliminar a este estudiante? Esta acción no se puede deshacer.'),
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
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Modificar Estudiante'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: keyboardOpen ? 20 : size.height * 0.1),

                // Matrícula
                TextFormField(
                  controller: _matriculaController,
                  decoration: InputDecoration(labelText: 'Matrícula'),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 6) {
                      return 'La matrícula debe tener 6 dígitos';
                    }
                    return null;
                  },
                ),

                // Nombre
                TextFormField(
                  controller: _nombreController,
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
                  controller: _primerApellidoController,
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
                  controller: _segundoApellidoController,
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
                  controller: _correoController,
                  decoration: InputDecoration(labelText: 'Correo'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !_isValidEmail(value)) {
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
                      return 'El teléfono debe tener 10 dígitos';
                    }
                    return null;
                  },
                ),

                // Dropdown para la carrera
                DropdownButtonFormField<String>(
                  value: _selectedCarrera,
                  hint: Text('Carrera'),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecciona una carrera';
                    }
                    return null;
                  },
                ),

                SizedBox(height: size.height * 0.02),

                // Botón para guardar cambios
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
