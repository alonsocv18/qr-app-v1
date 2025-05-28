import 'package:flutter/material.dart';
import 'mango_details_page.dart';

class MangoMarketplace extends StatefulWidget {
  @override
  _MangoMarketplaceState createState() => _MangoMarketplaceState();
}

class _MangoMarketplaceState extends State<MangoMarketplace> {
  String _searchText = '';
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

  List<Mango> get filteredMangos {
    return mangos
        .where(
          (mango) =>
              mango.name.toLowerCase().contains(_searchText.toLowerCase()),
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
                hintText: 'Search...',
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
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class Mango {
  final String name;
  final double price;
  final String imageUrl;
  final String origin;
  final String farmName;
  final String location;
  final String harvestDate;
  final String variety;
  final String type;
  final String flavor;
  final String cultivationMethods;
  final String cultivationType;
  final String certifications;
  final String pesticides;
  final String harvestProcess;
  final String collectionDate;
  final String harvestConditions;
  final String packingCenter;
  final String transportTemperature;
  final String transport;
  final String transportMethod;
  final String departureDate;
  final String totalTravelTime;
  final String qualityControl;
  final String testsPerformed;
  final String qualityResults;
  final String inspectionDate;
  final String lotData;
  final String qrCode;
  final String productionLot;
  final String fruitQuantity;
  final String sustainability;
  final String carbonFootprint;
  final String sustainableActions;
  final String socialImpact;
  final String consumptionRecommendations;
  final String optimalConsumptionDate;
  final String conservationTips;
  final String usageRecipes;

  Mango({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.origin = 'Piura, Perú',
    this.farmName = 'Perú Valle SAC',
    this.location = 'Sullana, Piura',
    this.harvestDate = '2025-01-22',
    this.variety = 'Mango Kent',
    this.type = 'Fruta tropical fresca',
    this.flavor = 'Dulce y jugoso, con poca fibra',
    this.cultivationMethods = 'Riego tecnificado y abono orgánico',
    this.cultivationType = 'Cultivo sostenible certificado',
    this.certifications = 'GlobalG.A.P., SENASA Perú',
    this.pesticides = 'Manejo integrado con control biológico',
    this.harvestProcess = 'Cosecha manual en horas frescas',
    this.collectionDate = '2025-01-23',
    this.harvestConditions = 'Cielo despejado, 26°C',
    this.packingCenter = 'Empacadora El Mango de Oro',
    this.transportTemperature = 'Mantención a 8°C',
    this.transport = 'Camión refrigerado hasta puerto de Paita',
    this.transportMethod = 'Marítimo hacia EE.UU.',
    this.departureDate = '2025-01-25',
    this.totalTravelTime = '12 días hasta destino final',
    this.qualityControl = 'Inspección visual y análisis de madurez',
    this.testsPerformed = 'Niveles de Brix, firmeza, residuos',
    this.qualityResults = 'Calidad exportación A',
    this.inspectionDate = '2025-01-24',
    this.lotData = 'Lote PIU-KENT-0125',
    this.qrCode = 'QR-PIU-0125-KENT',
    this.productionLot = 'LOT-KENT-0224-AGSI',
    this.fruitQuantity = '20 kg por caja',
    this.sustainability = 'Reducción de uso de agua y energía',
    this.carbonFootprint = '0.8 kg CO₂e por kg de mango',
    this.sustainableActions = 'Paneles solares, compostaje local',
    this.socialImpact = 'Apoyo a comunidades rurales y empleo local',
    this.consumptionRecommendations = 'Lavar antes de pelar. Consumir fresco.',
    this.optimalConsumptionDate = '2025-02-10',
    this.conservationTips = 'Mantener refrigerado entre 8-10°C',
    this.usageRecipes = 'Jugos, ensaladas, postres tropicales',
  });
}

class MangoCard extends StatelessWidget {
  final Mango mango;

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
      ),
    );
  }
}
