class Mango {
  final String name;
  final double price;
  final String imageUrl;
  final String description;

  const Mango({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  factory Mango.fromMap(Map<String, dynamic> map) {
    return Mango(
      name: map['name'] ?? '',
      price: (map['price'] is int) ? (map['price'] as int).toDouble() : map['price'] ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'Mango(name: $name, price: $price, imageUrl: $imageUrl)';
  }
} 