import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaldoScreen extends StatefulWidget {
  @override
  _SaldoScreenState createState() => _SaldoScreenState();
}

class _SaldoScreenState extends State<SaldoScreen> {
  final TextEditingController _saldoController = TextEditingController();
  double _dompet = 0.0;
  double _saldo = 0.0;
  late User _user;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
      });
      await _loadDompet(user.uid);
    } else {
      print('No user is currently signed in.');
    }
  }

  Future<void> _loadDompet(String userId) async {
    final url = Uri.https(
        'jeclebase-8fe6f-default-rtdb.firebaseio.com', '/users/$userId.json');
    try {
      print('Fetching dompet data for userId: $userId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _dompet = (responseData['dompet'] ?? 0.0).toDouble();
          _saldo = (responseData['saldo'] ?? 0.0).toDouble();
        });
        print('Dompet data loaded: $_dompet');
        print('Saldo data loaded: $_saldo');
      } else {
        print('Failed to load dompet & saldo: ${response.statusCode}');
      }
    } catch (error) {
      print('Error loading dompet & saldo: $error');
    }
  }

  void _saveSaldo() async {
    double saldo = double.tryParse(_saldoController.text) ?? 0.0;
    print('Attempting to save saldo: $saldo');
    if (saldo <= _dompet) {
      double newDompet = _dompet - saldo;
      double newSaldo = _saldo + saldo;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('dompet', newDompet);
      await prefs.setDouble('saldo', newSaldo);
      await _updateBalanceOnServer(newDompet, newSaldo);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saldo berhasil diperbarui')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saldo melebihi jumlah uang di dompet')),
      );
    }
  }

  Future<void> _updateBalanceOnServer(double newDompet, double newSaldo) async {
    final url = Uri.https('jeclebase-8fe6f-default-rtdb.firebaseio.com', '/users/${_user.uid}.json');
    try {
      print('Updating balance on server to: dompet - $newDompet, saldo - $newSaldo');
      final response = await http.patch(
        url,
        body: json.encode({
          'dompet': newDompet,
          'saldo': newSaldo,
        }),
      );
      if (response.statusCode == 200) {
        print('Balance updated on server');
      } else {
        print('Failed to update balance on server: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating balance: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Isi Saldo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Uang di Dompet: Rp ${_dompet.toStringAsFixed(0)}'),
            TextField(
              controller: _saldoController,
              decoration: InputDecoration(labelText: 'Masukkan Saldo'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveSaldo,
              child: Text('Simpan Saldo'),
            ),
          ],
        ),
      ),
    );
  }
}
