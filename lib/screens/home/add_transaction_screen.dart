import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/transaction_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final String? initialType; // 'income' atau 'expense'
  final Map<String, dynamic>? transactionToEdit; // Data untuk diedit

  const AddTransactionScreen({
    super.key,
    this.initialType,
    this.transactionToEdit,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _service = TransactionService();

  String _selectedType = 'expense';
  String _selectedCategory = 'Makanan';
  bool _isLoading = false;
  bool _isEditing = false;

  // Daftar Kategori (Disamakan dengan ManageCategoriesPage)
  final List<String> _incomeCategories = [
    'Gaji', 'Freelance', 'Investasi', 'Bonus', 'Hadiah', 'Lainnya',
  ];

  final List<String> _expenseCategories = [
    'Makanan', 'Transport', 'Belanja', 'Tagihan', 'Hiburan', 
    'Kesehatan', 'Pendidikan', 'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    
    // Cek apakah mode Edit
    if (widget.transactionToEdit != null) {
      _isEditing = true;
      final t = widget.transactionToEdit!;
      _selectedType = t['type'];
      _selectedCategory = t['category'];
      _noteController.text = t['note'] ?? '';
      
      // Format amount ke string rupiah (misal: 50.000)
      final amount = (t['amount'] as num).toInt();
      _amountController.text = NumberFormat('#,###', 'id_ID').format(amount).replaceAll(',', '.');
    } else {
      // Mode Tambah Baru
      if (widget.initialType != null) {
        _selectedType = widget.initialType!;
      }
      _selectedCategory = _selectedType == 'income'
          ? _incomeCategories.first
          : _expenseCategories.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<String> get _currentCategories =>
      _selectedType == 'income' ? _incomeCategories : _expenseCategories;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String cleanAmount = _amountController.text.replaceAll('.', '');
      final double amount = double.parse(cleanAmount);

      if (_isEditing) {
        // --- LOGIKA UPDATE ---
        await _service.updateTransaction(
          widget.transactionToEdit!['id'], // Pastikan ID dikirim
          type: _selectedType,
          category: _selectedCategory,
          amount: amount,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );
      } else {
        // --- LOGIKA TAMBAH BARU ---
        await _service.addTransaction(
          type: _selectedType,
          category: _selectedCategory,
          amount: amount,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Transaksi berhasil diubah!' : 'Transaksi berhasil disimpan!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true); // Kembali dan refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(number).replaceAll(',', '.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaksi' : 'Tambah Transaksi'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A73E8),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeButton(
                        label: 'Pemasukan',
                        value: 'income',
                        icon: Icons.arrow_downward,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTypeButton(
                        label: 'Pengeluaran',
                        value: 'expense',
                        icon: Icons.arrow_upward,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amount Input
              const Text('Jumlah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rp', style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.w500)),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1A73E8)),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final formatted = _formatCurrency(value);
                          if (formatted != value) {
                            _amountController.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(offset: formatted.length),
                            );
                          }
                        }
                      },
                      validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category Selector
              const Text('Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentCategories.contains(_selectedCategory) ? _selectedCategory : _currentCategories.first,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _currentCategories.map((category) {
                      return DropdownMenuItem(value: category, child: Text(category, style: const TextStyle(fontSize: 16)));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value!),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Note Input
              const Text('Catatan (Opsional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tambahkan catatan...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType == 'income' ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Transaksi', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton({required String label, required String value, required IconData icon, required Color color}) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
          _selectedCategory = value == 'income' ? _incomeCategories.first : _expenseCategories.first;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}