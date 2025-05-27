import 'package:flutter/material.dart';

class MangoMarketplace extends StatelessWidget {
  final List<Mango> mangos = [
    Mango(
      name: 'Kent',
      price: 2.50,
      imageUrl:
          'https://www.finedininglovers.com/es/sites/g/files/xknfdk1706/files/styles/article_1200_800_fallback/public/2021-10/mango%C2%A9iStock.jpg?itok=b0BXEvPw',
    ),
    Mango(
      name: 'T. Atkins',
      price: 3.00,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Mango_TommyAtkins04_Asit.jpg/1200px-Mango_TommyAtkins04_Asit.jpg',
    ),
    Mango(
      name: 'Haden',
      price: 2.75,
      imageUrl:
          'https://sowexotic.com/cdn/shop/products/hadenmangofruittreeforsalesowexotic_1_540x.png?v=1740421437',
    ),
    Mango(
      name: 'Edward',
      price: 3.25,
      imageUrl:
          'https://ddejw6xa064p3.cloudfront.net/sales/userGoods/IMG_7250.jpg',
    ),
    Mango(
      name: 'Omer',
      price: 4.00,
      imageUrl:
          'https://goodfruitguide.co.uk/wp-content/uploads/Mango-Omer-IL-DSC_0186-cr-sq-400x400-1.jpg',
    ),
    Mango(
      name: 'Shelly',
      price: 3.50,
      imageUrl: 'https://il.all.biz/img/il/catalog/463.jpeg',
    ),
    Mango(
      name: 'Ataulfo',
      price: 2.25,
      imageUrl:
          'https://www.mexicodesconocido.com.mx/wp-content/uploads/2020/03/mango-ataulfo.jpg',
    ),
    Mango(
      name: 'Maya',
      price: 2.80,
      imageUrl:
          'https://cdn.jurassicfruit.com/images/product/1MAM19/mango-maya?i=0&s=800&progressive=1&lang=en&t=3954-1713513627',
    ),
    Mango(
      name: 'Criollo',
      price: 3.10,
      imageUrl: 'https://www.tropicalnd.com/images/mangos/Mango_criollo_01.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Marketplace')),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: mangos.length,
        itemBuilder: (context, index) {
          return MangoCard(mango: mangos[index]);
        },
      ),
    );
  }
}

class Mango {
  final String name;
  final double price;
  final String imageUrl;

  Mango({required this.name, required this.price, required this.imageUrl});
}

class MangoCard extends StatelessWidget {
  final Mango mango;

  const MangoCard({Key? key, required this.mango}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                mango.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            SizedBox(height: 8),
            Text(
              mango.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text('\$${mango.price.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
