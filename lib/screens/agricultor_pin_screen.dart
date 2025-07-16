import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'farmer_screen.dart';

class AgricultorPinScreen extends StatefulWidget {
  const AgricultorPinScreen({super.key});

  @override
  State<AgricultorPinScreen> createState() => _AgricultorPinScreenState();
}

class _AgricultorPinScreenState extends State<AgricultorPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _validatePin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      setState(() {
        _isLoading = false;
        _error = 'El PIN debe tener 4 dígitos';
      });
      return;
    }
    final isValid = await FirebaseService.validateAgricultorPin(pin);
    if (isValid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FarmerScreen()),
      );
    } else {
      setState(() {
        _isLoading = false;
        _error = 'PIN incorrecto o ya utilizado';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validar PIN de Agricultor')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ingresa el PIN de 4 dígitos proporcionado por la empresa para acceder como agricultor:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'PIN',
                border: const OutlineInputBorder(),
                errorText: _error,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _validatePin,
                    child: const Text('Validar y acceder'),
                  ),
          ],
        ),
      ),
    );
  }
} 