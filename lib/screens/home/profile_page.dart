import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/login_screen.dart';
// Import halaman-halaman sub-menu (pastikan file-file di bawah dibuat)
import '../profile/personal_info_page.dart';
import '../profile/change_password_page.dart';
import '../profile/manage_categories_page.dart';
import '../profile/export_data_page.dart';
import '../profile/help_faq_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile/privacy_policy_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late SharedPreferences _prefs;
  final _supabase = Supabase.instance.client;
  String _userEmail = '';
  String _userName = '';
  bool _isLoading = true;
  bool _isNotificationEnabled = true; // State untuk toggle notifikasi

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isNotificationEnabled = _prefs.getBool('notifications') ?? true;
    });
  }

  // Reload data saat kembali dari halaman edit profil
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        setState(() {
          _userEmail = user.email ?? 'Email tidak tersedia';
          _userName = user.userMetadata?['name'] ??
              user.email?.split('@')[0] ??
              'Pengguna';
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F7FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A73E8), Color(0xFF4285F4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A73E8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Menu: Akun
              _buildMenuSection(
                title: 'Akun',
                items: [
                  _MenuItem(
                    icon: Icons.person_outline,
                    title: 'Informasi Pribadi',
                    onTap: () async {
                      // Navigate dan tunggu update (agar nama berubah kalau diedit)
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PersonalInfoPage()),
                      );
                      _loadUserData();
                    },
                  ),
                  _MenuItem(
                    icon: Icons.lock_outline,
                    title: 'Ubah Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ChangePasswordPage()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Menu: Pengaturan
              _buildMenuSection(
                title: 'Pengaturan',
                items: [
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifikasi',
                    trailing: Switch(
                      value: _isNotificationEnabled,
                      onChanged: (value) async {
                        setState(() => _isNotificationEnabled = value);
                        await _prefs.setBool('notifications', value);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(value
                                ? 'Notifikasi Aktif'
                                : 'Notifikasi Nonaktif'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      activeColor: const Color(0xFF1A73E8),
                    ),
                    onTap: () {
                      setState(() =>
                          _isNotificationEnabled = !_isNotificationEnabled);
                    },
                  ),
                  _MenuItem(
                    icon: Icons.category_outlined,
                    title: 'Kelola Kategori',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ManageCategoriesPage()),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.file_download_outlined,
                    title: 'Export Data',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ExportDataPage()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Menu: Lainnya
              _buildMenuSection(
                title: 'Lainnya',
                items: [
                  _MenuItem(
                    icon: Icons.help_outline,
                    title: 'Bantuan & FAQ',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelpFAQPage()),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Kebijakan Privasi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyPage()),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.info_outline,
                    title: 'Tentang Aplikasi',
                    trailing: const Text('v1.0.0',
                        style: TextStyle(color: Colors.grey)),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar'),
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
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F0FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet,
                    size: 40, color: Color(0xFF1A73E8)),
              ),
              const SizedBox(height: 16),
              const Text('MoneyKu',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Text(
                'Aplikasi pencatat keuangan pribadi yang simpel dan elegan. Dibuat untuk membantu Anda mencapai kebebasan finansial.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(
      {required String title, required List<_MenuItem> items}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
          ),
          ...items.map((item) => _buildMenuItem(item)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: const Color(0xFF1A73E8), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Text(item.title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500))),
            if (item.trailing != null)
              item.trailing!
            else
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  _MenuItem(
      {required this.icon, required this.title, this.trailing, this.onTap});
}
