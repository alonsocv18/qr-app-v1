// Prototipo visual de app de trazabilidad agrícola con códigos QR
// Pantalla 1: Pantalla de Inicio / Splash

import 'package:flutter/material.dart';
import 'consumer_screen.dart';

void main() => runApp(AgriQRApp());

class AgriQRApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriQR',
      theme: ThemeData(primarySwatch: Colors.green),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code, size: 100, color: Colors.green[800]),
            SizedBox(height: 20),
            Text(
              'AgriQR',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Del campo a tu mesa, con confianza.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserTypeSelection()),
                );
              },
              child: Text('Comenzar'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserTypeSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('¿Quién eres?')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.agriculture),
              label: Text('Soy Agricultor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConsumerScreen()),
                );
              },
              icon: Icon(Icons.person_search),
              label: Text('Soy Consumidor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
