import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/splash_screen.dart';
import 'screens/user_type_selection.dart';
import 'screens/farmer_screen.dart';
import 'screens/consumer_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/qr_library_screen.dart';
import 'screens/qr_generator_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/lote_management_screen.dart';
import 'screens/farmer_forms/register_lote_screen.dart';
import 'screens/farmer_forms/postcosecha_screen.dart';
import 'screens/farmer_forms/empacado_screen.dart';
import 'screens/farmer_forms/distribucion_screen.dart';
import 'screens/trazability_info_screen.dart';
import 'screens/mango_marketplace.dart';
import 'screens/mango_details_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(const AgriQRApp());
}

class AgriQRApp extends StatelessWidget {
  const AgriQRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriQR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/user-selection': (context) => const UserTypeSelection(),
        '/farmer': (context) => const FarmerScreen(),
        '/consumer': (context) => const ConsumerScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/qr-library': (context) => const QRLibraryScreen(),
        '/lote-management': (context) => const LoteManagementScreen(),
        '/register-lote': (context) => const RegisterLoteScreen(),
        '/postcosecha': (context) => const PostcosechaScreen(),
        '/empacado': (context) => const EmpacadoScreen(),
        '/distribucion': (context) => const DistribucionScreen(),
        '/marketplace': (context) => const MangoMarketplace(),
      },
    );
  }
} 