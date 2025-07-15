import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../services/firebase_service.dart';

class QRGeneratorScreen extends StatefulWidget {
  final String tipo; // 'lote', 'caja', 'pallet'
  final String id;
  final String titulo;
  final Map<String, dynamic> datos;

  const QRGeneratorScreen({
    super.key,
    required this.tipo,
    required this.id,
    required this.titulo,
    required this.datos,
  });

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  bool _isSaving = false;
  String? _savedQRUrl;

  @override
  void initState() {
    super.initState();
    _checkExistingQR();
  }

  Future<void> _checkExistingQR() async {
    try {
      final qrData = await FirebaseService.getQRCodeData(widget.id);
      if (mounted) {
        setState(() {
          _savedQRUrl = qrData != null ? 'saved' : null;
        });
      }
    } catch (e) {
      // QR no existe aún
    }
  }

  String _generateQRData() {
    // Simplificar el QR para que solo contenga el ID del lote
    // Esto hace que sea más fácil de escanear y más rápido
    return jsonEncode({
      'tipo': widget.tipo,
      'id': widget.id,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _saveQRToStorage() async {
    if (_savedQRUrl != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este QR ya está guardado'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Generar datos del QR
      final qrData = _generateQRData();
      
      // Guardar solo los datos del QR en Firestore
      final qrId = await FirebaseService.saveQRCode(widget.id, qrData);
      
      if (mounted) {
        setState(() {
          _savedQRUrl = qrId; // Ahora guardamos el ID del documento
          _isSaving = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar QR: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPrintOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Opciones de impresión',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Imprimir QR'),
              subtitle: const Text('Enviar a impresora'),
              onTap: () {
                Navigator.pop(context);
                _printQR();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartir QR'),
              subtitle: const Text('Enviar por WhatsApp, email, etc.'),
              onTap: () {
                Navigator.pop(context);
                _shareQR();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Descargar PDF'),
              subtitle: const Text('Generar documento PDF'),
              onTap: () {
                Navigator.pop(context);
                _generatePDF();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _printQR() {
    // TODO: Implementar impresión
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de impresión en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _shareQR() {
    // TODO: Implementar compartir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de compartir en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _generatePDF() {
    // TODO: Implementar generación de PDF
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de PDF en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrData = _generateQRData();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _savedQRUrl != null ? _showPrintOptions : null,
          ),
          if (_savedQRUrl != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareQR,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información del QR
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del ${widget.tipo.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('ID: ${widget.id}'),
                    Text('Tipo: ${widget.tipo}'),
                    Text('Título: ${widget.titulo}'),
                    const SizedBox(height: 8),
                    const Text(
                      'Datos del QR:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        qrData,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Código QR
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Código QR',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 250,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Botón de guardar
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveQRToStorage,
              icon: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
              label: Text(_isSaving ? 'Guardando...' : 'Guardar QR'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: _savedQRUrl != null ? Colors.blue : Colors.green,
              ),
            ),
            
            if (_savedQRUrl != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'QR guardado exitosamente',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/qr-library'),
                      child: const Text('Ver en Biblioteca'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 