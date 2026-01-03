import 'package:flutter/material.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  // Daftar Kategori Pemasukan
  final List<Map<String, dynamic>> _incomeCategories = [
    {
      'name': 'Gaji',
      'icon': '💰',
      'color': Colors.green,
      'description': 'Penghasilan tetap dari pekerjaan tetap'
    },
    {
      'name': 'Freelance',
      'icon': '💼',
      'color': Colors.teal,
      'description': 'Penghasilan dari proyek sampingan atau kerja lepas'
    },
    {
      'name': 'Investasi',
      'icon': '📈',
      'color': Colors.lightGreen,
      'description': 'Keuntungan dari investasi saham, reksadana, atau properti'
    },
    {
      'name': 'Bonus',
      'icon': '🎁',
      'color': Colors.greenAccent,
      'description': 'Tambahan penghasilan di luar gaji pokok'
    },
    {
      'name': 'Hadiah',
      'icon': '🎯',
      'color': Colors.lime,
      'description': 'Uang atau barang yang diterima sebagai hadiah'
    },
    {
      'name': 'Lainnya',
      'icon': '📦',
      'color': Colors.blueGrey,
      'description': 'Pemasukan lain yang tidak termasuk kategori di atas'
    },
  ];

  // Daftar Kategori Pengeluaran
  final List<Map<String, dynamic>> _expenseCategories = [
    {
      'name': 'Makanan',
      'icon': '🍔',
      'color': Colors.orange,
      'description': 'Pengeluaran untuk makan dan minum sehari-hari'
    },
    {
      'name': 'Transport',
      'icon': '🚗',
      'color': Colors.blue,
      'description': 'Biaya transportasi seperti bensin, tiket, atau ojek online'
    },
    {
      'name': 'Belanja',
      'icon': '🛍️',
      'color': Colors.pink,
      'description': 'Pembelian barang kebutuhan atau keinginan'
    },
    {
      'name': 'Tagihan',
      'icon': '💡',
      'color': Colors.red,
      'description': 'Pembayaran rutin seperti listrik, air, internet, dll'
    },
    {
      'name': 'Hiburan',
      'icon': '🎬',
      'color': Colors.purple,
      'description': 'Pengeluaran untuk rekreasi dan hiburan'
    },
    {
      'name': 'Kesehatan',
      'icon': '💊',
      'color': Colors.green,
      'description': 'Biaya kesehatan, obat-obatan, atau pemeriksaan medis'
    },
    {
      'name': 'Pendidikan',
      'icon': '📚',
      'color': Colors.indigo,
      'description': 'Biaya sekolah, kursus, buku, atau alat tulis'
    },
    {
      'name': 'Lainnya',
      'icon': '📦',
      'color': Colors.grey,
      'description': 'Pengeluaran lain yang tidak termasuk kategori di atas'
    },
  ];

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Kategori Transaksi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Informasi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A73E8).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A73E8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.category_outlined, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Kategori Transaksi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kategori yang tersedia untuk mengelompokkan transaksi Anda.',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('Pemasukan', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 16),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('Pengeluaran', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Kategori Pemasukan
            _buildCategorySection(
              title: 'Pemasukan',
              categories: _incomeCategories,
              isIncome: true,
            ),

            const SizedBox(height: 24),

            // Kategori Pengeluaran
            _buildCategorySection(
              title: 'Pengeluaran',
              categories: _expenseCategories,
              isIncome: false,
            ),

            const SizedBox(height: 32),

            // Panduan Penggunaan Kategori
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
                  const Row(
                    children: [
                      Icon(Icons.help_outline, color: Color(0xFF1A73E8)),
                      SizedBox(width: 8),
                      Text(
                        'Panduan Penggunaan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildGuideItem(
                    '1. Pilih kategori yang sesuai',
                    'Pilih kategori yang paling tepat untuk setiap transaksi Anda',
                  ),
                  _buildGuideItem(
                    '2. Konsisten dalam pengelompokan',
                    'Gunakan kategori yang sama untuk transaksi sejenis',
                  ),
                  _buildGuideItem(
                    '3. Gunakan "Lainnya" jika tidak ada',
                    'Jika tidak ada kategori yang cocok, gunakan "Lainnya"',
                  ),
                  _buildGuideItem(
                    '4. Analisis laporan kategori',
                    'Lihat laporan untuk mengetahui pengeluaran terbesar',
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

  Widget _buildCategorySection({
    required String title,
    required List<Map<String, dynamic>> categories,
    required bool isIncome,
  }) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isIncome ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    '${categories.length} kategori',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: isIncome ? Colors.green[50] : Colors.red[50],
                  labelStyle: TextStyle(
                    color: isIncome ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ],
            ),
          ),
          ...categories.map((category) => _buildCategoryItem(category, isIncome)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category, bool isIncome) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Card(
        elevation: 0,
        color: Colors.grey[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (category['color'] as Color).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                category['icon'],
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          title: Text(
            category['name'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            category['description'],
            style: const TextStyle(fontSize: 13, color: Colors.black54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isIncome ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isIncome ? 'Pemasukan' : 'Pengeluaran',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isIncome ? Colors.green[800] : Colors.red[800],
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(70, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Penjelasan:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category['description'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isIncome) ...[
                    _buildExampleItem('Contoh: Gaji bulanan dari kantor'),
                    _buildExampleItem('Contoh: Penghasilan dari project freelance'),
                  ] else ...[
                    _buildExampleItem('Contoh: Makan siang di restoran'),
                    _buildExampleItem('Contoh: Beli baju di mall'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Icon(
                Icons.check_circle_outline,
                color: const Color(0xFF1A73E8),
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}