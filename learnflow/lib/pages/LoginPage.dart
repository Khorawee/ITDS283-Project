// lib/pages/LoginPage.dart  [UPDATED — เชื่อม API]

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe      = false;
  bool _obscurePassword = true;
  bool _isLoading       = false;

  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Email / Password Login ────────────────────────────────────────────────
  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email:    _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Email login ไม่ต้อง sync API (สร้างตอน register แล้ว)
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showSnack(_firebaseMessage(e.code, e.message));
    } catch (e) {
      _showSnack('Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────
  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      UserCredential cred;
      if (kIsWeb) {
        final provider = GoogleAuthProvider()..addScope('email');
        cred = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) { setState(() => _isLoading = false); return; }
        final googleAuth = await googleUser.authentication;
        cred = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken:     googleAuth.idToken,
          ),
        );
      }
      // Sync user → MySQL
      final displayName = cred.user?.displayName ?? '';
      await AuthService.syncGoogleLogin(displayName);

      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on ApiException catch (e) {
      // API error ไม่ block การเข้าแอป (user อยู่ใน Firebase แล้ว)
      debugPrint('API sync warning: ${e.message}');
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showSnack('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _firebaseMessage(String code, String? msg) {
    switch (code) {
      case 'user-not-found':   return 'No account found for this email.';
      case 'wrong-password':   return 'Incorrect password.';
      case 'invalid-email':    return 'Invalid email address.';
      case 'user-disabled':    return 'This account has been disabled.';
      default:                 return msg ?? 'Login failed. Please try again.';
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
              decoration: const BoxDecoration(color: Color(0xFF1DBA78)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/LeranFlow_logo.png', width: 80, height: 80),
                  const SizedBox(height: 6),
                  const Text('LearnFlow', style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 20),
                  const Text('Get Started now',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 6),
                  const Text('Create an account or log in to explore about our app',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            // ── Form ─────────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {},
                          child: const Text('Log In',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200], elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: const Text('Sign Up', style: TextStyle(color: Colors.black54)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Email', style: TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(hint: 'example@gmail.com'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Password', style: TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(hint: '••••••••').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey, size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 20, height: 20,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (val) => setState(() => _rememberMe = val ?? false),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              side: BorderSide(color: Colors.grey[400]!),
                              activeColor: const Color(0xFF1DBA78),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Remember me', style: TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        child: const Text('Forgot Password ?',
                            style: TextStyle(fontSize: 13, color: Color(0xFF1DBA78))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DBA78),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Log In',
                              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Or', style: TextStyle(color: Colors.grey[500], fontSize: 13))),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ]),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : _loginWithGoogle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const Center(
                              child: Text('G',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4285F4))),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('Continue with Google', style: TextStyle(color: Colors.black87, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black45),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1DBA78))),
  );
}
