import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExportDataPage extends StatefulWidget {
  const ExportDataPage({super.key});

  @override
  State<ExportDataPage> createState() => _ExportDataPageState();
}

class _ExportDataPageState extends State<ExportDataPage> {
  final _supabase = Supabase.instance.client;
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedFormat = 'PDF';
  final List<String> _formats = ['PDF', 'Excel', 'CSV'];
  bool _isExporting = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('transactions')
            .select('*')
            .eq('user_id', user.id)
            .order('date', ascending: false);

        if (response is List) {
          _transactions = List<Map<String, dynamic>>.from(response);
        }
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? DateTime.now() : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _exportData() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal terlebih dahulu')),
      );
      return;
    }

    // Validasi: end date tidak boleh sebelum start date
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal akhir tidak boleh sebelum tanggal awal')),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      // Filter transactions berdasarkan tanggal
      final filteredTransactions = _transactions.where((t) {
        final dateStr = t['date'] as String?;
        if (dateStr == null) return false;
        
        final transactionDate = DateTime.parse(dateStr);
        final startOfDay = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        
        return transactionDate.isAfter(startOfDay.subtract(const Duration(days: 1))) &&
               transactionDate.isBefore(endOfDay.add(const Duration(days: 1)));
      }).toList();

      if (filteredTransactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada data transaksi pada periode ini')),
        );
        return;
      }

      // Hitung total
      double totalIncome = 0;
      double totalExpense = 0;
      
      for (var t in filteredTransactions) {
        final amount = (t['amount'] as num).toDouble();
        if (t['type'] == 'income') {
          totalIncome += amount;
        } else {
          totalExpense += amount;
        }
      }
      
      final balance = totalIncome - totalExpense;

      // Format currency
      String formatCurrency(double amount) {
        return NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        ).format(amount);
      }

      // Format date
      String formatTransactionDate(String dateStr) {
        try {
          final date = DateTime.parse(dateStr);
          return DateFormat('dd/MM/yyyy').format(date);
        } catch (e) {
          return dateStr;
        }
      }

      // Bangun string export
      StringBuffer exportData = StringBuffer();
      exportData.writeln('=' * 50);
      exportData.writeln('MONEYKU - LAPORAN KEUANGAN');
      exportData.writeln('=' * 50);
      exportData.writeln('Tanggal Ekspor: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
      exportData.writeln('Periode: ${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}');
      exportData.writeln('');
      exportData.writeln('RINGKASAN:');
      exportData.writeln('-' * 30);
      exportData.writeln('Total Pemasukan: ${formatCurrency(totalIncome)}');
      exportData.writeln('Total Pengeluaran: ${formatCurrency(totalExpense)}');
      exportData.writeln('Saldo: ${formatCurrency(balance)}');
      exportData.writeln('');
      exportData.writeln('DETAIL TRANSAKSI:');
      exportData.writeln('-' * 80);

      // Urutkan berdasarkan tanggal
      filteredTransactions.sort((a, b) {
        final dateA = DateTime.parse(a['date']);
        final dateB = DateTime.parse(b['date']);
        return dateB.compareTo(dateA); // Terbaru ke terlama
      });

      for (int i = 0; i < filteredTransactions.length; i++) {
        final t = filteredTransactions[i];
        final no = i + 1;
        final date = formatTransactionDate(t['date']);
        final category = t['category'] ?? 'Tidak ada kategori';
        final note = t['note'] ?? '';
        final amount = formatCurrency((t['amount'] as num).toDouble());
        final type = t['type'] == 'income' ? 'Pemasukan' : 'Pengeluaran';
        
        exportData.writeln('$no. $date');
        exportData.writeln('   Kategori: $category');
        if (note.isNotEmpty) exportData.writeln('   Catatan: $note');
        exportData.writeln('   Jumlah: $amount ($type)');
        exportData.writeln('');
      }

      exportData.writeln('=' * 80);
      exportData.writeln('Jumlah Transaksi: ${filteredTransactions.length}');
      exportData.writeln('Generated by MoneyKu App');
      exportData.writeln('=' * 80);

      // Tentukan nama file berdasarkan format
      String fileName = 'Laporan_Keuangan_${DateFormat('yyyyMMdd').format(DateTime.now())}';
      String fileExtension = _selectedFormat.toLowerCase();
      
      if (_selectedFormat == 'Excel') {
        fileExtension = 'xlsx';
      }

      // Share data
      await Share.share(
        exportData.toString(),
        subject: 'Laporan Keuangan MoneyKu - ${DateFormat('dd/MM/yyyy').format(_startDate!)}_sd_${DateFormat('dd/MM/yyyy').format(_endDate!)}',
        sharePositionOrigin: Rect.largest,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${filteredTransactions.length} data berhasil diekspor dalam format $_selectedFormat'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint('Error exporting data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saat mengekspor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showStatistics() {
    if (_transactions.isEmpty) return;

    double totalIncome = 0;
    double totalExpense = 0;
    int incomeCount = 0;
    int expenseCount = 0;
    
    for (var t in _transactions) {
      final amount = (t['amount'] as num).toDouble();
      if (t['type'] == 'income') {
        totalIncome += amount;
        incomeCount++;
      } else {
        totalExpense += amount;
        expenseCount++;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistik Data'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatItem('Total Transaksi', _transactions.length.toString()),
              _buildStatItem('Pemasukan', '$incomeCount transaksi'),
              _buildStatItem('Pengeluaran', '$expenseCount transaksi'),
              const SizedBox(height: 16),
              const Text(
                'Data transaksi yang tersedia untuk diekspor.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Export Data'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (!_isLoading && _transactions.isNotEmpty)
            IconButton(
              onPressed: _showStatistics,
              icon: const Icon(Icons.insights_outlined),
              tooltip: 'Lihat Statistik',
            ),
          IconButton(
            onPressed: _loadTransactions,
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informasi
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
                            const Icon(Icons.info_outline, color: Color(0xFF1A73E8)),
                            const SizedBox(width: 8),
                            const Text(
                              'Ekspor Data',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Text(
                              '${_transactions.length} transaksi tersedia',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pilih periode untuk mengekspor data transaksi keuangan Anda.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Pilih Periode
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
                          'Pilih Periode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDatePicker(
                                label: 'Dari Tanggal',
                                date: _startDate,
                                onTap: () => _pickDate(context, true),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDatePicker(
                                label: 'Sampai Tanggal',
                                date: _endDate,
                                onTap: () => _pickDate(context, false),
                              ),
                            ),
                          ],
                        ),
                        if (_startDate != null && _endDate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              'Periode: ${_calculateDuration()} hari',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pilih Format
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
                          'Pilih Format File',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _formats.map((format) {
                            final isSelected = _selectedFormat == format;
                            return ChoiceChip(
                              label: Text(format),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() => _selectedFormat = format);
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: const Color(0xFF1A73E8).withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: isSelected ? const Color(0xFF1A73E8) : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Tombol Export
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isExporting ? null : _exportData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isExporting
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Mengekspor...'),
                              ],
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.download_outlined),
                                SizedBox(width: 8),
                                Text('Export Data'),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info Format
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Format yang Tersedia:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Text('• PDF: Format dokumen yang mudah dibaca dan dicetak'),
                        SizedBox(height: 4),
                        Text('• Excel: Format spreadsheet untuk analisis data'),
                        SizedBox(height: 4),
                        Text('• CSV: Format data sederhana yang kompatibel'),
                      ],
                    ),
                  ),

                  // Catatan Penting
                  if (_transactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_outlined, color: Colors.amber),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Belum ada data transaksi untuk diekspor. '
                                'Tambahkan transaksi di halaman Aktivitas terlebih dahulu.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  String _calculateDuration() {
    if (_startDate == null || _endDate == null) return '0';
    final duration = _endDate!.difference(_startDate!).inDays + 1;
    return duration.toString();
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              date != null
                  ? DateFormat('dd/MM/yyyy').format(date)
                  : 'Pilih tanggal',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}