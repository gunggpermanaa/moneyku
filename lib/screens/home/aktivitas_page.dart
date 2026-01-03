import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/transaction_service.dart';
import 'add_transaction_screen.dart';

class AktivitasPage extends StatefulWidget {
  const AktivitasPage({super.key});

  @override
  State<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends State<AktivitasPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- FORMATTING UTILS ---
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String formatDate(dynamic date) {
    try {
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return '';
      }
      return DateFormat('HH:mm', 'id_ID').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  String formatFullDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'id_ID').format(date);
  }

  // --- LOGIKA WARNA & IKON ---
  Color getCategoryColor(String category) {
    final colors = {
      'Makanan': Colors.orange,
      'Transport': Colors.blue,
      'Transportasi': Colors.blue,
      'Belanja': Colors.purple,
      'Tagihan': Colors.red,
      'Hiburan': Colors.pink,
      'Kesehatan': Colors.green,
      'Pendidikan': Colors.indigo,
      'Gaji': Colors.teal,
      'Freelance': Colors.cyan,
      'Investasi': Colors.amber,
      'Bonus': Colors.lightGreen,
      'Hadiah': Colors.lime,
      'Lainnya': Colors.grey,
    };
    return colors[category] ?? Colors.grey[700]!;
  }

  IconData getCategoryIcon(String category) {
    final icons = {
      'Makanan': Icons.restaurant,
      'Transport': Icons.directions_car,
      'Transportasi': Icons.directions_car,
      'Belanja': Icons.shopping_bag,
      'Tagihan': Icons.receipt_long,
      'Hiburan': Icons.movie,
      'Kesehatan': Icons.medical_services,
      'Pendidikan': Icons.school,
      'Gaji': Icons.account_balance_wallet,
      'Freelance': Icons.work,
      'Investasi': Icons.trending_up,
      'Bonus': Icons.card_giftcard,
      'Hadiah': Icons.gif,
      'Lainnya': Icons.category,
    };
    return icons[category] ?? Icons.category;
  }

  // --- LOGIKA FILTER & SEARCH ---
  List<Map<String, dynamic>> _processData(List<Map<String, dynamic>> data) {
    // 1. Filter by Type (Income/Expense)
    var filtered = data;
    if (_selectedFilter != 'Semua') {
      final isIncome = _selectedFilter == 'Pemasukan';
      filtered = filtered.where((t) {
        final type = t['type'].toString().toLowerCase();
        return isIncome ? 
          (type == 'income' || type == 'pemasukan') : 
          (type == 'expense' || type == 'pengeluaran');
      }).toList();
    }

    // 2. Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        final category = t['category'].toString().toLowerCase();
        final note = (t['note'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return category.contains(query) || note.contains(query);
      }).toList();
    }

    // 3. Sort by Date (terbaru dulu)
    filtered.sort((a, b) {
      try {
        final dateA = DateTime.parse(a['date']);
        final dateB = DateTime.parse(b['date']);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    return filtered;
  }

  Map<String, List<Map<String, dynamic>>> _groupByDate(List<Map<String, dynamic>> data) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (var t in data) {
      try {
        DateTime date = (t['date'] is String) ? DateTime.parse(t['date']) : t['date'];
        final displayDate = _getDisplayDate(date);
        if (!grouped.containsKey(displayDate)) grouped[displayDate] = [];
        grouped[displayDate]!.add(t);
      } catch (e) {
        // Skip data dengan format tanggal tidak valid
        debugPrint('Error parsing date: ${t['date']}');
      }
    }
    
    // Sort tanggal (terbaru dulu)
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'Hari Ini') return -1;
        if (b == 'Hari Ini') return 1;
        if (a == 'Kemarin') return -1;
        if (b == 'Kemarin') return 1;
        return 0;
      });
    
    final sortedMap = <String, List<Map<String, dynamic>>>{};
    for (var key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }
    
    return sortedMap;
  }

  String _getDisplayDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) return 'Hari Ini';
    if (transactionDate == yesterday) return 'Kemarin';
    
    // Untuk minggu ini
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    if (transactionDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        transactionDate.isBefore(weekEnd.add(const Duration(days: 1)))) {
      return DateFormat('EEEE', 'id_ID').format(date);
    }
    
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  // --- FUNGSI AKSI ---
  void _editTransaction(Map<String, dynamic> transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(transactionToEdit: transaction),
      ),
    );
  }

  Future<void> _deleteTransaction(String id, TransactionService service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await service.delete(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus transaksi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    final isIncome = transaction['type'].toString().toLowerCase() == 'income' || 
                     transaction['type'].toString().toLowerCase() == 'pemasukan';
    final amount = double.tryParse(transaction['amount'].toString()) ?? 0;
    final category = transaction['category']?.toString() ?? 'Lainnya';
    final note = transaction['note']?.toString() ?? '-';
    String dateStr = '';
    
    try {
      final date = DateTime.parse(transaction['date']);
      dateStr = DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(date);
    } catch (e) {
      dateStr = transaction['date']?.toString() ?? '-';
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Icon dan Kategori
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: getCategoryColor(category).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      getCategoryIcon(category),
                      color: getCategoryColor(category),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isIncome ? 'Pemasukan' : 'Pengeluaran',
                        style: TextStyle(
                          fontSize: 14,
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Detail Transaksi
            _buildDetailRow('Jumlah', formatCurrency(amount)),
            _buildDetailRow('Tanggal', dateStr),
            if (note.isNotEmpty && note != '-')
              _buildDetailRow('Catatan', note),
            
            const SizedBox(height: 32),
            
            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _editTransaction(transaction);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _deleteTransaction(transaction['id'], TransactionService());
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Hapus'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal(List<Map<String, dynamic>> transactions) {
    double total = 0;
    for (var t in transactions) {
      final amount = double.tryParse(t['amount'].toString()) ?? 0;
      final type = t['type'].toString().toLowerCase();
      if (type == 'income' || type == 'pemasukan') {
        total += amount;
      } else {
        total -= amount;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final service = TransactionService();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER & SEARCH ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aktivitas',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A73E8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Cari transaksi...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Semua'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Pemasukan'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Pengeluaran'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- LIST TRANSAKSI ---
            Expanded(
              child: StreamBuilder(
                stream: service.streamTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi kesalahan',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState('Belum ada transaksi');
                  }

                  final processedData = _processData(snapshot.data!);
                  
                  if (processedData.isEmpty) {
                    return _buildEmptyState('Tidak ditemukan transaksi');
                  }

                  final groupedData = _groupByDate(processedData);

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 10, bottom: 80),
                      itemCount: groupedData.length,
                      itemBuilder: (context, index) {
                        final dateKey = groupedData.keys.elementAt(index);
                        final transactions = groupedData[dateKey]!;
                        final dailyTotal = _calculateTotal(transactions);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Tanggal dengan Total
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateKey,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(dailyTotal),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: dailyTotal >= 0 ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Daftar Transaksi
                            ...transactions.map((t) => _buildTransactionItem(t, service)),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, 
              size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddTransactionScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Transaksi Pertama'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    Color color = const Color(0xFF1A73E8);
    if (label == 'Pemasukan') color = Colors.green;
    if (label == 'Pengeluaran') color = Colors.red;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction, TransactionService service) {
    final isIncome = transaction['type'].toString().toLowerCase() == 'income' ||
                    transaction['type'].toString().toLowerCase() == 'pemasukan';
    final amount = double.tryParse(transaction['amount'].toString()) ?? 0;
    final category = transaction['category']?.toString() ?? 'Lainnya';
    final note = transaction['note'] as String? ?? '';
    final date = transaction['date'];

    return GestureDetector(
      onTap: () => _showTransactionDetails(transaction),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon Kategori
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: getCategoryColor(category).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    getCategoryIcon(category),
                    color: getCategoryColor(category),
                    size: 24,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Detail Transaksi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        note,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    Text(
                      formatDate(date),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Jumlah dan Menu
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'} ${formatCurrency(amount)}',
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isIncome ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isIncome ? 'Pemasukan' : 'Pengeluaran',
                      style: TextStyle(
                        fontSize: 10,
                        color: isIncome ? Colors.green[700] : Colors.red[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 8),
              
              // Tombol Menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editTransaction(transaction);
                  } else if (value == 'delete') {
                    _deleteTransaction(transaction['id'], service);
                  } else if (value == 'detail') {
                    _showTransactionDetails(transaction);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'detail',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Text('Detail'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.orange, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Hapus'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}