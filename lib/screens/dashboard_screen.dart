import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/trazability_models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;
  List<Lote> _lotes = [];
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLotes();
  }

  Future<void> _loadLotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final lotes = await FirebaseService.getLotes();
      setState(() {
        _lotes = lotes;
        _statusMessage = 'Lotes cargados: ${lotes.length}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al cargar lotes: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestLote() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Creando lote de prueba...';
    });

    try {
      // Crear un lote de prueba usando el constructor factory
      final testLote = Lote.nuevo(
        productor: 'Agricultor de Prueba',
        ubicacion: 'Piura, Perú',
        variedad: 'Kent',
        fechaCosecha: DateTime.now(),
        condicionesClimaticas: {
          'temperatura': '28°C',
          'humedad': '65%',
          'viento': 'Suave'
        },
        coordenadasGPS: '-5.1945, -80.6328',
        estado: 'cosechado',
      );

      final loteId = await FirebaseService.createLote(testLote);
      
      setState(() {
        _statusMessage = '✅ Lote creado exitosamente! ID: $loteId';
      });

      // Recargar la lista
      await _loadLotes();
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error al crear lote: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testFirestoreConnection() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Probando conexión con Firestore...';
    });

    try {
      // Intentar escribir un documento de prueba
      await FirebaseFirestore.instance
          .collection('test')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Conexión exitosa desde Flutter',
      });

      setState(() {
        _statusMessage = '✅ Conexión con Firestore exitosa!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error de conexión: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - Pruebas Firebase'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: _statusMessage.contains('✅') 
                  ? Colors.green.shade50 
                  : _statusMessage.contains('❌') 
                      ? Colors.red.shade50 
                      : Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado de la conexión:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _statusMessage.contains('✅') 
                            ? Colors.green.shade800 
                            : _statusMessage.contains('❌') 
                                ? Colors.red.shade800 
                                : Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage.isEmpty ? 'Listo para probar' : _statusMessage,
                      style: TextStyle(
                        color: _statusMessage.contains('✅') 
                            ? Colors.green.shade700 
                            : _statusMessage.contains('❌') 
                                ? Colors.red.shade700 
                                : Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botones de prueba
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testFirestoreConnection,
                    icon: const Icon(Icons.wifi),
                    label: const Text('Probar Conexión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createTestLote,
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Lote Test'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Botones adicionales
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/qr-library');
                    },
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Biblioteca QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/farmer');
                    },
                    icon: const Icon(Icons.agriculture),
                    label: const Text('Panel Agricultor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Lista de lotes
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.list, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Lotes registrados (${_lotes.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _loadLotes,
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _lotes.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No hay lotes registrados.\nCrea un lote de prueba para empezar.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _lotes.length,
                                  itemBuilder: (context, index) {
                                    final lote = _lotes[index];
                                    return ListTile(
                                      leading: const Icon(
                                        Icons.agriculture,
                                        color: Colors.green,
                                      ),
                                      title: Text('Lote ${lote.id}'),
                                      subtitle: Text(
                                        '${lote.variedad} - ${lote.productor}\n${lote.ubicacion}',
                                      ),
                                      trailing: Text(
                                        lote.fechaCosecha.toString().split(' ')[0],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 