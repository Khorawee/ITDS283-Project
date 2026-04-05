// lib/pages/ContactUsPage.dart  [UPDATED — ใส่รูป dev1.png / dev2.png]

import 'package:flutter/material.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  static const Color primaryGreen = Color(0xFF1DBA78);
  static const Color cardGreen    = Color(0xFF81E3AB);

  final List<Map<String, dynamic>> _developers = const [
    {
      'name':      'Khorawee Suwattanaphan',
      'role':      'Developer',
      'image':     'assets/images/dev1.png',
      'instagram': 'ffiw_plzjkz',
      'email':     'khorawee.suw@student.mahiidol.edu',
    },
    {
      'name':      'Watcharin Wangsop',
      'role':      'Developer',
      'image':     'assets/images/dev2.png',
      'instagram': 'kvnd_12',
      'email':     'watcharin.wag@student.mahiidol.edu',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CONTACT US',
          style: TextStyle(
            color: primaryGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: _developers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 32),
        itemBuilder: (_, i) => _buildDevCard(_developers[i]),
      ),
    );
  }

  Widget _buildDevCard(Map<String, dynamic> dev) {
    return Column(
      children: [
        // Avatar — แสดงรูป dev1.png / dev2.png
        Container(
          width: 110,
          height: 130,
          decoration: BoxDecoration(
            color: cardGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              dev['image'] as String,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person, size: 60, color: primaryGreen),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Name + Role
        Text(
          dev['name'] as String,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          dev['role'] as String,
          style: const TextStyle(fontSize: 13, color: Colors.black45),
        ),

        const SizedBox(height: 14),

        // Contact card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildContactRow(
                icon: Icons.camera_alt_outlined,
                text: ': ${dev['instagram']}',
              ),
              const SizedBox(height: 12),
              _buildContactRow(
                icon: Icons.mail_outline,
                text: ': ${dev['email']}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}