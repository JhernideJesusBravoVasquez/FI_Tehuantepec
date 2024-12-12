import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerEvidencias extends StatefulWidget {
  @override
  _AdminEvidenciasPageState createState() => _AdminEvidenciasPageState();
}

class _AdminEvidenciasPageState extends State<VerEvidencias> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener evidencias desde Firestore agrupadas por estudiante
  Future<Map<String, Map<String, List<String>>>> _getEvidencias() async {
    QuerySnapshot snapshot = await _firestore.collection('evidencias').get();

    Map<String, Map<String, List<String>>> groupedEvidencias = {};
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String idActividad = data['idActividad'];
      String matricula = data['matricula'];
      String url = data['url'];

      if (!groupedEvidencias.containsKey(idActividad)) {
        groupedEvidencias[idActividad] = {};
      }

      if (!groupedEvidencias[idActividad]!.containsKey(matricula)) {
        groupedEvidencias[idActividad]![matricula] = [];
      }

      groupedEvidencias[idActividad]![matricula]!.add(url);
    }

    return groupedEvidencias;
  }

  Future<Map<String, String>> _getEstudianteDetalles(String matricula) async {
    try {
      var docSnapshot = await _firestore.collection('students').doc(matricula).get();
      if (docSnapshot.exists) {
        var estudiante = docSnapshot.data() as Map<String, dynamic>;
        return {
          'nombre': estudiante['nombre'] ?? 'Nombre no disponible',
          'primerApellido': estudiante['primerApellido'] ?? 'Primer apellido no disponible',
          'segundoApellido': estudiante['segundoApellido'] ?? 'Segundo apellido no disponible',
        };
      }
    } catch (e) {
      print('Error al obtener los detalles del estudiante: $e');
    }
    return {
      'nombre': 'Estudiante no encontrado',
      'primerApellido': 'No disponible',
      'segundoApellido': 'No disponible',
    };
  }

  // Mostrar imágenes deslizables en un cuadro de diálogo con flechas
  void _mostrarEvidencias(BuildContext context, List<String> evidencias) {
    int currentIndex = 0;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Stack(
                children: [
                  SizedBox(
                    height: 400,
                    child: Image.network(
                      evidencias[currentIndex],
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Flecha izquierda
                  if (currentIndex > 0)
                    Positioned(
                      left: 10,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, size: 30),
                        onPressed: () {
                          setState(() {
                            currentIndex--;
                          });
                        },
                      ),
                    ),
                  // Flecha derecha
                  if (currentIndex < evidencias.length - 1)
                    Positioned(
                      right: 10,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward_ios, size: 30),
                        onPressed: () {
                          setState(() {
                            currentIndex++;
                          });
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evidencias de Estudiantes'),
      ),
      body: FutureBuilder<Map<String, Map<String, List<String>>>>(
        future: _getEvidencias(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar evidencias'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay evidencias registradas'));
          } else {
            var evidencias = snapshot.data!;

            return ListView(
              children: evidencias.keys.map((idActividad) {
                return Card(
                  child: ExpansionTile(
                    title: Text('Actividad: $idActividad'),
                    children: evidencias[idActividad]!.keys.map((matricula) {
                      return FutureBuilder<Map<String, String>>(
                        future: _getEstudianteDetalles(matricula),
                        builder: (context, detallesSnapshot) {
                          if (detallesSnapshot.connectionState == ConnectionState.waiting) {
                            return ListTile(
                              title: Text('Cargando detalles...'),
                            );
                          } else if (detallesSnapshot.hasError) {
                            return ListTile(
                              title: Text('Error al obtener los detalles'),
                            );
                          } else {
                            var detalles = detallesSnapshot.data!;
                            String nombre = detalles['nombre'] ?? 'Nombre no disponible';
                            String primerApellido = detalles['primerApellido'] ?? 'Primer apellido no disponible';
                            String segundoApellido = detalles['segundoApellido'] ?? 'Segundo apellido no disponible';

                            return ListTile(
                              title: Text('$nombre $primerApellido $segundoApellido ($matricula)'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  // Mostrar las evidencias en un cuadro de diálogo con flechas
                                  _mostrarEvidencias(context, evidencias[idActividad]![matricula]!);
                                },
                                child: Text('Ver evidencias'),
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
