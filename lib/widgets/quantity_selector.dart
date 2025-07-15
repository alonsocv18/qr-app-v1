import 'package:flutter/material.dart';
import '../models/mango.dart';

class QuantitySelector extends StatefulWidget {
  final Mango mango;
  final Function(int quantity, double totalPrice)? onQuantityChanged;

  const QuantitySelector({
    super.key, 
    required this.mango,
    this.onQuantityChanged,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  int _quantity = 1;
  late double _currentPrice;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.mango.price;
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity >= 1) {
      setState(() {
        _quantity = newQuantity;
        _currentPrice = widget.mango.price * _quantity;
      });
      widget.onQuantityChanged?.call(_quantity, _currentPrice);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => _updateQuantity(_quantity - 1),
              color: Colors.green,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_quantity',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _updateQuantity(_quantity + 1),
              color: Colors.green,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '\$${_currentPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }
} 