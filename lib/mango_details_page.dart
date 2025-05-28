import 'package:flutter/material.dart';
import 'mango_marketplace.dart';

class MangoDetailsPage extends StatelessWidget {
  final Mango mango;

  const MangoDetailsPage({Key? key, required this.mango}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(mango.name)),
      body: ListView(
        children: [
          Image.network(
            mango.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 300,
          ),
          _QuantitySelector(mango: mango),
          _MangoDetails(mango: mango),
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatefulWidget {
  final Mango mango;

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
    _currentPrice = widget.mango.price;
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
                    _currentPrice = widget.mango.price * _quantity;
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
                  _currentPrice = widget.mango.price * _quantity;
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

class _MangoDetails extends StatelessWidget {
  final Mango mango;

  const _MangoDetails({Key? key, required this.mango}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final details = [
      'Origen del Mango: ${mango.origin}',
      'Nombre de la finca o productor: ${mango.farmName}',
      'Ubicación geográfica: ${mango.location}',
      'Fecha de cosecha: ${mango.harvestDate}',
      'Variedad del Mango: ${mango.variety}',
      'Tipo: ${mango.type}',
      'Características de sabor y textura: ${mango.flavor}',
      'Métodos de Cultivo: ${mango.cultivationMethods}',
      'Tipo de cultivo: ${mango.cultivationType}',
      'Certificaciones: ${mango.certifications}',
      'Uso de pesticidas o fertilizantes: ${mango.pesticides}',
      'Proceso de Cosecha y Empaque: ${mango.harvestProcess}',
      'Fecha de recolección: ${mango.collectionDate}',
      'Condiciones de cosecha: ${mango.harvestConditions}',
      'Centro de empaque: ${mango.packingCenter}',
      'Temperatura durante el transporte: ${mango.transportTemperature}',
      'Transporte: ${mango.transport}',
      'Medio de transporte: ${mango.transportMethod}',
      'Fecha de salida y llegada: ${mango.departureDate}',
      'Tiempo total de traslado: ${mango.totalTravelTime}',
      'Control de Calidad: ${mango.qualityControl}',
      'Pruebas realizadas: ${mango.testsPerformed}',
      'Resultados de calidad: ${mango.qualityResults}',
      'Fecha de inspección: ${mango.inspectionDate}',
      'Datos del Lote: ${mango.lotData}',
      'Código QR o ID del lote: ${mango.qrCode}',
      'Lote de producción: ${mango.productionLot}',
      'Cantidad de frutas en el lote: ${mango.fruitQuantity}',
      'Sostenibilidad: ${mango.sustainability}',
      'Huella de carbono estimada: ${mango.carbonFootprint}',
      'Acciones sostenibles del productor: ${mango.sustainableActions}',
      'Impacto social en la comunidad local: ${mango.socialImpact}',
      'Recomendaciones de Consumo: ${mango.consumptionRecommendations}',
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: details.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(details[index], style: TextStyle(fontSize: 16)),
          );
        },
      ),
    );
  }
}
