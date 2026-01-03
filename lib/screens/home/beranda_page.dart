import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'add_transaction_screen.dart';
import '../../services/transaction_service.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

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

  @override
  Widget build(BuildContext context) {
    final service = TransactionService();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: StreamBuilder(
          stream: service.streamTransactions(),
          builder: (context, snapshot) {
            // 1. Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Error State
            if (snapshot.hasError) {
              debugPrint("Error Stream: ${snapshot.error}");
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // 3. Empty State
            if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return _buildEmptyState(context);
            }

            final List data = snapshot.data as List;
            
            // --- LOGIKA PERHITUNGAN ---
            double income = 0;
            double expense = 0;
            final Map<String, double> expenseCategories = {};
            final Map<String, double> incomeCategories = {};

            // Data untuk grafik perbandingan bulan ini
            double thisMonthIncome = 0;
            double thisMonthExpense = 0;
            double lastMonthIncome = 0;
            double lastMonthExpense = 0;

            final now = DateTime.now();
            final currentMonth = DateTime(now.year, now.month);
            final lastMonth = DateTime(now.year, now.month - 1);

            for (var t in data) {
              // Konversi amount
              double amount = 0;
              try {
                amount = double.parse(t['amount'].toString());
              } catch (e) {
                debugPrint("Gagal parse amount: ${t['amount']}");
                amount = 0;
              }

              // Normalisasi tipe
              String type = t['type'].toString().toLowerCase();
              String category = t['category']?.toString() ?? 'Lainnya';

              // Cek tanggal transaksi
              DateTime? transactionDate;
              try {
                transactionDate = DateTime.parse(t['date']);
              } catch (e) {
                continue;
              }

              // Hitung total
              if (type == 'income' || type == 'pemasukan') {
                income += amount;
                incomeCategories[category] = (incomeCategories[category] ?? 0) + amount;
                
                // Hitung per bulan
                final transactionMonth = DateTime(transactionDate.year, transactionDate.month);
                if (transactionMonth == currentMonth) {
                  thisMonthIncome += amount;
                } else if (transactionMonth == lastMonth) {
                  lastMonthIncome += amount;
                }
              } else {
                expense += amount;
                expenseCategories[category] = (expenseCategories[category] ?? 0) + amount;
                
                // Hitung per bulan
                final transactionMonth = DateTime(transactionDate.year, transactionDate.month);
                if (transactionMonth == currentMonth) {
                  thisMonthExpense += amount;
                } else if (transactionMonth == lastMonth) {
                  lastMonthExpense += amount;
                }
              }
            }

            final balance = income - expense;
            final thisMonthBalance = thisMonthIncome - thisMonthExpense;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 80,
                  floating: true,
                  pinned: true,
                  backgroundColor: const Color(0xFFF6F7FB),
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Moneyku',
                      style: TextStyle(
                        color: Color(0xFF1A73E8),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    centerTitle: false,
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBalanceCard(balance),
                        const SizedBox(height: 16),
                        
                        // GRAFIK PERBANDINGAN BULAN INI VS BULAN LALU
                        if (thisMonthIncome > 0 || thisMonthExpense > 0 || lastMonthIncome > 0 || lastMonthExpense > 0)
                          Column(
                            children: [
                              _buildSectionTitle('Perbandingan Bulanan'),
                              const SizedBox(height: 16),
                              _buildMonthlyComparisonChart(
                                thisMonthIncome, 
                                thisMonthExpense, 
                                lastMonthIncome, 
                                lastMonthExpense
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),

                        Row(
                          children: [
                            Expanded(child: _buildIncomeCard(thisMonthIncome)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildExpenseCard(thisMonthExpense)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // GRAFIK PIE CHART PENGELUARAN
                        if (expense > 0 && expenseCategories.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Pengeluaran per Kategori'),
                              const SizedBox(height: 16),
                              _buildCategoryChart(expenseCategories, expense, false),
                            ],
                          ),
                        
                        // GRAFIK PIE CHART PEMASUKAN
                        if (income > 0 && incomeCategories.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              _buildSectionTitle('Pemasukan per Kategori'),
                              const SizedBox(height: 16),
                              _buildCategoryChart(incomeCategories, income, true),
                            ],
                          ),
                        
                        // SECTION TRANSAKSI TERBARU
                        const SizedBox(height: 24),
                        _buildSectionTitle('Transaksi Terbaru'),
                        const SizedBox(height: 12),
                        _buildRecentTransactions(data),
                        
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthlyComparisonChart(
    double thisMonthIncome, 
    double thisMonthExpense, 
    double lastMonthIncome, 
    double lastMonthExpense
  ) {
    final totalThisMonth = thisMonthIncome + thisMonthExpense;
    final totalLastMonth = lastMonthIncome + lastMonthExpense;
    
    // Data untuk chart
    final maxValue = [thisMonthIncome, thisMonthExpense, lastMonthIncome, lastMonthExpense]
      .reduce((a, b) => a > b ? a : b);
    
    // Warna untuk chart
    final thisMonthColor = const Color(0xFF1A73E8);
    final lastMonthColor = Colors.grey[400]!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: thisMonthColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Bulan Ini', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 20),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: lastMonthColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Bulan Lalu', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          
          // Bar Chart
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: [
                  // Pemasukan - Bulan Ini
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: thisMonthIncome,
                        color: thisMonthColor,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  // Pengeluaran - Bulan Ini
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: thisMonthExpense,
                        color: thisMonthColor,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  // Pemasukan - Bulan Lalu
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: lastMonthIncome,
                        color: lastMonthColor,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  // Pengeluaran - Bulan Lalu
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(
                        toY: lastMonthExpense,
                        color: lastMonthColor,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.white,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final labels = ['Pemasukan', 'Pengeluaran'];
                      final isIncome = groupIndex % 2 == 0;
                      final isThisMonth = groupIndex < 2;
                      final value = rod.toY;
                      
                      return BarTooltipItem(
                        '${isThisMonth ? 'Bulan Ini' : 'Bulan Lalu'}\n'
                        '${labels[isIncome ? 0 : 1]}\n'
                        '${formatCurrency(value)}',
                        TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final labels = ['Pemasukan', 'Pengeluaran'];
                        final isIncome = value.toInt() % 2 == 0;
                        final isThisMonth = value.toInt() < 2;
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[isIncome ? 0 : 1],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            formatCurrency(value),
                            style: const TextStyle(fontSize: 10),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                      interval: maxValue > 0 ? maxValue / 4 : 100000,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: maxValue > 0 ? maxValue / 4 : 100000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[200],
                    strokeWidth: 1,
                  ),
                ),
              ),
            ),
          ),
          
          // Summary
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'Bulan Ini',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(thisMonthIncome - thisMonthExpense),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: (thisMonthIncome - thisMonthExpense) >= 0 
                            ? Colors.green 
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Bulan Lalu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(lastMonthIncome - lastMonthExpense),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: (lastMonthIncome - lastMonthExpense) >= 0 
                            ? Colors.green 
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Perubahan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${((thisMonthIncome - thisMonthExpense) - (lastMonthIncome - lastMonthExpense) >= 0 ? '+' : '')}'
                      '${formatCurrency((thisMonthIncome - thisMonthExpense) - (lastMonthIncome - lastMonthExpense))}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ((thisMonthIncome - thisMonthExpense) - (lastMonthIncome - lastMonthExpense)) >= 0 
                            ? Colors.green 
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Belum ada transaksi', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Transaksi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF4285F4)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Saldo', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            formatCurrency(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard(double income) {
    return _buildStatCard(
      title: 'Pemasukan',
      amount: income,
      color: Colors.green,
      icon: Icons.arrow_downward,
      subtitle: 'Bulan Ini',
    );
  }

  Widget _buildExpenseCard(double expense) {
    return _buildStatCard(
      title: 'Pengeluaran',
      amount: expense,
      color: Colors.red,
      icon: Icons.arrow_upward,
      subtitle: 'Bulan Ini',
    );
  }

  Widget _buildStatCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    String subtitle = '',
  }) {
    return Container(
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          if (subtitle.isNotEmpty) ...[
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            formatCurrency(amount),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildCategoryChart(Map<String, double> categories, double totalAmount, bool isIncome) {
    final List<MapEntry<String, double>> categoryList = categories.entries.toList();
    categoryList.sort((a, b) => b.value.compareTo(a.value));

    final displayedCategories = categoryList.take(6).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: displayedCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final double percentage = totalAmount == 0 ? 0 : (data.value / totalAmount * 100);

                  return PieChartSectionData(
                    value: data.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    color: getCategoryColor(data.key),
                    radius: 40,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    badgeWidget: _buildChartBadge(data.key, index),
                    badgePositionPercentageOffset: 0.98,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: displayedCategories.map((data) {
              final percentage = totalAmount == 0 ? 0 : (data.value / totalAmount * 100);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: getCategoryColor(data.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(getCategoryIcon(data.key), size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.key,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatCurrency(data.value),
                      style: TextStyle(
                        fontSize: 12,
                        color: isIncome ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBadge(String category, int index) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2),
        ],
      ),
      child: Center(
        child: Text(
          (index + 1).toString(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: getCategoryColor(category),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(List<dynamic> transactions) {
    final sortedTransactions = List.from(transactions);
    sortedTransactions.sort((a, b) {
      try {
        final dateA = DateTime.parse(a['date']);
        final dateB = DateTime.parse(b['date']);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    final recent = sortedTransactions.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          ...recent.map((transaction) {
            final isIncome = transaction['type'].toString().toLowerCase() == 'income' ||
                            transaction['type'].toString().toLowerCase() == 'pemasukan';
            final amount = double.tryParse(transaction['amount'].toString()) ?? 0;
            final category = transaction['category']?.toString() ?? 'Lainnya';
            final note = transaction['note']?.toString() ?? '';
            String dateStr = '';
            
            try {
              final date = DateTime.parse(transaction['date']);
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final transactionDate = DateTime(date.year, date.month, date.day);
              
              if (transactionDate == today) {
                dateStr = 'Hari ini';
              } else if (transactionDate == today.subtract(const Duration(days: 1))) {
                dateStr = 'Kemarin';
              } else {
                dateStr = DateFormat('dd/MM/yyyy').format(date);
              }
            } catch (e) {
              dateStr = transaction['date']?.toString() ?? '';
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: getCategoryColor(category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        getCategoryIcon(category),
                        color: getCategoryColor(category),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 14,
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
                          dateStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'} ${formatCurrency(amount)}',
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
          
          if (sortedTransactions.length > 5) 
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Masih ada ${sortedTransactions.length - 5} transaksi lainnya',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}