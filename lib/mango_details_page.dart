import 'package:flutter/material.dart';

class _QuantitySelector extends StatefulWidget {
  final Map<String, dynamic> mango;

  _QuantitySelector({required this.mango});

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<_QuantitySelector> {
  int _quantity = 1;
  late double _currentPrice;

  @override
  void initState() {
    super.initState();
    _currentPrice = double.parse(widget.mango['price'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  if (_quantity > 1) {
                    _quantity--;
                    _currentPrice =
                        double.parse(widget.mango['price'].toString()) *
                        _quantity;
                  }
                });
              },
            ),
            Text('$_quantity', style: TextStyle(fontSize: 20)),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _quantity++;
                  _currentPrice =
                      double.parse(widget.mango['price'].toString()) *
                      _quantity;
                });
              },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '\$${_currentPrice.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class MangoDetailsPage extends StatelessWidget {
  final Map<String, dynamic> mango;

  const MangoDetailsPage({Key? key, required this.mango}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Información')),
      body: ListView(
        children: [
          Center(
            child: Image.network(
              mango['imageUrl'],
              fit: BoxFit.cover,
              width: 350,
              height: 300,
            ),
          ),
          _QuantitySelector(mango: mango),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${mango['name']} 🥭',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'El mango Kent es una variedad de mango reconocida por su sabor dulce, suave y bajo contenido de fibra. Su pulpa es jugosa y de color amarillo intenso, ideal para consumir fresca o en preparaciones como jugos, batidos y postres. Se caracteriza por su forma ovalada, piel verde con rubor rojo, y una textura firme que facilita su manipulación y transporte.\nSu contenido de azúcar natural (Brix) lo hace muy apreciado tanto en mercados locales como internacionales.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
