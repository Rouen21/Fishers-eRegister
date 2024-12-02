import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../reuse.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _signInAsAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('Attempting login with email: ${_emailController.text.trim()}'); // Debug log

      // Authenticate the user with Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final String uid = userCredential.user!.uid;
      print('User authenticated with UID: $uid'); // Debug log

      // Check if the user exists in the 'admin' collection
      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('admin').doc(uid).get();
      
      print('Admin document exists: ${userDoc.exists}'); // Debug log
      if (userDoc.exists) {
        print('Admin document data: ${userDoc.data()}'); // Debug log
      }

      if (!userDoc.exists) {
        print('No admin document found for UID: $uid'); // Debug log
        await FirebaseAuth.instance.signOut();
        throw 'Not authorized as admin';
      }

      // Check for admin role
      final data = userDoc.data() as Map<String, dynamic>;
      final String? role = data['role'];
      print('User role: $role'); // Debug log

      if (role != 'admin') {
        print('User does not have admin role: $role'); // Debug log
        await FirebaseAuth.instance.signOut();
        throw 'Not authorized as admin';
      }

      // Navigate to the admin dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/adminpage');
      }
    } catch (e) {
      print('Error during login: $e'); // Debug log
      setState(() {
        if (e.toString().contains('user-not-found')) {
          _errorMessage = 'No user found with this email';
        } else if (e.toString().contains('wrong-password')) {
          _errorMessage = 'Invalid password';
        } else if (e.toString().contains('Not authorized')) {
          _errorMessage = 'Not authorized as admin';
        } else {
          _errorMessage = 'Login failed: ${e.toString()}';
        }
      });
      await FirebaseAuth.instance.signOut();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            margin: const EdgeInsets.all(32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 80,
                      color: Colors.blue,
                    ),
                    myBox(32, 0),

                    // Email Field
                    myText(
                      context,
                      'Admin Email',
                      _emailController,
                      false,
                    ),
                    myBox(16, 0),

                    // Password Field
                    myText(
                      context,
                      'Password',
                      _passwordController,
                      true,
                    ),
                    myBox(24, 0),

                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    // Login Button
                    _isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF008080))
                        : myButton(
                            context,
                            _signInAsAdmin,
                            'Login',
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
