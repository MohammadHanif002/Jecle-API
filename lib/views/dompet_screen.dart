import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DompetScreen extends StatefulWidget {
  @override
  _DompetScreenState createState() => _DompetScreenState();
}

class _DompetScreenState extends State<DompetScreen> {
  final TextEditingController _dompetController = TextEditingController();

  void _saveDompet() async {
    if (_dompetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi nominal')),
      );
      return;
    }

    double newDompetAmount = double.tryParse(_dompetController.text) ?? 0.0;
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      double currentDompetAmount = await _fetchCurrentDompetAmount(userId);

      double updatedDompetAmount = currentDompetAmount + newDompetAmount;

      bool success =
          await _updateUserDompetOnServer(userId, updatedDompetAmount);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dompet berhasil diperbarui')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui dompet di server')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal memperbarui dompet, user tidak ditemukan')),
      );
    }
  }

  Future<double> _fetchCurrentDompetAmount(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://jeclebase-8fe6f-default-rtdb.firebaseio.com/users/$userId.json'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body);
        return (userData['dompet'] ?? 0.0).toDouble();
      } else {
        print('Failed to fetch current wallet amount: ${response.statusCode}');
        return 0.0;
      }
    } catch (error) {
      print('Error fetching current wallet amount: $error');
      return 0.0;
    }
  }

  Future<bool> _updateUserDompetOnServer(String userId, double dompet) async {
    try {
      final response = await http.patch(
        Uri.parse(
            'https://jeclebase-8fe6f-default-rtdb.firebaseio.com/users/$userId.json'), // Update with your actual API URL
        body: jsonEncode({'dompet': dompet}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update wallet on server: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Error updating wallet on server: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Isi Dompet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _dompetController,
              decoration: InputDecoration(labelText: 'Masukkan Uang ke Dompet'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveDompet,
              child: Text('Simpan ke Dompet'),
            ),
          ],
        ),
      ),
    );
  }
}
