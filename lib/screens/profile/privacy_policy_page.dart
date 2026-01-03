import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Kebijakan Privasi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.privacy_tip_outlined, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Kebijakan Privasi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Terakhir diperbarui: 12 Desember 2024',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Konten Kebijakan
            Container(
              padding: const EdgeInsets.all(20),
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
                  _buildSection(
                    title: '1. Informasi yang Kami Kumpulkan',
                    content: 'Kami mengumpulkan informasi yang Anda berikan secara langsung:\n\n'
                        '• Data akun (nama, email)\n'
                        '• Data transaksi keuangan\n'
                        '• Data kategori dan pengeluaran\n'
                        '• Data perangkat (opsional untuk analisis)',
                  ),
                  
                  _buildSection(
                    title: '2. Penggunaan Informasi',
                    content: 'Informasi yang kami kumpulkan digunakan untuk:\n\n'
                        '• Menyediakan dan memelihara layanan\n'
                        '• Meningkatkan pengalaman pengguna\n'
                        '• Menganalisis penggunaan aplikasi\n'
                        '• Mengirim notifikasi penting\n'
                        '• Mencegah aktivitas penipuan',
                  ),
                  
                  _buildSection(
                    title: '3. Penyimpanan Data',
                    content: 'Data Anda disimpan dengan aman di server yang terenkripsi.\n\n'
                        '• Data disimpan selama akun Anda aktif\n'
                        '• Anda dapat meminta penghapusan data kapan saja\n'
                        '• Backup data dilakukan secara berkala',
                  ),
                  
                  _buildSection(
                    title: '4. Keamanan Data',
                    content: 'Kami menerapkan langkah-langkah keamanan yang ketat:\n\n'
                        '• Enkripsi data end-to-end\n'
                        '• Autentikasi dua faktor\n'
                        '• Monitoring keamanan 24/7\n'
                        '• Akses data yang terbatas',
                  ),
                  
                  _buildSection(
                    title: '5. Hak Anda',
                    content: 'Sebagai pengguna, Anda memiliki hak untuk:\n\n'
                        '• Mengakses data pribadi Anda\n'
                        '• Memperbaiki data yang tidak akurat\n'
                        '• Menghapus data pribadi\n'
                        '• Menolak pemrosesan data tertentu\n'
                        '• Mengekspor data Anda',
                  ),
                  
                  _buildSection(
                    title: '6. Pembaruan Kebijakan',
                    content: 'Kami dapat memperbarui kebijakan privasi ini dari waktu ke waktu. '
                        'Perubahan akan diberitahukan melalui aplikasi atau email.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Persetujuan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 Persetujuan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Dengan menggunakan aplikasi MoneyKu, Anda menyetujui pengumpulan '
                    'dan penggunaan informasi sesuai dengan kebijakan privasi ini.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Kontak
            Container(
              padding: const EdgeInsets.all(16),
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
                  const Text(
                    'Pertanyaan atau Masalah?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Jika Anda memiliki pertanyaan tentang kebijakan privasi kami, '
                    'silahkan hubungi kami melalui:',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _buildContactInfo(Icons.email_outlined, 'privacy@moneyku.app'),
                  _buildContactInfo(Icons.phone_outlined, '+62 812-3456-7890'),
                  _buildContactInfo(Icons.location_on_outlined, 'Jakarta, Indonesia'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Kembali ke Profil'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A73E8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1A73E8), size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}