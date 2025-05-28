import 'package:flutter/material.dart';
import 'mango_details_page.dart';

class MangoMarketplace extends StatefulWidget {
  @override
  _MangoMarketplaceState createState() => _MangoMarketplaceState();
}

class _MangoMarketplaceState extends State<MangoMarketplace> {
  String _searchText = '';
  final List<Map<String, dynamic>> mangos = [
    {
      'name': 'Kent',
      'price': 2.50,
      'imageUrl':
          'https://www.finedininglovers.com/es/sites/g/files/xknfdk1706/files/styles/article_1200_800_fallback/public/2021-10/mango%C2%A9iStock.jpg?itok=b0BXEvPw',
    },
    {
      'name': 'T. Atkins',
      'price': 3.00,
      'imageUrl':
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Mango_TommyAtkins04_Asit.jpg/1200px-Mango_TommyAtkins04_Asit.jpg',
    },
    {
      'name': 'Haden',
      'price': 2.75,
      'imageUrl':
          'https://sowexotic.com/cdn/shop/products/hadenmangofruittreeforsalesowexotic_1_540x.png?v=1740421437',
    },
    {
      'name': 'Edward',
      'price': 3.25,
      'imageUrl':
          'https://ddejw6xa064p3.cloudfront.net/sales/userGoods/IMG_7250.jpg',
    },
    {
      'name': 'Omer',
      'price': 4.00,
      'imageUrl':
          'https://goodfruitguide.co.uk/wp-content/uploads/Mango-Omer-IL-DSC_0186-cr-sq-400x400-1.jpg',
    },
    {
      'name': 'Shelly',
      'price': 3.50,
      'imageUrl': 'https://il.all.biz/img/il/catalog/463.jpeg',
    },
    {
      'name': 'Ataulfo',
      'price': 2.25,
      'imageUrl':
          'https://www.mexicodesconocido.com.mx/wp-content/uploads/2020/03/mango-ataulfo.jpg',
    },
    {
      'name': 'Maya',
      'price': 2.80,
      'imageUrl':
          'https://cdn.jurassicfruit.com/images/product/1MAM19/mango-maya?i=0&s=800&progressive=1&lang=en&t=3954-1713513627',
    },
    {
      'name': 'Criollo',
      'price': 3.10,
      'imageUrl':
          'https://www.tropicalnd.com/images/mangos/Mango_criollo_01.jpg',
    },
  ];

  List<Map<String, dynamic>> get filteredMangos {
    return mangos
        .where(
          (mango) => mango['name'].toString().toLowerCase().contains(
            _searchText.toLowerCase(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar...',
                border: InputBorder.none,
              ),
              onChanged: (text) {
                setState(() {
                  _searchText = text;
                });
              },
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: filteredMangos.length,
        itemBuilder: (context, index) {
          return MangoCard(mango: filteredMangos[index]);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Marketplace'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class MangoCard extends StatelessWidget {
  final Map<String, dynamic> mango;

  const MangoCard({Key? key, required this.mango}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangoDetailsPage(mango: mango),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  mango['imageUrl'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              SizedBox(height: 8),
              Text(
                mango['name'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '\$${double.parse(mango['price'].toString()).toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
