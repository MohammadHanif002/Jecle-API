import 'package:flutter/material.dart';
import 'package:jecle/views/home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminDaurUlangScreen extends StatefulWidget {
  @override
  _AdminDaurUlangScreenState createState() => _AdminDaurUlangScreenState();
}

class _AdminDaurUlangScreenState extends State<AdminDaurUlangScreen> {
  List<Product> products = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _imageUrl = '';
  String? _currentProductId;
  final List<String> _imageUrls = [
    'assets/images/hasil daur ulang1.png',
    'assets/images/hasil daur ulang2.png',
    'assets/images/hasil daur ulang3.png',
    'assets/images/hasil daur ulang4.png',
    'assets/images/hasil daur ulang5.png',
    'assets/images/hasil daur ulang6.png'
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://jeclebase-8fe6f-default-rtdb.firebaseio.com/product.json'),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);
        if (data != null) {
          final List<Product> fetchedProducts = [];
          data.forEach((key, value) {
            final product = Product(
              id: key,
              name: value['name'] ?? '',
              imageUrl: value['imageUrl'] ?? '',
              price: (value['price'] ?? 0).toDouble(),
              quantity: (value['quantity'] ?? 1),
            );
            fetchedProducts.add(product);
          });
          if (mounted) {
            setState(() {
              products = fetchedProducts;
            });
          }
        } else {
          print('No data found');
        }
      } else {
        print('Failed to fetch products: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching products: $error');
    }
  }

  Future<void> _addOrUpdateProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: _currentProductId ?? '',
        name: _nameController.text,
        imageUrl: _imageUrl,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
      );
      final url = _currentProductId == null
          ? 'https://jeclebase-8fe6f-default-rtdb.firebaseio.com/product.json'
          : 'https://jeclebase-8fe6f-default-rtdb.firebaseio.com/product/$_currentProductId.json';
      final response = await (_currentProductId == null
          ? http.post(Uri.parse(url), body: jsonEncode(product.toJson()))
          : http.put(Uri.parse(url), body: jsonEncode(product.toJson())));
      print('Add/Update Response status: ${response.statusCode}');
      print('Add/Update Response body: ${response.body}');
      if (response.statusCode == 200) {
        _fetchProducts();
        _clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Product ${_currentProductId == null ? 'added' : 'updated'} successfully'),
          ),
        );
      } else {
        print('Failed to add/update product: ${response.statusCode}');
      }
    }
  }

  Future<void> _deleteProduct(String id) async {
    final response = await http.delete(
      Uri.parse(
          'https://jeclebase-8fe6f-default-rtdb.firebaseio.com/product/$id.json'),
    );
    print('Delete Response status: ${response.statusCode}');
    print('Delete Response body: ${response.body}');
    if (response.statusCode == 200) {
      _fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
    } else {
      print('Failed to delete product: ${response.statusCode}');
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _priceController.clear();
    _quantityController.clear();
    setState(() {
      _imageUrl = '';
      _currentProductId = null;
    });
  }

  void _populateForm(Product product) {
    setState(() {
      _nameController.text = product.name;
      _imageUrl = product.imageUrl;
      _priceController.text = product.price.toString();
      _quantityController.text = product.quantity.toString();
      _currentProductId = product.id;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Daur Ulang'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product name';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Image URL'),
                    value: _imageUrl.isNotEmpty ? _imageUrl : null,
                    items: _imageUrls.map((String url) {
                      return DropdownMenuItem<String>(
                        value: url,
                        child: Text(url),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _imageUrl = newValue!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an image URL';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          double.tryParse(value) == null) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null) {
                        return 'Please enter a valid quantity';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addOrUpdateProduct,
                    child: Text(_currentProductId == null
                        ? 'Add Product'
                        : 'Update Product'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
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
                          child: product.imageUrl.startsWith('http')
                              ? Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  product.imageUrl.replaceFirst('file://', ''),
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
                              style: TextStyle(
                                  color: Color.fromRGBO(48, 133, 195, 1)),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    print(
                                        'Edit button pressed for ${product.name}');
                                    _populateForm(product);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteProduct(product.id),
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
          ],
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }
}
