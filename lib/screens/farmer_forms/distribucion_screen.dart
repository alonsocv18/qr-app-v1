import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/trazability_models.dart';
import '../../services/firebase_service.dart';

class DistribucionScreen extends StatefulWidget {
  const DistribucionScreen({super.key});

  @override
  State<DistribucionScreen> createState() => _DistribucionScreenState();
}

class _DistribucionScreenState extends State<DistribucionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinoController = TextEditingController();
  final _transportistaController = TextEditingController();
  final _placaController = TextEditingController();
  final _observacionesController = TextEditingController();
  
  String? _selectedLoteId;
  String _tipoTransporte = 'normal';
  DateTime _fechaSalida = DateTime.now();
  bool _isLoading = false;
  List<Lote> _lotes = [];

  @override
  void initState() {
    super.initState();
    _loadLotes();
  }

  @override
  void dispose() {
    _destinoController.dispose();
    _transportistaController.dispose();
    _placaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _loadLotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final lotes = await FirebaseService.getLotes();
      // Filtrar solo lotes que ya tienen empacado registrado
      final lotesConEmpacado = <Lote>[];
      
      for (final lote in lotes) {
        try {
          final empacado = await FirebaseService.getEmpacadoByLoteId(lote.id);
          if (empacado != null) {
            lotesConEmpacado.add(lote);
          }
        } catch (e) {
          // Si no hay empacado, no incluir el lote
        }
      }

      setState(() {
        _lotes = lotesConEmpacado;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error al cargar lotes: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSalida,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _fechaSalida) {
      setState(() {
        _fechaSalida = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final distribucion = Distribucion.nuevo(
        loteId: _selectedLoteId!,
        destino: _destinoController.text.trim(),
        transportista: _transportistaController.text.trim(),
        placaVehiculo: _placaController.text.trim(),
        tipoTransporte: _tipoTransporte,
        fechaSalida: _fechaSalida,
        observaciones: _observacionesController.text.trim().isEmpty 
            ? null 
            : _observacionesController.text.trim(),
      );

      await FirebaseService.createDistribucion(distribucion);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Distribución registrada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        title: const Text('Registrar Distribución'),
        backgroundColor: Colors.green,
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
                'Información de Distribución',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
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
                      'No hay lotes disponibles para distribución. Asegúrate de registrar empacado primero.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              
              if (_lotes.isNotEmpty) ...[
                // Destino
                TextFormField(
                  controller: _destinoController,
                  decoration: const InputDecoration(
                    labelText: 'Destino *',
                    hintText: 'Ciudad, mercado, cliente, etc.',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingrese el destino';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Transportista
                TextFormField(
                  controller: _transportistaController,
                  decoration: const InputDecoration(
                    labelText: 'Transportista *',
                    hintText: 'Nombre del transportista o empresa',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingrese el transportista';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Placa del vehículo
                TextFormField(
                  controller: _placaController,
                  decoration: const InputDecoration(
                    labelText: 'Placa del Vehículo *',
                    hintText: 'ABC-123',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingrese la placa del vehículo';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Tipo de transporte
                DropdownButtonFormField<String>(
                  value: _tipoTransporte,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Transporte *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_shipping),
                  ),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'normal',
                      child: Text('Normal'),
                    ),
                    DropdownMenuItem(
                      value: 'refrigerado',
                      child: Text('Refrigerado'),
                    ),
                    DropdownMenuItem(
                      value: 'especial',
                      child: Text('Especial'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _tipoTransporte = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Fecha de salida
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Salida *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_fechaSalida.day}/${_fechaSalida.month}/${_fechaSalida.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Observaciones
                TextFormField(
                  controller: _observacionesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    hintText: 'Información adicional sobre la distribución...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Botón de envío
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Registrar Distribución',
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