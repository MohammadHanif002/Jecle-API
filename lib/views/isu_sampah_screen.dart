import 'package:flutter/material.dart';

class IsuSampahScreen extends StatelessWidget {
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
        title: Text('Informasi Isu Sampah'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 100, // Sesuaikan dengan tinggi background yang diinginkan
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage('assets/images/background informasi sampah.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                IsuSampahItem(
                  title: 'Berbagai Isu Pengelolaan Sampah di Indonesia',
                  source: 'Universitas Jember',
                  date: '10 Oktober, 2020',
                  description:
                      'Berbagai konsep dan informasi penting dan mutakhir terkait pengolahan dan pengelolaan sampah di Indonesia diperkenalkan dan dipaparkan oleh ....',
                ),
                IsuSampahItem(
                  title:
                      'Tiga Permasalahan Mendasar Sampah yang Tidak Kunjung Selesai',
                  source: 'Kompas.id',
                  date: '7 April, 2023',
                  description:
                      'Sampah terus menjadi masalah meski banyak inovasi dalam pengelolaannya. Sampah kantong plastik dan kemasan produk kebutuhan sehari-hari ...',
                ),
                // Tambahkan item lainnya jika diperlukan
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IsuSampahItem extends StatelessWidget {
  final String title;
  final String source;
  final String date;
  final String description;

  const IsuSampahItem({
    required this.title,
    required this.source,
    required this.date,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            source,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(description),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                // Implementasi logika untuk baca selengkapnya
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(48, 133, 195, 1),
              ),
              child: Text(
                'Baca selengkapnya >>>',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
