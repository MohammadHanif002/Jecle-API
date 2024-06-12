import 'package:flutter/material.dart';
import 'package:jecle/views/daur_ulang_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jecle/views/home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutScreen extends StatefulWidget {
  final List<Product> cart;
  final double saldo;

  CheckoutScreen({required this.cart, required this.saldo});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    total =
        widget.cart.fold(0, (sum, item) => sum + item.price * item.quantity);
    _fetchCart();
  }

  void _fetchCart() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://jeclebase-8fe6f-default-rtdb.firebaseio.com/cart.json'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<Product> fetchedCart = [];
        data.forEach((key, value) {
          final product = Product(
            id: key,
            name: value['name'],
            imageUrl: value['imageUrl'],
            price: value['price'].toDouble(),
            quantity: value['quantity'],
          );
          fetchedCart.add(product);
        });

        setState(() {
          widget.cart.clear();
          widget.cart.addAll(fetchedCart);
          total = widget.cart
              .fold(0, (sum, item) => sum + item.price * item.quantity);
        });
      } else {
        print('Failed to fetch cart: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching cart: $error');
    }
  }

  void increaseQuantity(Product product) async {
    setState(() {
      product.quantity += 1;
      total += product.price;
    });
    // await _updateProductQuantity(product);
  }

  void decreaseQuantity(Product product) async {
    setState(() {
      if (product.quantity > 1) {
        product.quantity -= 1;
        total -= product.price;
      } else {
        widget.cart.remove(product);
        total -= product.price;
      }
    });
    // await _updateProductQuantity(product);
  }

  // Future<void> _updateProductQuantity(Product product) async {
  //   try {
  //     await http.put(
  //       Uri.parse('https://jeclebase-8fe6f-default-rtdb.firebaseio.com/cart/${product.id}.json'),
  //       body: jsonEncode({
  //         'name': product.name,
  //         'imageUrl': product.imageUrl,
  //         'price': product.price,
  //         'quantity': product.quantity,
  //       }),
  //     );
  //   } catch (error) {
  //     print('Error updating product quantity: $error');
  //   }
  // }

  void _deleteCart(Product product) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://jeclebase-8fe6f-default-rtdb.firebaseio.com/cart/${product.id}.json'),
      );

      if (response.statusCode == 200) {
        setState(() {
          widget.cart.remove(product);
          total -= product.price * product.quantity;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item berhasil dihapus dari keranjang')),
        );
      } else {
        print('Failed to delete item from cart: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting item from cart: $error');
    }
  }

  Future<void> _clearCartOnServer() async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://jeclebase-8fe6f-default-rtdb.firebaseio.com/cart.json'),
      );

      if (response.statusCode == 200) {
        print('Cart successfully cleared on server');
      } else {
        print('Failed to clear cart on server: ${response.statusCode}');
      }
    } catch (error) {
      print('Error clearing cart on server: $error');
    }
  }

  void completeCheckout() async {
    if (widget.saldo < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saldo tidak mencukupi!')),
      );
      return;
    }

    double newSaldo = widget.saldo - total;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('saldo', newSaldo);

    await _clearCartOnServer();

    setState(() {
      widget.cart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checkout berhasil!')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.cart.length,
                itemBuilder: (context, index) {
                  final product = widget.cart[index];
                  return ListTile(
                    leading:
                        Image.asset(product.imageUrl, width: 50, height: 50),
                    title: Text(product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rp. ${product.price.toStringAsFixed(0)}'),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle),
                              onPressed: () {
                                decreaseQuantity(product);
                              },
                            ),
                            Text('${product.quantity}'),
                            IconButton(
                              icon: Icon(Icons.add_circle),
                              onPressed: () {
                                increaseQuantity(product);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteCart(product);
                      },
                    ),
                  );
                },
              ),
            ),
            Text('Total: Rp. ${total.toStringAsFixed(0)}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: completeCheckout,
              child: Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
