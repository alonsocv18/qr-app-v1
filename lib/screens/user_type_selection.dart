import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'consumer_screen.dart';
import 'farmer_screen.dart';
import 'dashboard_screen.dart';
import '../services/firebase_service.dart';
import 'agricultor_pin_screen.dart';

class UserTypeSelection extends StatefulWidget {
  const UserTypeSelection({super.key});

  @override
  State<UserTypeSelection> createState() => _UserTypeSelectionState();
}

class _UserTypeSelectionState extends State<UserTypeSelection> {
  bool _isLoading = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _signInWithGoogleIfNeeded();
  }

  Future<void> _signInWithGoogleIfNeeded() async {
    setState(() { _isLoading = true; });
    final user = FirebaseService.getCurrentUser();
    if (user == null) {
      final credential = await FirebaseService.signInWithGoogle();
      if (credential == null) {
        setState(() { _isLoading = false; });
        return;
      }
      setState(() { _userEmail = credential.user?.email; });
    } else {
      setState(() { _userEmail = user.email; });
    }
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
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
            if (_userEmail != null)
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Text(
                  'Bienvenido, $_userEmail',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(1, 1))],
                  ),
                ),
              ),
            _buildOption(
              context,
              imagePath: 'assets/agricultor.png',
              label: 'SOY AGRICULTOR',
              onTap: () async {
                setState(() { _isLoading = true; });
                await FirebaseService.setUserRole('agricultor');
                setState(() { _isLoading = false; });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AgricultorPinScreen()),
                );
              },
            ),
            _buildOption(
              context,
              imagePath: 'assets/client.png',
              label: 'SOY CONSUMIDOR',
              onTap: () async {
                setState(() { _isLoading = true; });
                await FirebaseService.setUserRole('consumidor');
                setState(() { _isLoading = false; });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ConsumerScreen()),
                );
              },
            ),
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