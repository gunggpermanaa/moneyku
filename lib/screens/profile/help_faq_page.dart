import 'package:flutter/material.dart';

class HelpFAQPage extends StatefulWidget {
  const HelpFAQPage({super.key});

  @override
  State<HelpFAQPage> createState() => _HelpFAQPageState();
}

class _HelpFAQPageState extends State<HelpFAQPage> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'Bagaimana cara menambah transaksi baru?',
      answer: 'Untuk menambah transaksi baru:\n1. Buka halaman utama\n2. Tap tombol "+" di pojok kanan bawah\n3. Pilih jenis transaksi (Pendapatan/Pengeluaran)\n4. Isi detail transaksi\n5. Tap "Simpan"',
    ),
    FAQItem(
      question: 'Bisakah mengedit atau menghapus transaksi?',
      answer: 'Ya, Anda bisa:\n• Edit: Tap dan tahan transaksi, lalu pilih "Edit"\n• Hapus: Geser transaksi ke kiri atau kanan',
    ),
    FAQItem(
      question: 'Bagaimana cara mengubah kategori?',
      answer: 'Buka halaman Profil → Pengaturan → Kelola Kategori. Di sana Anda bisa menambah, edit, atau menghapus kategori.',
    ),
    FAQItem(
      question: 'Apakah data saya aman?',
      answer: 'Ya, data Anda disimpan dengan aman di server yang terenkripsi dan hanya bisa diakses oleh Anda.',
    ),
    FAQItem(
      question: 'Bagaimana cara backup data?',
      answer: 'Gunakan fitur Export Data di halaman Profil → Pengaturan → Export Data untuk mengekspor data ke file PDF/Excel/CSV.',
    ),
    FAQItem(
      question: 'Bisakah menggunakan di beberapa perangkat?',
      answer: 'Ya, login dengan akun yang sama di beberapa perangkat untuk sinkronisasi data otomatis.',
    ),
    FAQItem(
      question: 'Bagaimana cara reset password?',
      answer: 'Buka halaman Profil → Akun → Ubah Password untuk mengganti password Anda.',
    ),
  ];

  final List<String> _contactMethods = [
    'Email: support@moneyku.app',
    'Telepon: +62 812-3456-7890',
    'Jam Operasional: Senin-Jumat, 09:00-17:00 WIB',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Bantuan & FAQ'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pencarian
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari bantuan...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: (value) {
                  // Implement search functionality here
                },
              ),
            ),

            const SizedBox(height: 24),

            // FAQ List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Text(
                      'Pertanyaan Umum',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ..._faqItems.map((faq) => _buildFAQItem(faq)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Kontak Support
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.support_agent, color: Color(0xFF1A73E8)),
                        SizedBox(width: 12),
                        Text(
                          'Hubungi Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._contactMethods.map((method) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1A73E8),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(method)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Aksi kirim email
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Membuka aplikasi email...'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.email_outlined),
                        label: const Text('Kirim Email'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Tips & Saran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Catat semua transaksi secara rutin\n'
                    '• Review laporan bulanan secara berkala\n'
                    '• Gunakan kategori yang spesifik\n'
                    '• Setel anggaran untuk pengeluaran\n'
                    '• Backup data secara berkala',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        faq.question,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            faq.answer,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}