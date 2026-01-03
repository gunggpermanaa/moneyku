class TransactionModel {
  final String id;
  final String userId;
  final String type; // 'income' atau 'expense'
  final String category;
  final double amount;
  final String? note; // Changed from description
  final DateTime date; // Changed from createdAt
  final DateTime createdAt; // Keep this for record creation time

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.amount,
    this.note,
    required this.date,
    required this.createdAt,
  });

  // Convert dari JSON (dari Supabase)
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert ke JSON (untuk kirim ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'category': category,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String().split('T')[0], // Only date part
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Copy with (untuk update data)
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? category,
    double? amount,
    String? note,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper untuk cek apakah pemasukan
  bool get isIncome => type == 'income';

  // Helper untuk cek apakah pengeluaran
  bool get isExpense => type == 'expense';

  @override
  String toString() {
    return 'TransactionModel(id: $id, type: $type, category: $category, amount: $amount)';
  }
}
