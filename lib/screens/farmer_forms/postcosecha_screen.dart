import 'package:flutter/material.dart';
import '../../models/trazability_models.dart';
import '../../services/firebase_service.dart';

class PostcosechaScreen extends StatefulWidget {
  const PostcosechaScreen({super.key});

  @override
  State<PostcosechaScreen> createState() => _PostcosechaScreenState();
}

class _PostcosechaScreenState extends State<PostcosechaScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedTratamiento = 'Hidrotermia';
  final _temperaturaController = TextEditingController(text: '46.1');
  final _duracionController = TextEditingController(text: '75');
  String _selectedGradoMadurez = 'Óptimo para exportación';
  final _observacionesController = TextEditingController();
  bool _isLoading = false;
  List<Lote> _lotes = [];
  String? _selectedLoteId;

  final List<String> _tratamientos = ['Hidrotermia', 'Fumigación', 'Otro'];
  final List<String> _gradosMadurez = [
    'Óptimo para exportación',
    'Maduro para consumo local',
    'Semi-maduro',
    'Verde',
  ];

  @override
  void initState() {
    super.initState();
    _loadLotes();
  }

  @override
  void dispose() {
    _temperaturaController.dispose();
    _duracionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _loadLotes() async {
    setState(() => _isLoading = true);
    try {
      final lotes = await FirebaseService.getLotes();
      // Filtrar solo lotes que estén en estado 'cosechado'
      final lotesDisponibles = lotes.where((lote) => lote.estado == 'cosechado').toList();
      setState(() {
        _lotes = lotesDisponibles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error al cargar lotes: $e');
    }
  }

  Future<void> _savePostcosecha() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLoteId == null) {
      _showSnackBar('Por favor selecciona un lote');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final postcosecha = Postcosecha.nuevo(
        loteId: _selectedLoteId!,
        tipoTratamiento: _selectedTratamiento,
        temperatura: _temperaturaController.text,
        duracion: _duracionController.text,
        gradoMadurez: _selectedGradoMadurez,
        observaciones: _observacionesController.text.isNotEmpty 
            ? _observacionesController.text 
            : null,
      );

      final postcosechaId = await FirebaseService.createPostcosecha(postcosecha);
      
      if (mounted) {
        _showSuccessDialog(postcosechaId);
      }
    } catch (e) {
      _showSnackBar('Error al guardar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String postcosechaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Postcosecha Registrada!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID de Postcosecha: $postcosechaId'),
            const SizedBox(height: 8),
            Text('Lote: $_selectedLoteId'),
            const SizedBox(height: 8),
            Text('Tratamiento: $_selectedTratamiento'),
            const SizedBox(height: 16),
            const Text(
              'La información de postcosecha ha sido registrada exitosamente. El lote ahora está en estado "postcosecha" y puede continuar con el empacado.',
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
        title: const Text('Registro Postcosecha'),
        backgroundColor: Colors.blue,
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
                'Información de Postcosecha',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
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
                      'No hay lotes disponibles para postcosecha. Asegúrate de registrar un lote primero.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              
              if (_lotes.isNotEmpty) ...[
                // Tratamiento
                DropdownButtonFormField<String>(
                  value: _selectedTratamiento,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Tratamiento',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.water_drop),
                  ),
                  isExpanded: true,
                  items: _tratamientos.map((String tratamiento) {
                    return DropdownMenuItem<String>(
                      value: tratamiento,
                      child: Text(tratamiento),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTratamiento = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Temperatura
                TextFormField(
                  controller: _temperaturaController,
                  decoration: const InputDecoration(
                    labelText: 'Temperatura (°C)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.thermostat),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la temperatura';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Duración
                TextFormField(
                  controller: _duracionController,
                  decoration: const InputDecoration(
                    labelText: 'Duración (minutos)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.timer),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la duración';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Grado de Madurez
                DropdownButtonFormField<String>(
                  value: _selectedGradoMadurez,
                  decoration: const InputDecoration(
                    labelText: 'Grado de Madurez',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.eco),
                  ),
                  isExpanded: true,
                  items: _gradosMadurez.map((String grado) {
                    return DropdownMenuItem<String>(
                      value: grado,
                      child: Text(grado),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGradoMadurez = newValue!;
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
                    onPressed: _isLoading ? null : _savePostcosecha,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Registrar Postcosecha',
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