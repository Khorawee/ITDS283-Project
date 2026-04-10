// lib/pages/RegisterPage.dart  [FIXED]

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword  = true;
  bool _isLoading        = false;
  bool _isGoogleLoading  = false;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _dobCtrl       = TextEditingController();
  final _phoneCtrl     = TextEditingController();

  // วันเกิดในรูปแบบ YYYY-MM-DD สำหรับส่ง API
  String? _birthDateIso;

  @override
  void dispose() {
    for (final c in [_firstNameCtrl, _lastNameCtrl, _emailCtrl, _passwordCtrl, _dobCtrl, _phoneCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text = '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        _birthDateIso = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Firebase Register + API sync ─────────────────────────────────────────
  Future<void> _register() async {
    if (_firstNameCtrl.text.trim().isEmpty ||
        _lastNameCtrl.text.trim().isEmpty  ||
        _emailCtrl.text.trim().isEmpty     ||
        _passwordCtrl.text.trim().isEmpty) {
      _showSnack('Please fill in all required fields');
      return;
    }
    setState(() => _isLoading = true);
    try {
      // 1. สร้าง Firebase user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      await cred.user!.updateDisplayName(
        '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}',
      );

      // 2. Sync → MySQL
      await AuthService.registerUser(
        firstName: _firstNameCtrl.text.trim(),
        lastName:  _lastNameCtrl.text.trim(),
        phone:     _phoneCtrl.text.trim(),
        birthDate: _birthDateIso,
      );

      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showSnack(_firebaseMsg(e.code, e.message));
    } on ApiException catch (e) {
      debugPrint('API register warning: ${e.message}');
      // Firebase user สร้างแล้ว ให้เข้าแอปได้
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────
  // FIX: Google บน RegisterPage ควรทำงานเหมือน Login (ไม่ใช่ register ใหม่)
  // เพราะ Google account มักมีอยู่แล้ว และ Firebase จะ sign-in หรือ link อัตโนมัติ
  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      // FIX: signOut ก่อนทุกครั้งเพื่อให้ Google แสดง account picker
      // หากไม่ทำ Google จะใช้ cached account โดยไม่แสดง picker
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isGoogleLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );

      // Firebase signInWithCredential — ถ้า account มีอยู่แล้วจะ sign in
      // ถ้ายังไม่มีจะสร้างใหม่อัตโนมัติ
      final cred = await FirebaseAuth.instance.signInWithCredential(credential);

      // Sync กับ MySQL (API จะ upsert ให้ ไม่ duplicate)
      await AuthService.syncGoogleLogin(cred.user?.displayName ?? '');

      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      // FIX: handle กรณีที่ email นี้สมัครด้วย email/password แล้ว
      if (e.code == 'account-exists-with-different-credential') {
        _showSnack('This email is already registered with email/password. Please log in instead.');
      } else {
        _showSnack('Google sign-in failed: ${e.message}');
      }
    } on ApiException catch (e) {
      debugPrint('API sync warning: ${e.message}');
      // Firebase login สำเร็จแล้ว ให้เข้าแอปได้
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showSnack('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  String _firebaseMsg(String code, String? msg) {
    switch (code) {
      case 'email-already-in-use': return 'This email is already registered.';
      case 'invalid-email':        return 'Invalid email address.';
      case 'weak-password':        return 'Password must be at least 6 characters.';
      default:                     return msg ?? 'Registration failed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
              decoration: const BoxDecoration(color: Color(0xFF1DBA78)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),
                  const Text('Register',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Text('Already have an account? ',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Log In',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline, decorationColor: Colors.white)),
                    ),
                  ]),
                ],
              ),
            ),

            // Form
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: _labelField('First Name', _firstNameCtrl, 'First name')),
                    const SizedBox(width: 12),
                    Expanded(child: _labelField('Last Name', _lastNameCtrl, 'Last name')),
                  ]),
                  const SizedBox(height: 16),
                  _labelField('Email', _emailCtrl, 'example@gmail.com', type: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  const Text('Birth of date', style: TextStyle(fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _dobCtrl, readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: _inputDecoration(hint: 'DD/MM/YYYY').copyWith(
                      suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black45),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _labelField('Phone Number', _phoneCtrl, '0812345678', type: TextInputType.phone),
                  const SizedBox(height: 16),
                  const Text('Set Password', style: TextStyle(fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordCtrl, obscureText: _obscurePassword,
                    decoration: _inputDecoration(hint: '••••••••').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.grey, size: 20),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DBA78),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: _isLoading ? null : _register,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Register',
                              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                      child: _isGoogleLoading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4285F4)))
                          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Container(
                                width: 22, height: 22,
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey[300]!)),
                                child: const Center(child: Text('G',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4285F4)))),
                              ),
                              const SizedBox(width: 10),
                              const Text('Continue with Google', style: TextStyle(color: Colors.black87, fontSize: 14)),
                            ]),
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

  Widget _labelField(String label, TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 6),
        TextField(controller: ctrl, keyboardType: type, decoration: _inputDecoration(hint: hint)),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: Colors.black45),
    filled: true, fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1DBA78))),
  );
}
