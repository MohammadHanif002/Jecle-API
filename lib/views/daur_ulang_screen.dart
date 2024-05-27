import 'package:flutter/material.dart';

class DaurUlangScreen extends StatelessWidget {
  final List<Product> products = [
    Product(
      name: 'Lampu Botol Kerip-kerlip',
      imageUrl: 'assets/images/hasil daur ulang1.png',
      price: 130000.0,
    ),
    Product(
      name: 'Penyimpanan Botol Klasik',
      imageUrl: 'assets/images/hasil daur ulang2.png',
      price: 15000.0,
    ),
    Product(
      name: 'Hiasan Dinding Kerangsik',
      imageUrl: 'assets/images/hasil daur ulang3.png',
      price: 40000.0,
    ),
    Product(
      name: 'Vas Copule Jeraph',
      imageUrl: 'assets/images/hasil daur ulang4.png',
      price: 110000.0,
    ),
    Product(
      name: 'Tabungan Kardus Comelun',
      imageUrl: 'assets/images/hasil daur ulang5.png',
      price: 50000.0,
    ),
    Product(
      name: 'Vas Bunga kiyowoi',
      imageUrl: 'assets/images/hasil daur ulang6.png',
      price: 30000.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(94, 119, 216, 1),
                Color.fromRGBO(48, 133, 195, 1),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Text('Daur Ulang'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.7,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.asset(
                        product.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Rp. ${product.price.toStringAsFixed(0)}',
                          style:
                              TextStyle(color: Color.fromRGBO(48, 133, 195, 1)),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Implementasi logika beli
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromRGBO(48, 133, 195, 1),
                              ),
                              child: Text(
                                'Beli',
                                style: TextStyle(
                                    color: Colors.white), // Text color
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final String imageUrl;
  final double price;

  Product({
    required this.name,
    required this.imageUrl,
    required this.price,
  });
}
