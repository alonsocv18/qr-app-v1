import 'package:flutter/material.dart';
import '../../models/trazability_models.dart';
import '../../services/firebase_service.dart';

class EmpacadoScreen extends StatefulWidget {
  const EmpacadoScreen({super.key});

  @override
  State<EmpacadoScreen> createState() => _EmpacadoScreenState();
}

class _EmpacadoScreenState extends State<EmpacadoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadCajasController = TextEditingController();
  final _pesoPorCajaController = TextEditingController(text: '4.0');
  final _cantidadPalletsController = TextEditingController();
  String _selectedTipoCaja = 'Caja de cartón estándar';
  String _selectedTipoPallet = 'Pallet de madera';
  final _observacionesController = TextEditingController();
  bool _isLoading = false;
  List<Lote> _lotes = [];
  String? _selectedLoteId;

  final List<String> _tiposCaja = [
    'Caja de cartón estándar',
    'Caja de plástico reutilizable',
    'Caja de madera',
    'Otro',
  ];

  final List<String> _tiposPallet = [
    'Pallet de madera',
    'Pallet de plástico',
    'Pallet de cartón',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _loadLotes();
  }

  @override
  void dispose() {
    _cantidadCajasController.dispose();
    _pesoPorCajaController.dispose();
    _cantidadPalletsController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _loadLotes() async {
    setState(() => _isLoading = true);
    try {
      final lotes = await FirebaseService.getLotes();
      // Filtrar solo lotes que estén en estado 'postcosecha'
      final lotesDisponibles = lotes.where((lote) => lote.estado == 'postcosecha').toList();
      setState(() {
        _lotes = lotesDisponibles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error al cargar lotes: $e');
    }
  }

  Future<void> _saveEmpacado() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLoteId == null) {
      _showSnackBar('Por favor selecciona un lote');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final empacado = Empacado.nuevo(
        loteId: _selectedLoteId!,
        cantidadCajas: _cantidadCajasController.text,
        pesoPorCaja: _pesoPorCajaController.text,
        tipoCaja: _selectedTipoCaja,
        cantidadPallets: _cantidadPalletsController.text,
        tipoPallet: _selectedTipoPallet,
        observaciones: _observacionesController.text.isNotEmpty 
            ? _observacionesController.text 
            : null,
      );

      final empacadoId = await FirebaseService.createEmpacado(empacado);
      
      if (mounted) {
        _showSuccessDialog(empacadoId);
      }
    } catch (e) {
      _showSnackBar('Error al guardar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String empacadoId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Empacado Registrado!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID de Empacado: $empacadoId'),
            const SizedBox(height: 8),
            Text('Lote: $_selectedLoteId'),
            const SizedBox(height: 8),
            Text('Cajas: ${_cantidadCajasController.text}'),
            const SizedBox(height: 8),
            Text('Pallets: ${_cantidadPalletsController.text}'),
            const SizedBox(height: 16),
            const Text(
              'La información de empacado ha sido registrada exitosamente. El lote ahora está en estado "empacado" y puede generar el QR de trazabilidad completa.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Empacado'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLotes,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información de Empacado',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),
              
              // Selección de Lote
              DropdownButtonFormField<String>(
                value: _selectedLoteId,
                decoration: const InputDecoration(
                  labelText: 'Seleccionar Lote',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.agriculture),
                ),
                isExpanded: true,
                items: _lotes.map((Lote lote) {
                  // Acortar el ID del lote para mostrar solo los últimos 8 caracteres
                  String shortId = lote.id.length > 8 ? '...${lote.id.substring(lote.id.length - 8)}' : lote.id;
                  return DropdownMenuItem<String>(
                    value: lote.id,
                    child: Text(
                      'Lote $shortId - ${lote.variedad}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLoteId = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona un lote';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              if (_lotes.isEmpty && !_isLoading)
                const Card(
                  color: Colors.orange,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No hay lotes disponibles para empacado. Asegúrate de registrar postcosecha primero.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              
              if (_lotes.isNotEmpty) ...[
                // Cantidad de Cajas
                TextFormField(
                  controller: _cantidadCajasController,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad de Cajas',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory_2),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la cantidad de cajas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Peso por Caja
                TextFormField(
                  controller: _pesoPorCajaController,
                  decoration: const InputDecoration(
                    labelText: 'Peso por Caja (kg)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.scale),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el peso por caja';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tipo de Caja
                DropdownButtonFormField<String>(
                  value: _selectedTipoCaja,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Caja',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory),
                  ),
                  isExpanded: true,
                  items: _tiposCaja.map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTipoCaja = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Cantidad de Pallets
                TextFormField(
                  controller: _cantidadPalletsController,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad de Pallets',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.grid_4x4),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la cantidad de pallets';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tipo de Pallet
                DropdownButtonFormField<String>(
                  value: _selectedTipoPallet,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Pallet',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.grid_4x4),
                  ),
                  isExpanded: true,
                  items: _tiposPallet.map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTipoPallet = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Observaciones
                TextFormField(
                  controller: _observacionesController,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 30),

                // Botón de guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveEmpacado,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Registrar Empacado',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 