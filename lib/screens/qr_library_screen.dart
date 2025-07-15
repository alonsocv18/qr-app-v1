import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/firebase_service.dart';

class QRLibraryScreen extends StatefulWidget {
  const QRLibraryScreen({super.key});

  @override
  State<QRLibraryScreen> createState() => _QRLibraryScreenState();
}

class _QRLibraryScreenState extends State<QRLibraryScreen> {
  List<Map<String, dynamic>> _qrCodes = [];
  List<Map<String, dynamic>> _filteredQRCodes = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchTerm = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQRCodes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQRCodes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🔄 Cargando QR codes...');
      final qrCodes = await FirebaseService.getAllQRCodes();
      print('✅ QR codes cargados: ${qrCodes.length}');
      
      if (mounted) {
        setState(() {
          _qrCodes = qrCodes;
          _filteredQRCodes = qrCodes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error al cargar QR codes: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar QR codes: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _filterQRCodes(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm;
      if (searchTerm.isEmpty) {
        _filteredQRCodes = _qrCodes;
      } else {
        _filteredQRCodes = _qrCodes.where((qr) {
          final loteId = qr['loteId'].toString().toLowerCase();
          return loteId.contains(searchTerm.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _searchQRCodes() async {
    if (_searchTerm.isEmpty) {
      _loadQRCodes();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final qrCodes = await FirebaseService.searchQRCodes(_searchTerm);
      setState(() {
        _filteredQRCodes = qrCodes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al buscar QR codes: $e';
        _isLoading = false;
      });
    }
  }

  void _showQRDetails(Map<String, dynamic> qrCode) {
    final qrData = qrCode['qrData'] as String?;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'QR - Lote ${qrCode['loteId']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const Divider(),
              
              // Información del QR
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID del Lote: ${qrCode['loteId']}'),
                    const SizedBox(height: 4),
                    Text('ID del QR: ${qrCode['id']}'),
                    if (qrCode['fechaCreacion'] != null) ...[
                      const SizedBox(height: 4),
                      Text('Fecha: ${(qrCode['fechaCreacion'] as Timestamp).toDate().toString().substring(0, 19)}'),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Código QR
              if (qrData != null) ...[
                const Text(
                  'Código QR:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const Expanded(
                  child: Center(
                    child: Text(
                      'Datos del QR no disponibles',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                  if (qrData != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showQROptions(qrCode);
                      },
                      icon: const Icon(Icons.more_vert),
                      label: const Text('Opciones'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQROptions(Map<String, dynamic> qrCode) {
    final qrData = qrCode['qrData'] as String?;
    if (qrData == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Opciones del QR',
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
                _printQR(qrCode);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartir QR'),
              subtitle: const Text('Enviar por WhatsApp, email, etc.'),
              onTap: () {
                Navigator.pop(context);
                _shareQR(qrCode);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Descargar QR'),
              subtitle: const Text('Guardar imagen del QR'),
              onTap: () {
                Navigator.pop(context);
                _downloadQR(qrCode);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar QR', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Eliminar de la biblioteca'),
              onTap: () {
                Navigator.pop(context);
                _deleteQR(qrCode);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _printQR(Map<String, dynamic> qrCode) {
    // TODO: Implementar impresión
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de impresión en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _shareQR(Map<String, dynamic> qrCode) {
    // TODO: Implementar compartir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de compartir en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _downloadQR(Map<String, dynamic> qrCode) {
    // TODO: Implementar descarga
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de descarga en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _deleteQR(Map<String, dynamic> qrCode) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar QR'),
        content: Text('¿Estás seguro de que quieres eliminar el QR del lote ${qrCode['loteId']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseService.deleteQRCode(qrCode['id']);
        _loadQRCodes(); // Recargar la lista
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar QR: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca de QR'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQRCodes,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por ID del lote...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: _searchTerm.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterQRCodes('');
                              },
                            )
                          : null,
                    ),
                    onChanged: _filterQRCodes,
                    onSubmitted: (_) => _searchQRCodes(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchQRCodes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),

          // Lista de QR codes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadQRCodes,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : _filteredQRCodes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.qr_code,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchTerm.isEmpty
                                      ? 'No hay QR codes guardados'
                                      : 'No se encontraron QR codes',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchTerm.isEmpty
                                      ? 'Genera QR codes para verlos aquí'
                                      : 'Intenta con otro término de búsqueda',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredQRCodes.length,
                            itemBuilder: (context, index) {
                              final qrCode = _filteredQRCodes[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green,
                                    child: const Icon(
                                      Icons.qr_code,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    'Lote ${qrCode['loteId']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text('Archivo: ${qrCode['fileName']}'),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'details':
                                          _showQRDetails(qrCode);
                                          break;
                                        case 'delete':
                                          _deleteQR(qrCode);
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'details',
                                        child: Row(
                                          children: [
                                            Icon(Icons.info),
                                            SizedBox(width: 8),
                                            Text('Detalles'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _showQRDetails(qrCode),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
} 