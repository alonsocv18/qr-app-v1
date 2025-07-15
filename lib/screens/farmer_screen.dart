import 'package:flutter/material.dart';
import 'farmer_forms/register_lote_screen.dart';
import 'farmer_forms/postcosecha_screen.dart';
import 'farmer_forms/empacado_screen.dart';
import 'farmer_forms/distribucion_screen.dart';
import 'lote_management_screen.dart';

class FarmerScreen extends StatelessWidget {
  const FarmerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel del Agricultor',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gestión de Trazabilidad',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Registra y gestiona la información de tus lotes de mango',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildOptionCard(
                      context,
                      icon: Icons.agriculture,
                      title: 'Registrar Lote',
                      subtitle: 'Nueva cosecha',
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterLoteScreen(),
                          ),
                        );
                      },
                    ),
                    _buildOptionCard(
                      context,
                      icon: Icons.water_drop,
                      title: 'Postcosecha',
                      subtitle: 'Tratamientos',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PostcosechaScreen(),
                          ),
                        );
                      },
                    ),
                    _buildOptionCard(
                      context,
                      icon: Icons.inventory_2,
                      title: 'Empacado',
                      subtitle: 'Cajas y pallets',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmpacadoScreen(),
                          ),
                        );
                      },
                    ),
                    _buildOptionCard(
                      context,
                      icon: Icons.local_shipping,
                      title: 'Distribución',
                      subtitle: 'Transporte y entrega',
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DistribucionScreen(),
                          ),
                        );
                      },
                    ),
                    _buildOptionCard(
                      context,
                      icon: Icons.qr_code,
                      title: 'Generar QR',
                      subtitle: 'Códigos de trazabilidad',
                      color: Colors.purple,
                      onTap: () {
                        _showQRGenerationDialog(context);
                      },
                    ),
                    _buildOptionCard(
                      context,
                      icon: Icons.history,
                      title: 'Historial',
                      subtitle: 'Lotes registrados',
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoteManagementScreen(),
                          ),
                        );
                      },
                    ),
                    _buildOptionCard(
                      context,
                      icon: Icons.analytics,
                      title: 'Reportes',
                      subtitle: 'Estadísticas',
                      color: Colors.teal,
                      onTap: () {
                        _showComingSoonDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showQRGenerationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generar QR'),
        content: const Text(
          'Selecciona el tipo de QR que quieres generar:',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToLoteManagement(context);
            },
            child: const Text('Por Lote'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoonDialog(context);
            },
            child: const Text('Por Caja'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoonDialog(context);
            },
            child: const Text('Por Pallet'),
          ),
        ],
      ),
    );
  }

  void _navigateToLoteManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoteManagementScreen(),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Próximamente'),
        content: const Text(
          'Esta funcionalidad estará disponible en la próxima versión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 