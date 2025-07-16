import 'package:flutter/material.dart';
import '../models/mango.dart';
import '../utils/constants.dart';
import '../widgets/mango_card.dart';
import '../services/firebase_service.dart';
import 'user_type_selection.dart';

class MangoMarketplace extends StatefulWidget {
  const MangoMarketplace({super.key});

  @override
  State<MangoMarketplace> createState() => _MangoMarketplaceState();
}

class _MangoMarketplaceState extends State<MangoMarketplace> {
  bool _checkingRole = true;
  String _searchText = '';

  List<Mango> get filteredMangos {
    return AppConstants.availableMangos
        .where(
          (mango) => mango.name.toLowerCase().contains(
            _searchText.toLowerCase(),
          ),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final rol = await FirebaseService.getUserRole();
    if (rol != 'consumidor') {
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

  @override
  Widget build(BuildContext context) {
    if (_checkingRole) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              hintText: 'Buscar mangos...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onChanged: (text) {
              setState(() {
                _searchText = text;
              });
            },
          ),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: filteredMangos.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No se encontraron mangos',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredMangos.length,
              itemBuilder: (context, index) {
                return MangoCard(mango: filteredMangos[index]);
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        onTap: (index) {
          // TODO: Implementar navegación del bottom navigation
          if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Carrito próximamente'),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil próximamente'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
      ),
    );
  }
} 