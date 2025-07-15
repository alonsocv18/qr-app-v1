import '../models/mango.dart';

class AppConstants {
  static const String appName = 'AgriQR';
  static const String appTagline = 'Del campo a tu mesa, con confianza.';
  
  static const String backgroundImageUrl = 
      'https://cdn.www.gob.pe/uploads/document/file/6727708/997736-mango-d.png';

  static const List<Mango> availableMangos = [
    Mango(
      name: 'Kent',
      price: 2.50,
      imageUrl: 'https://www.finedininglovers.com/es/sites/g_files/xknfdk1706/files/styles/article_1200_800_fallback/public/2021-10/mango%C2%A9iStock.jpg?itok=b0BXEvPw',
      description: 'El mango Kent es una variedad de mango reconocida por su sabor dulce, suave y bajo contenido de fibra. Su pulpa es jugosa y de color amarillo intenso, ideal para consumir fresca o en preparaciones como jugos, batidos y postres.',
    ),
    Mango(
      name: 'T. Atkins',
      price: 3.00,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/Mango_TommyAtkins04_Asit.jpg/1200px-Mango_TommyAtkins04_Asit.jpg',
      description: 'Variedad de mango muy popular por su excelente sabor y textura. Ideal para consumo fresco y preparaciones culinarias.',
    ),
    Mango(
      name: 'Haden',
      price: 2.75,
      imageUrl: 'https://sowexotic.com/cdn/shop/products/hadenmangofruittreeforsalesowexotic_1_540x.png?v=1740421437',
      description: 'Mango Haden, conocido por su sabor dulce y aroma característico. Perfecto para jugos y postres.',
    ),
    Mango(
      name: 'Edward',
      price: 3.25,
      imageUrl: 'https://ddejw6xa064p3.cloudfront.net/sales/userGoods/IMG_7250.jpg',
      description: 'Variedad premium de mango con sabor excepcional y textura suave.',
    ),
    Mango(
      name: 'Omer',
      price: 4.00,
      imageUrl: 'https://goodfruitguide.co.uk/wp-content/uploads/Mango-Omer-IL-DSC_0186-cr-sq-400x400-1.jpg',
      description: 'Mango Omer, una variedad especial con características únicas de sabor y aroma.',
    ),
    Mango(
      name: 'Shelly',
      price: 3.50,
      imageUrl: 'https://il.all.biz/img/il/catalog/463.jpeg',
      description: 'Mango Shelly, conocido por su dulzura natural y textura cremosa.',
    ),
    Mango(
      name: 'Ataulfo',
      price: 2.25,
      imageUrl: 'https://www.mexicodesconocido.com.mx/wp-content/uploads/2020/03/mango-ataulfo.jpg',
      description: 'Mango Ataulfo, variedad mexicana muy apreciada por su sabor dulce y bajo contenido de fibra.',
    ),
    Mango(
      name: 'Maya',
      price: 2.80,
      imageUrl: 'https://cdn.jurassicfruit.com/images/product/1MAM19/mango-maya?i=0&s=800&progressive=1&lang=en&t=3954-1713513627',
      description: 'Mango Maya, con un sabor equilibrado entre dulce y ácido, perfecto para múltiples usos.',
    ),
    Mango(
      name: 'Criollo',
      price: 3.10,
      imageUrl: 'https://www.tropicalnd.com/images/mangos/Mango_criollo_01.jpg',
      description: 'Mango Criollo, variedad tradicional con características únicas de sabor y aroma.',
    ),
  ];
} 