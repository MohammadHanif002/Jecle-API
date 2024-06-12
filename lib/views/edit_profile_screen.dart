import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jecle/views/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      if (idToken == null || idToken.isEmpty) {
        // Handle the case where the token is missing
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen()), // Adjust this as needed
        );
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://jeclebase-8fe6f-default-rtdb.firebaseio.com/users/$userId.json'),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body);
        setState(() {
          nameController.text = userData['name'] ?? '';
          phoneController.text = userData['phone'] ?? '';
          addressController.text = userData['address'] ?? '';
          cityController.text = userData['city'] ?? '';
          postalCodeController.text = userData['postalCode'] ?? '';
          ageController.text = userData['age'] ?? '';
          genderController.text = userData['gender'] ?? '';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  Future<String> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference ref =
          FirebaseStorage.instance.ref().child('images/$fileName.jpg');
      await ref.putFile(imageFile);
      String imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return '';
    }
  }

  void _handleSaveButtonPressed() async {
    String imageUrl = '';
    if (_image != null) {
      imageUrl = await uploadImageToFirebaseStorage(_image!);
    }
    await _saveDataToFirebase(imageUrl);
  }

  Future<void> _saveDataToFirebase(String imageUrl) async {
    String name = nameController.text;
    String phone = phoneController.text;
    String address = addressController.text;
    String city = cityController.text;
    String postalCode = postalCodeController.text;
    int age = int.tryParse(ageController.text) ?? 0;
    String gender = genderController.text;

    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();

      if (userId != null && idToken != null && idToken.isNotEmpty) {
        final response = await http.patch(
          Uri.parse(
              'https://jeclebase-8fe6f-default-rtdb.firebaseio.com/users/$userId.json'),
          body: jsonEncode({
            'name': name,
            'phone': phone,
            'address': address,
            'city': city,
            'postalCode': postalCode,
            'age': age,
            'gender': gender,
            if (imageUrl.isNotEmpty) 'profileImage': imageUrl,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Data successfully saved to Firebase')));
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save data: ${response.body}')));
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(48, 133, 195, 1),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          iconSize: 24,
        ),
        toolbarHeight: 40.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 0, right: 0),
              width: w,
              height: h * 0.3,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/top_background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: h * 0.05),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: w * 0.15,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(Icons.camera_alt, size: w * 0.1)
                        : null,
                  ),
                ),
                SizedBox(height: h * 0.02),
                Text(
                  'Nama Pengguna',
                  style: TextStyle(
                      fontSize: w * 0.08, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: h * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Nama'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                  child: TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'Nomor HP'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                  child: TextField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: 'Alamat'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                  child: TextField(
                    controller: cityController,
                    decoration: InputDecoration(labelText: 'Kota'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                  child: TextField(
                    controller: postalCodeController,
                    decoration: InputDecoration(labelText: 'Kode Pos'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                  child: TextField(
                    controller: ageController,
                    decoration: InputDecoration(labelText: 'Usia'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                  child: TextField(
                    controller: genderController,
                    decoration: InputDecoration(labelText: 'Jenis Kelamin'),
                  ),
                ),
                SizedBox(height: h * 0.03),
                Container(
                  width: w * 0.4,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 3, 123, 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _handleSaveButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 3, 123, 3),
                    ),
                    child: Text(
                      'Simpan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 0, right: 0),
              width: w,
              height: h * 0.3,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bottom_background.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
