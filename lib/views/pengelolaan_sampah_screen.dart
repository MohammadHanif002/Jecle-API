import 'package:flutter/material.dart';

class PengelolaanSampahScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panduan Pengelolaan Sampah'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SampahOption(
            title: 'Tata Cara Pemilahan Sampah',
            description:
                'Berikut adalah sedikit panduan mengenai cara memilah sampah dari Go-Trash.',
            icon: Icons.recycling,
            onTap: () {
              // Navigate to the detail screen or show more information
            },
          ),
          SampahOption(
            title: 'Pemanfaatan Sampah Anorganik',
            description:
                'Berikut adalah rekomendasi bagaimana cara kita memanfaatkan sampah anorganik.',
            icon: Icons.delete,
            onTap: () {
              // Navigate to the detail screen or show more information
            },
          ),
          SampahOption(
            title: 'Pemanfaatan Sampah Organik',
            description:
                'Berikut adalah rekomendasi bagaimana cara kita memanfaatkan sampah organik.',
            icon: Icons.eco,
            onTap: () {
              // Navigate to the detail screen or show more information
            },
          ),
          SampahOption(
            title: 'Pentingnya Daur Ulang Sampah',
            description:
                'Berikut adalah rekomendasi bagaimana cara kita memanfaatkan sampah anorganik.',
            icon: Icons.autorenew,
            onTap: () {
              // Navigate to the detail screen or show more information
            },
          ),
        ],
      ),
    );
  }
}

class SampahOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const SampahOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 40.0, color: Colors.blue),
        title: Text(title),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}
