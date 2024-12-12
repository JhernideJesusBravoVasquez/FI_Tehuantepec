import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvanceEstudiante extends StatefulWidget {
  final String studentMatricula;

  AvanceEstudiante({required this.studentMatricula});

  @override
  _AvanceEstudianteState createState() => _AvanceEstudianteState();
}

class _AvanceEstudianteState extends State<AvanceEstudiante> {
  List<Map<String, dynamic>> _actividadesParticipadas = [];
  List<Map<String, dynamic>> _actividadesFiltradas = [];
  String _mensaje = '';
  String _categoriaSeleccionada = 'Todas';
  int _progresoTotal = 0;
  int _progresoCategoria = 0;

  static const int LIMITE_TOTAL = 200;
  static const int LIMITE_ACADEMICO = 80;
  static const int LIMITE_CULTURAL = 60;
  static const int LIMITE_DEPORTIVO = 60;

  @override
  void initState() {
    super.initState();
    _cargarActividadesParticipadas();
  }

  Future<void> _cargarActividadesParticipadas() async {
    try {
      QuerySnapshot participacionesSnapshot = await FirebaseFirestore.instance
          .collection('participaciones')
          .where('matricula', isEqualTo: widget.studentMatricula)
          .get();

      if (participacionesSnapshot.docs.isEmpty) {
        setState(() {
          _mensaje = 'No has participado en ninguna actividad.';
          _progresoTotal = 0;
          _progresoCategoria = 0;
        });
      } else {
        List<Map<String, dynamic>> actividades = [];

        for (var doc in participacionesSnapshot.docs) {
          String idActividad = doc['idActividad'];

          DocumentSnapshot actividadSnapshot = await FirebaseFirestore.instance
              .collection('activities')
              .doc(idActividad)
              .get();

          if (actividadSnapshot.exists) {
            Map<String, dynamic> actividadData =
                actividadSnapshot.data() as Map<String, dynamic>;
            actividades.add(actividadData);
          }
        }

        setState(() {
          _actividadesParticipadas = actividades;
          _aplicarFiltro(); // Aplicar filtro inicial
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error al cargar las actividades: $e';
      });
    }
  }
  int _obtenerLimitePorCategoria(String categoria) {
    switch (categoria) {
      case 'Academica':
        return LIMITE_ACADEMICO;
      case 'Cultural':
        return LIMITE_CULTURAL;
      case 'Deportiva':
        return LIMITE_DEPORTIVO;
      default:
        return LIMITE_TOTAL; // Para "Todas"
    }
  }

  // Función para filtrar y calcular el progreso según la categoría seleccionada
  void _aplicarFiltro() {
    if (_categoriaSeleccionada == 'Todas') {
      _actividadesFiltradas = _actividadesParticipadas;
    } else {
      _actividadesFiltradas = _actividadesParticipadas
          .where((actividad) => actividad['categoria'] == _categoriaSeleccionada.toLowerCase())
          .toList();
    }

    // Calcular el progreso total
    int sumaValoresTotal = _actividadesParticipadas.fold(
      0,
      (sum, actividad) => sum + (actividad['valor'] as int? ?? 0),
    );

    // Calcular el progreso por categoría
    int sumaValoresCategoria = _actividadesFiltradas.fold(
      0,
      (sum, actividad) => sum + (actividad['valor'] as int? ?? 0),
    );

    // Mensajes de advertencia si se alcanza algún límite
    String mensajeAdvertencia = '';
    int limiteCategoria = _obtenerLimitePorCategoria(_categoriaSeleccionada);
    if (sumaValoresTotal >= LIMITE_TOTAL) {
      mensajeAdvertencia = '¡Has alcanzado el límite total de $LIMITE_TOTAL horas!';
    } else if (_categoriaSeleccionada != 'Todas' && sumaValoresCategoria >= limiteCategoria) {
      mensajeAdvertencia =
          '¡Has alcanzado el límite de $limiteCategoria horas en la categoría $_categoriaSeleccionada!';
    }

    setState(() {
      _mensaje = _actividadesFiltradas.isEmpty
          ? 'No se encontraron actividades en la categoría seleccionada.'
          : mensajeAdvertencia;
      _progresoTotal = sumaValoresTotal;
      _progresoCategoria = sumaValoresCategoria;
    });
  }

  // Función para formatear fecha y hora desde el timestamp
  String _formatearFechaHora(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime dateTime = timestamp.toDate();
    String formattedDate = '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String formattedTime = '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
    return '$formattedDate - $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avance Personal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Mostrar progreso total y/o por categoría
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Progreso Total: $_progresoTotal / $LIMITE_TOTAL horas',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Mostrar progreso por categoría solo si se selecciona una categoría específica
                  if (_categoriaSeleccionada != 'Todas')
                    Text(
                      'Progreso en $_categoriaSeleccionada: $_progresoCategoria / ${_obtenerLimitePorCategoria(_categoriaSeleccionada)} horas',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Dropdown para seleccionar la categoría
            DropdownButton<String>(
              value: _categoriaSeleccionada,
              onChanged: (String? nuevaCategoria) {
                setState(() {
                  _categoriaSeleccionada = nuevaCategoria!;
                  _aplicarFiltro(); // Aplicar el filtro al cambiar la categoría
                });
              },
              items: ['Todas', 'Cultural', 'Academica', 'Deportiva']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            _actividadesFiltradas.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: _actividadesFiltradas.length,
                      itemBuilder: (context, index) {
                        var actividad = _actividadesFiltradas[index];
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nombre: ${actividad['nombre'] ?? 'N/A'}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Fecha y Hora: ${_formatearFechaHora(actividad['fechaHora'])}',
                                ),
                                Text(
                                  'Categoría: ${actividad['categoria'] ?? 'N/A'}',
                                ),
                                Text(
                                  'Valor: ${actividad['valor'] ?? 'N/A'} horas',
                                ),
                                Text(
                                  'Lugar: ${actividad['lugar'] ?? 'N/A'}',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      _mensaje.isNotEmpty ? _mensaje : 'Cargando...',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
