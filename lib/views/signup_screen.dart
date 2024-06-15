import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jecle/views/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  Future<String?> _signUp(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print('User UID: ${userCredential.user?.uid}');

      await _saveUserInfo(userCredential.user?.uid);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );
      return null; // Registration successful, no error message
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
      return e.toString(); // Return the error message
    }
  }

  Future<void> _saveUserInfo(String? uid) async {
    if (uid == null) {
      throw Exception('User UID is null');
    }

    final url = Uri.parse(
        'https://jeclebase-8fe6f-default-rtdb.firebaseio.com/users/$uid.json');
    final response = await http.put(
      url,
      body: json.encode({
        'address': _addressController.text,
        'age': _ageController.text,
        'city': _cityController.text,
        'gender': _genderController.text,
        'name': _usernameController.text,
        'phone': _phoneController.text,
        'postalCode': _postalCodeController.text,
        'profileImage': '',
        'dompet': 0,
        'saldo': 0
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save user info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(20, 30, 70, 1),
                  Color(0xFF3085C3),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(1.0),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Create Account',
                            style: TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                    _buildTextField(
                        'Username', _usernameController, Icons.person),
                    _buildTextField('Email', _emailController, Icons.email),
                    _buildTextField('Password', _passwordController, Icons.lock,
                        obscureText: true),
                    _buildTextField(
                        'Address', _addressController, Icons.location_on),
                    _buildTextField(
                        'City', _cityController, Icons.location_city),
                    _buildTextField(
                        'Gender', _genderController, Icons.person_outline),
                    _buildTextField('Phone', _phoneController, Icons.phone),
                    _buildTextField(
                        'Postal Code', _postalCodeController, Icons.code),
                    _buildTextField('Age', _ageController, Icons.cake),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(48, 133, 195, 1),
                          padding: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 50.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        onPressed: () async {
                          String? errorMessage = await _signUp(context);
                          if (errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Registration failed: $errorMessage')),
                            );
                          }
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'By continue you agree to our',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Terms & Privacy Policy',
                            style: TextStyle(color: Color(0xFF3085C3)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[300],
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
