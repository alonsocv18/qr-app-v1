import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/firebase_service.dart';
import '../models/trazability_models.dart';
import 'trazability_info_screen.dart';
import 'dart:convert';
import 'user_type_selection.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? controller;
  bool _isScanning = false;
  bool _hasPermission = false;
  String _statusMessage = 'Iniciando...';
  String _lastScannedData = 'Ningún QR escaneado';
  int _scanAttempts = 0;
  bool _checkingRole = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
    _requestCameraPermission();
  }

  Future<void> _checkRole() async {
    final rol = await FirebaseService.getUserRole();
    if (rol != 'agricultor' && rol != 'consumidor') {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserTypeSelection()),
          (route) => false,
        );
      }
    } else {
      setState(() { _checkingRole = false; });
    }
  }

  Future<void> _requestCameraPermission() async {
    setState(() {
      _statusMessage = 'Solicitando permisos...';
    });
    
    print('🔍 SOLICITANDO PERMISOS DE CÁMARA');
    final status = await Permission.camera.request();
    
    setState(() {
      _hasPermission = status.isGranted;
      _statusMessage = status.isGranted 
          ? '✅ Cámara lista - Escaneando...' 
          : '❌ Permisos denegados';
    });
    
    print('🔍 ESTADO DE PERMISOS: $status');
    print('🔍 PERMISOS CONCEDIDOS: ${status.isGranted}');
    
    if (status.isGranted) {
      controller = MobileScannerController();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
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

  Future<void> _processQRCode(String qrData) async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _statusMessage = '🔄 Procesando QR...';
    });

    try {
      // Pausar la cámara para evitar múltiples escaneos
      controller?.stop();

      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Debug: Mostrar qué datos recibimos del QR
      print('🔍 QR DATA RECIBIDA: $qrData');

      // Procesar el QR
      Map<String, dynamic> qrInfo;
      try {
        qrInfo = jsonDecode(qrData);
        print('🔍 QR PARSEADO COMO JSON: $qrInfo');
      } catch (e) {
        // Si no es JSON válido, asumir que es solo el ID del lote
        qrInfo = {'tipo': 'lote', 'id': qrData};
        print('🔍 QR NO ES JSON VÁLIDO, USANDO COMO ID DIRECTO: $qrData');
      }

      String tipo = qrInfo['tipo'] ?? 'lote';
      String loteId = qrInfo['id'] ?? qrData;
      print('🔍 TIPO: $tipo, LOTE ID: $loteId');

      // Verificar que sea un QR de tipo lote
      if (tipo != 'lote') {
        throw Exception('QR no válido para esta aplicación. Tipo: $tipo');
      }

      // Obtener información del lote
      print('🔍 BUSCANDO LOTE: $loteId');
      
      TrazabilidadCompleta? trazabilidad;
      try {
        trazabilidad = await FirebaseService.getTrazabilidadCompleta(loteId);
        print('🔍 TRAZABILIDAD ENCONTRADA: ${trazabilidad != null}');
        if (trazabilidad != null) {
          print('🔍 POSTCOSECHA: ${trazabilidad.postcosecha != null}');
          print('🔍 EMPACADO: ${trazabilidad.empacado != null}');
        }
      } catch (e) {
        print('🔍 ERROR OBTENIENDO TRAZABILIDAD: $e');
        trazabilidad = null;
      }

      // Cerrar indicador de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (trazabilidad != null) {
        print('🔍 TRAZABILIDAD ENCONTRADA, NAVEGANDO A PANTALLA DE INFO');
        setState(() {
          _statusMessage = '✅ Trazabilidad encontrada - Navegando...';
        });
        
        // Navegar a la pantalla de información de trazabilidad
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TrazabilityInfoScreen(
                trazabilidad: trazabilidad!,
              ),
            ),
          );
        }
      } else {
        print('🔍 NO SE ENCONTRÓ LA TRAZABILIDAD: $loteId');
        setState(() {
          _statusMessage = '❌ Trazabilidad no encontrada - Reintentando...';
        });
        _showErrorDialog('No se encontró información para este código QR. Verifica que el lote exista en la base de datos.');
        // Reanudar la cámara si no se encontró el lote
        controller?.start();
      }
    } catch (e) {
      print('🔍 ERROR PROCESANDO QR: $e');
      setState(() {
        _statusMessage = '❌ Error - Reintentando...';
      });
      // Cerrar indicador de carga
      if (mounted) {
        Navigator.of(context).pop();
      }
      _showErrorDialog('Error al procesar el código QR: $e');
      // Reanudar la cámara en caso de error
      controller?.start();
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingRole) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR - DEBUG'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () async {
              await controller?.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () async {
              await controller?.switchCamera();
            },
          ),
        ],
      ),
      body: !_hasPermission 
          ? _buildPermissionDeniedView()
          : Column(
              children: [
                // Panel de debug
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.black87,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado: $_statusMessage',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Intentos de escaneo: $_scanAttempts',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Último QR: $_lastScannedData',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Scanner
                Expanded(
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: controller,
                        onDetect: (capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          for (final barcode in barcodes) {
                            setState(() {
                              _scanAttempts++;
                              _lastScannedData = barcode.rawValue ?? 'Sin datos';
                            });
                            
                            print('🔍 DATOS ESCANEADOS: ${barcode.rawValue}');
                            print('🔍 INTENTO #$_scanAttempts');
                            
                            if (barcode.rawValue != null && !_isScanning) {
                              print('🔍 PROCESANDO QR: ${barcode.rawValue}');
                              _processQRCode(barcode.rawValue!);
                            }
                          }
                        },
                      ),
                      // Overlay para el marco
                      Center(
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      // Instrucciones
                      Positioned(
                        bottom: 50,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Coloca el código QR dentro del marco para escanear',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPermissionDeniedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'Permisos de Cámara Requeridos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Esta aplicación necesita acceso a la cámara para escanear códigos QR.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _requestCameraPermission,
            child: const Text('Solicitar Permisos'),
          ),
        ],
      ),
    );
  }
} 