import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:barcode_widget/barcode_widget.dart';

class InscribirseActividad extends StatefulWidget {
  final String studentMatricula;
  final String studentName;
  final String studentFirstLastname;
  final String studentSecondLastname;

  InscribirseActividad({
    required this.studentMatricula,
    required this.studentName,
    required this.studentFirstLastname,
    required this.studentSecondLastname});

  @override
  _QRMatriculaPageState createState() => _QRMatriculaPageState();
}

class _QRMatriculaPageState extends State<InscribirseActividad> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Personal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${widget.studentName}' ' ' '${widget.studentFirstLastname}' ' ' '${widget.studentSecondLastname}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Uso de BarcodeWidget para generar el QR
            BarcodeWidget(
              barcode: Barcode.qrCode(), // Genera un código QR
              data: widget.studentMatricula, // Genera el QR con la matrícula
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              'Matrícula: ${widget.studentMatricula}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
