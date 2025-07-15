import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/trazability_models.dart';
import '../../services/firebase_service.dart';

class RegisterLoteScreen extends StatefulWidget {
  const RegisterLoteScreen({super.key});

  @override
  State<RegisterLoteScreen> createState() => _RegisterLoteScreenState();
}

class _RegisterLoteScreenState extends State<RegisterLoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productorController = TextEditingController();
  final _ubicacionController = TextEditingController();
  String _selectedVariedad = 'Kent';
  DateTime _fechaCosecha = DateTime.now();
  String? _coordenadasGPS;
  bool _isLoading = false;
  bool _isGettingLocation = false;
  String _locationStatus = 'No obtenidas';

  final List<String> _variedades = ['Kent', 'Haden', 'Tommy Atkins', 'Ataulfo', 'Maya'];

  @override
  void initState() {
    super.initState();
    // Obtener ubicación automáticamente al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _productorController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    
    setState(() {
      _isGettingLocation = true;
      _locationStatus = 'Solicitando permisos...';
    });

    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _locationStatus = 'Permisos denegados';
            });
          }
          _showSnackBar('Permisos de ubicación denegados');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationStatus = 'Permisos bloqueados';
          });
        }
        _showSnackBar('Los permisos de ubicación están bloqueados permanentemente');
        return;
      }

      // Verificar si el GPS está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _locationStatus = 'GPS deshabilitado';
          });
        }
        _showSnackBar('Por favor habilita el GPS');
        return;
      }

      if (mounted) {
        setState(() {
          _locationStatus = 'Obteniendo ubicación...';
        });
      }

      // Obtener ubicación actual
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
      setState(() {
          _coordenadasGPS = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
          _locationStatus = 'Ubicación obtenida';
      });
      }

      _showSnackBar('Ubicación GPS obtenida exitosamente');
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationStatus = 'Error al obtener ubicación';
        });
      }
      _showSnackBar('Error al obtener ubicación: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaCosecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fechaCosecha) {
      setState(() {
        _fechaCosecha = picked;
      });
    }
  }

  Future<void> _saveLote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Crear el lote usando el constructor factory
      final lote = Lote.nuevo(
        productor: _productorController.text,
        ubicacion: _ubicacionController.text,
        variedad: _selectedVariedad,
        fechaCosecha: _fechaCosecha,
        condicionesClimaticas: {
          'temperatura': '28°C', // TODO: Obtener datos reales del clima
          'humedad': '65%',
          'condicion': 'cielo despejado',
          'viento': 'suave',
        },
        coordenadasGPS: _coordenadasGPS,
        estado: 'cosechado',
      );

      // Guardar en Firebase
      final loteId = await FirebaseService.createLote(lote);

      if (mounted) {
        _showSuccessDialog(loteId);
      }
    } catch (e) {
      _showSnackBar('Error al guardar el lote: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String loteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Lote Registrado!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID del Lote: $loteId'),
            const SizedBox(height: 8),
            Text('Productor: ${_productorController.text}'),
            const SizedBox(height: 8),
            Text('Variedad: $_selectedVariedad'),
            const SizedBox(height: 16),
            const Text(
              'El lote ha sido registrado exitosamente en la base de datos. Puedes continuar con el proceso de postcosecha.',
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
    if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    }
  }

  Color _getLocationStatusColor() {
    if (_locationStatus == 'Ubicación obtenida') {
      return Colors.green;
    } else if (_locationStatus == 'Error al obtener ubicación') {
      return Colors.red;
    } else if (_locationStatus == 'GPS deshabilitado') {
      return Colors.orange;
    } else if (_locationStatus == 'Solicitando permisos...') {
      return Colors.blue;
    } else if (_locationStatus == 'Permisos denegados' || _locationStatus == 'Permisos bloqueados') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  IconData _getLocationStatusIcon() {
    if (_locationStatus == 'Ubicación obtenida') {
      return Icons.check_circle;
    } else if (_locationStatus == 'Error al obtener ubicación') {
      return Icons.error;
    } else if (_locationStatus == 'GPS deshabilitado') {
      return Icons.gps_off;
    } else if (_locationStatus == 'Solicitando permisos...') {
      return Icons.access_time;
    } else if (_locationStatus == 'Permisos denegados' || _locationStatus == 'Permisos bloqueados') {
      return Icons.block;
    } else {
      return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Nuevo Lote'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del Lote',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              
              // Productor
              TextFormField(
                controller: _productorController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Productor/Finca',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del productor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ubicación
              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación (Ciudad, Región)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la ubicación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Variedad
              DropdownButtonFormField<String>(
                value: _selectedVariedad,
                decoration: const InputDecoration(
                  labelText: 'Variedad de Mango',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.eco),
                ),
                isExpanded: true,
                items: _variedades.map((String variedad) {
                  return DropdownMenuItem<String>(
                    value: variedad,
                    child: Text(variedad),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVariedad = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Fecha de Cosecha
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Cosecha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_fechaCosecha.day}/${_fechaCosecha.month}/${_fechaCosecha.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Coordenadas GPS
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              Row(
                children: [
                          const Icon(Icons.gps_fixed, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Coordenadas GPS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Estado de la ubicación
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getLocationStatusColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getLocationStatusColor(),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getLocationStatusIcon(),
                              color: _getLocationStatusColor(),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                  Expanded(
                              child: Text(
                                _locationStatus,
                                style: TextStyle(
                                  color: _getLocationStatusColor(),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Coordenadas obtenidas
                      if (_coordenadasGPS != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Coordenadas obtenidas:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _coordenadasGPS!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 12),
                      
                      // Botón para actualizar ubicación
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isGettingLocation ? null : _getCurrentLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: _isGettingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(_isGettingLocation ? 'Obteniendo...' : 'Actualizar Ubicación'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveLote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Registrar Lote',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 