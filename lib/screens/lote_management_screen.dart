import 'package:flutter/material.dart';
import '../models/trazability_models.dart';
import '../services/firebase_service.dart';
import 'qr_generator_screen.dart';

class LoteManagementScreen extends StatefulWidget {
  const LoteManagementScreen({super.key});

  @override
  State<LoteManagementScreen> createState() => _LoteManagementScreenState();
}

class _LoteManagementScreenState extends State<LoteManagementScreen> {
  List<Lote> _lotes = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLotes();
  }

  Future<void> _loadLotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final lotes = await FirebaseService.getLotes();
      setState(() {
        _lotes = lotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar lotes: $e';
        _isLoading = false;
      });
    }
  }

  String _getEstadoColor(String estado) {
    switch (estado) {
      case 'cosechado':
        return '#4CAF50'; // Verde
      case 'postcosecha':
        return '#2196F3'; // Azul
      case 'empacado':
        return '#FF9800'; // Naranja
      case 'paletizado':
        return '#9C27B0'; // Púrpura
      case 'almacenado':
        return '#607D8B'; // Gris azulado
      case 'transportado':
        return '#FF5722'; // Rojo naranja
      case 'distribuido':
        return '#795548'; // Marrón
      default:
        return '#757575'; // Gris
    }
  }

  String _getEstadoText(String estado) {
    switch (estado) {
      case 'cosechado':
        return 'Cosechado';
      case 'postcosecha':
        return 'Postcosecha';
      case 'empacado':
        return 'Empacado';
      case 'paletizado':
        return 'Paletizado';
      case 'almacenado':
        return 'Almacenado';
      case 'transportado':
        return 'Transportado';
      case 'distribuido':
        return 'Distribuido';
      default:
        return estado;
    }
  }

  void _showLoteDetails(Lote lote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lote ${lote.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Productor:', lote.productor),
              _buildDetailRow('Ubicación:', lote.ubicacion),
              _buildDetailRow('Variedad:', lote.variedad),
              _buildDetailRow('Fecha Cosecha:', 
                '${lote.fechaCosecha.day}/${lote.fechaCosecha.month}/${lote.fechaCosecha.year}'),
              _buildDetailRow('Estado:', _getEstadoText(lote.estado)),
              if (lote.coordenadasGPS != null)
                _buildDetailRow('GPS:', lote.coordenadasGPS!),
              const SizedBox(height: 8),
              const Text('Condiciones Climáticas:', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              ...lote.condicionesClimaticas.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('${entry.key}: ${entry.value}'),
                )
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _generateQRForLote(lote);
            },
            child: const Text('Generar QR'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _generateQRForLote(Lote lote) async {
    try {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRGeneratorScreen(
              tipo: 'lote',
              id: lote.id,
              titulo: 'QR de Trazabilidad - Lote ${lote.id}',
              datos: {
                'loteId': lote.id,
                'variedad': lote.variedad,
                'productor': lote.productor,
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar QR: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Lotes'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLotes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLotes,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _lotes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.agriculture,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay lotes registrados',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Registra tu primer lote para empezar',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadLotes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _lotes.length,
                        itemBuilder: (context, index) {
                          final lote = _lotes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Color(
                                  int.parse(
                                    _getEstadoColor(lote.estado).replaceAll('#', '0xFF'),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.agriculture,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                'Lote ${lote.id}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${lote.variedad} - ${lote.productor}'),
                                  Text(
                                    'Cosechado: ${lote.fechaCosecha.day}/${lote.fechaCosecha.month}/${lote.fechaCosecha.year}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(
                                    int.parse(
                                      _getEstadoColor(lote.estado).replaceAll('#', '0xFF'),
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getEstadoText(lote.estado),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onTap: () => _showLoteDetails(lote),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
} 