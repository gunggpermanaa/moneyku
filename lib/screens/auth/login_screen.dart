import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  bool loading = false;

  Future<void> submit() async {
    if (passCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      if (isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
      } else {
        await Supabase.instance.client.auth.signUp(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
          data: {'name': nameCtrl.text.trim()},
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Moneyku',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                ToggleButtons(
                  isSelected: [isLogin, !isLogin],
                  onPressed: (i) => setState(() => isLogin = i == 0),
                  borderRadius: BorderRadius.circular(12),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text('Login'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text('Register'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                if (!isLogin)
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nama'),
                  ),

                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),

                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : submit,
                    child: Text(
                      loading
                          ? 'Loading...'
                          : isLogin
                          ? 'Login'
                          : 'Register',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
