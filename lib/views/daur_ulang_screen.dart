import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jecle/views/checkout_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DaurUlangScreen extends StatefulWidget {
  @override
  _DaurUlangScreenState createState() => _DaurUlangScreenState();
}

class _DaurUlangScreenState extends State<DaurUlangScreen> {
  List<Product> products = [];
  List<Product> cart = [];
  double _saldo = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSaldo();
    _fetchProducts();
  }

  void _loadSaldo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _saldo = prefs.getDouble('saldo') ?? 0.0;
    });
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://jeclebase-8fe6f-default-rtdb.firebaseio.com/product.json'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<Product> fetchedProducts = [];
        data.forEach((key, value) {
          final product = Product(
            id: key,
            name: value['name'],
            imageUrl: value['imageUrl'],
            price: value['price'].toDouble(),
          );
          fetchedProducts.add(product);
        });

        setState(() {
          products = fetchedProducts;
        });
      } else {
        print('Failed to fetch products: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  void addToCart(Product product) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://jeclebase-8fe6f-default-rtdb.firebaseio.com/cart/${product.id}.json'),
        body: jsonEncode({
          'name': product.name,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'quantity': product.quantity,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('${product.name} berhasil ditambahkan ke keranjang')),
        );
      } else {
        print('Failed to add product to cart: ${response.statusCode}');
      }
    } catch (error) {
      print('Error adding product to cart: $error');
    }

    setState(() {
      final existingProduct = cart.firstWhere(
        (p) => p.id == product.id,
        orElse: () => Product(id: '', name: '', imageUrl: '', price: 0),
      );
      if (existingProduct.id != '') {
        existingProduct.quantity += 1;
      } else {
        cart.add(product);
      }
    });
  }

  void removeFromCart(Product product) {
    setState(() {
      cart.remove(product);
    });
  }

  void checkout() {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Keranjang kosong!')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cart: cart, saldo: _saldo),
      ),
    );
  }

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
        title: Text('Daur Ulang'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Color.fromRGBO(255, 255, 255, 1),
            onPressed: checkout,
          ),
        ],
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
                                addToCart(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '${product.name} ditambahkan ke keranjang')),
                                );
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
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.quantity = 1,
  });
}
