import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final _supabase = Supabase.instance.client;

  // Get current user ID
  String? get _userId => _supabase.auth.currentUser?.id;

  // Stream all transactions (realtime)
Stream<List<Map<String, dynamic>>> streamTransactions() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from(SupabaseConfig.transactionsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId!)
        .order('date', ascending: false)
        .map((data) {
          // DEBUG: Lihat di "Run" tab apakah data ini muncul?
          // print("Data mentah dari Supabase: $data");
          
          // FIX: Gunakan .from() untuk konversi list aman
          return List<Map<String, dynamic>>.from(data);
        });
  }

  // Get all transactions (one time)
  Future<List<TransactionModel>> getTransactions() async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final response = await _supabase
        .from(SupabaseConfig.transactionsTable)
        .select()
        .eq('user_id', _userId!)
        .order('date', ascending: false);

    return (response as List)
        .map((json) => TransactionModel.fromJson(json))
        .toList();
  }

  // Add new transaction
Future<void> addTransaction({
    required String type, // 'income' atau 'expense'
    required String category,
    required double amount,
    String? note,
    DateTime? date, 
  }) async {
    if (_userId == null) throw Exception('User not logged in');

    // Validasi data
    final safeType = type.toLowerCase();
    if (safeType != 'income' && safeType != 'expense') {
      throw Exception('Type must be "income" or "expense"');
    }

    final data = <String, dynamic>{
      'user_id': _userId,
      'type': safeType,
      'category': category,
      'amount': amount, // Pastikan dikirim sebagai number/double
      'date': (date ?? DateTime.now()).toIso8601String(), // Simpan full ISO string biar aman
    };

    if (note != null && note.isNotEmpty) {
      data['note'] = note;
    }

    await _supabase
        .from(SupabaseConfig.transactionsTable)
        .insert(data);
        
    print("Berhasil insert data: $data");
  }

  // Update transaction
  Future<TransactionModel> updateTransaction(
    String id, {
    String? type,
    String? category,
    double? amount,
    String? note, // Changed from description
    DateTime? date,
  }) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final data = <String, dynamic>{};

    if (type != null) {
      if (type != 'income' && type != 'expense') {
        throw Exception('Type must be "income" or "expense"');
      }
      data['type'] = type;
    }

    if (category != null) data['category'] = category;

    if (amount != null) {
      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }
      data['amount'] = amount;
    }

    if (note != null) data['note'] = note;

    if (date != null) {
      data['date'] = date.toIso8601String().split('T')[0];
    }

    final response = await _supabase
        .from(SupabaseConfig.transactionsTable)
        .update(data)
        .eq('id', id)
        .eq('user_id', _userId!)
        .select()
        .single();

    return TransactionModel.fromJson(response);
  }

  // Delete transaction
  Future<void> delete(String id) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    await _supabase
        .from(SupabaseConfig.transactionsTable)
        .delete()
        .eq('id', id)
        .eq('user_id', _userId!);
  }

  // Get transactions by type
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    if (type != 'income' && type != 'expense') {
      throw Exception('Type must be "income" or "expense"');
    }

    final response = await _supabase
        .from(SupabaseConfig.transactionsTable)
        .select()
        .eq('user_id', _userId!)
        .eq('type', type)
        .order('date', ascending: false);

    return (response as List)
        .map((json) => TransactionModel.fromJson(json))
        .toList();
  }

  // Get transactions by category
  Future<List<TransactionModel>> getTransactionsByCategory(
      String category) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final response = await _supabase
        .from(SupabaseConfig.transactionsTable)
        .select()
        .eq('user_id', _userId!)
        .eq('category', category)
        .order('date', ascending: false);

    return (response as List)
        .map((json) => TransactionModel.fromJson(json))
        .toList();
  }

  // Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final response = await _supabase
        .from(SupabaseConfig.transactionsTable)
        .select()
        .eq('user_id', _userId!)
        .gte('created_at', startDate.toIso8601String())
        .lte('created_at', endDate.toIso8601String())
        .order('date', ascending: false);

    return (response as List)
        .map((json) => TransactionModel.fromJson(json))
        .toList();
  }

  // Get total income
  Future<double> getTotalIncome() async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final transactions = await _supabase
        .from(SupabaseConfig.transactionsTable)
        .select('amount')
        .eq('user_id', _userId!)
        .eq('type', 'income');

    double total = 0.0;
    for (var t in transactions) {
      total += (t['amount'] as num).toDouble();
    }

    return total;
  }

  // Get total expense
  Future<double> getTotalExpense() async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final transactions = await _supabase
        .from(SupabaseConfig.transactionsTable)
        .select('amount')
        .eq('user_id', _userId!)
        .eq('type', 'expense');

    double total = 0.0;
    for (var t in transactions) {
      total += (t['amount'] as num).toDouble();
    }

    return total;
  }

  // Get balance (income - expense)
  Future<double> getBalance() async {
    final transactions = await getTransactions();
    double income = 0.0;
    double expense = 0.0;

    for (var transaction in transactions) {
      if (transaction.type == 'income') {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return income - expense;
  }
}
