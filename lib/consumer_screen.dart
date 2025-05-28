import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_application_1/mango_marketplace.dart';

class ConsumerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Opciones del consumidor',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightGreen, // A lighter, more "fruity" green
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Image.asset('assets/market.jpg', width: 100, height: 100),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MangoMarketplace(),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart, color: Colors.white),
                      SizedBox(height: 0),
                      Text(
                        'Marketplace',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Image.asset('assets/qrcode.png', width: 100, height: 100),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRScannerScreen(),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code_scanner, color: Colors.white),
                      SizedBox(height: 0),
                      Text(
                        'Escanear QR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final firstCamera = cameras.first;

        _controller = CameraController(firstCamera, ResolutionPreset.medium);

        try {
          await _controller!.initialize();
        } catch (e) {
          print('Error initializing camera: $e');
          _controller = null;
        }
      } else {
        print('No cameras available');
        _controller = null;
      }
    } catch (e) {
      print('Error initializing camera: $e');
      _controller = null;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Scanner')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.done) {
            if (_controller == null || !_controller!.value.isInitialized) {
              return Center(child: Text('HA OCURRIDO UN ERROR'));
            } else {
              return CameraPreview(_controller!);
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
