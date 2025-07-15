import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'consumer_screen.dart';
import 'farmer_screen.dart';
import 'dashboard_screen.dart';

class UserTypeSelection extends StatelessWidget {
  const UserTypeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(AppConstants.backgroundImageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOption(
              context,
              imagePath: 'assets/agricultor.png',
              label: 'SOY AGRICULTOR',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FarmerScreen()),
                );
              },
            ),
            _buildOption(
              context,
              imagePath: 'assets/client.png',
              label: 'SOY CONSUMIDOR',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConsumerScreen()),
                );
              },
            ),
            // Botón para pruebas de Firebase
            _buildTestButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bug_report,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'PRUEBAS FIREBASE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(imagePath, fit: BoxFit.contain),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black54,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 