import 'package:excercises_tracker/Repositories/auth_repository.dart';
import 'package:excercises_tracker/app_strings.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _authRepository.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? AppStrings.unknownError)),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ExerciseTracker',
                style: TextStyle(color: Colors.green, fontSize: 24),
              ),
              const SizedBox(height: 16),
              const Text(
                'Create your account',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: AppStrings.nameHint,
                  fillColor: Colors.grey,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: const TextStyle(color: Colors.redAccent),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.nameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: AppStrings.emailHint,
                  fillColor: Colors.grey,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: const TextStyle(color: Colors.redAccent),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return AppStrings.emailRequired;
                  if (!value.contains('@') || !value.contains('.')) return AppStrings.invalidEmail;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: AppStrings.passwordHint,
                  fillColor: Colors.grey,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: const TextStyle(color: Colors.redAccent),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return AppStrings.passwordRequired;
                  if (value.length < 6) return AppStrings.passwordTooShort;
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _repeatPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: AppStrings.repeatPasswordHint,
                  fillColor: Colors.grey,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  errorStyle: const TextStyle(color: Colors.redAccent),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return AppStrings.repeatPasswordRequired;
                  if (value != _passwordController.text) return AppStrings.passwordsDoNotMatch;
                  return null;
                },
              ),
              const SizedBox(height: 32),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                    'Register',
                     style: TextStyle(color: Colors.black))
              ),

              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Already have an account? Sign In',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
