import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_application_1/mango_marketplace.dart';

class ConsumerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Opciones del consumidor')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MangoMarketplace()),
                );
              },
              child: Text('Ingresar al marketplace'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScannerScreen()),
                );
              },
              child: Text('EscanearQR'),
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
  CameraController? _controller; // Make it nullable
  late Future<void> _initializeControllerFuture = Future.value();

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      // Get a specific camera from the list of available cameras.
      if (cameras.isNotEmpty) {
        final firstCamera = cameras.first;

        _controller = CameraController(
          // Get a specific camera from the list of available cameras.
          firstCamera,
          // Define the resolution to use.
          ResolutionPreset.medium,
        );

        // Next, initialize the controller. This returns a Future.
        _initializeControllerFuture = _controller!.initialize();
      } else {
        // Handle the case where no cameras are available.
        print('No cameras available');
        _controller = null; // Ensure _controller is null
      }
    } catch (e) {
      // If the camera is not available or permissions are not granted,
      // display an error message.
      print('Error initializing camera: $e');
      _controller = null; // Ensure _controller is null
    }
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
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
            if (_controller != null &&
                _controller?.value.isInitialized == true) {
              return CameraPreview(_controller!);
            } else {
              return Center(child: Text('gf'));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
