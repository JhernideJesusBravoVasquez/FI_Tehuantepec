import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'modificar_actividad.dart';
import 'crear_actividad.dart';
import 'participaciones.dart'; // Importa la ventana de participantes

class GestionarActivities extends StatefulWidget {

  final String adminId;

  GestionarActivities({
    required this.adminId
  });
  @override
  _BuscarActividadPageState createState() => _BuscarActividadPageState();
}

class _BuscarActividadPageState extends State<GestionarActivities> {
  final TextEditingController _idController = TextEditingController();
  List<Map<String, dynamic>> _actividadesEncontradas = [];
  Map<String, dynamic>? actividad;
  String _resultado = '';

  Future<void> _buscarActividadPorId() async {
  String idActividadParcial = _idController.text.trim();

  if (idActividadParcial.isEmpty) {
    setState(() {
      _resultado = 'Por favor, ingresa un texto para buscar.';
      actividad = null;
    });
    return;
  }

  try {
    QuerySnapshot actividadesSnapshot = await FirebaseFirestore.instance
        .collection('activities')
        .where('idActividad', isGreaterThanOrEqualTo: idActividadParcial)
        .where('idActividad', isLessThan: '$idActividadParcial~') // "~" asegura que solo incluya IDs que comiencen con el texto ingresado
        .get();

    if (actividadesSnapshot.docs.isEmpty) {
      setState(() {
        _resultado = 'No se encontraron actividades que coincidan con el texto ingresado.';
        actividad = null;
      });
    } else {
      setState(() {
        actividad = null; // Limpia la actividad específica anterior
        _resultado = ''; // Limpia cualquier mensaje anterior
      });

      // Mostrar todas las actividades que coinciden
      _actividadesEncontradas = actividadesSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    }
  } catch (e) {
    setState(() {
      _resultado = 'Error al buscar actividades: $e';
      actividad = null;
    });
  }
}



  String _formatearFechaHora(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime dateTime = timestamp.toDate();
    String formattedDate = '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String formattedTime = '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
    return '$formattedDate - $formattedTime';
  }

  void _verActividad(Map<String, dynamic> actividad) async {
  bool? wasDeleted = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ModificarActividad(
        actividadId: actividad['idActividad'],
        actividadData: actividad,
        onDelete: () {
          setState(() {
            _actividadesEncontradas.remove(actividad);
          });
        },
      ),
    ),
  );

  if (wasDeleted == true) {
    setState(() {
      _actividadesEncontradas.remove(actividad);
    });
  }
}


  void _verParticipantes(String idActividad) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Participaciones(
        idActividad: idActividad,
      ),
    ),
  );
}


  void _crearNuevaActividad() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearActividad(
          adminId: widget.adminId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Actividad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'ID de la Actividad'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _buscarActividadPorId,
              child: Text('Buscar'),
            ),
            SizedBox(height: 16),
            Text(_resultado),
            SizedBox(height: 16),
            
            _actividadesEncontradas.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: _actividadesEncontradas.length,
                    itemBuilder: (context, index) {
                      var actividad = _actividadesEncontradas[index];
                      return Card(
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
                              Text('Categoría: ${actividad['categoria'] ?? 'N/A'}'),
                              Text('Valor: ${actividad['valor'] ?? 'N/A'} horas'),
                              Text('Estado: ${actividad['estado'] ?? 'N/A'}'),
                              Text('Lugar: ${actividad['lugar'] ?? 'N/A'}'),
                              Text('ID: ${actividad['idActividad'] ?? 'N/A'}'),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _verActividad(actividad),
                                child: Text('Ver'),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _verParticipantes(actividad['idActividad']),
                                child: Text('Participaciones'), // Botón para ver participantes
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
            :SizedBox(height: 16),
            ElevatedButton(
              onPressed: _crearNuevaActividad,
              child: Text('Crear Nueva Actividad'),
            ),
          ],
        ),
      ),
    );
  }
}
