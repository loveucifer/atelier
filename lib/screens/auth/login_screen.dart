import 'package:atelier/main.dart';
import 'package:atelier/screens/auth/signup_screen.dart';
import 'package:atelier/widgets/common/pulsating_gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });

    // --- DEBUGGING ADDED HERE ---
    try {
      // ignore: avoid_print
      print('Attempting to sign in with email: ${_emailController.text}');

      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ignore: avoid_print
      print('Sign in successful!');

    } on AuthException catch (error) {
       if (mounted) {
        // We will now print the error to the console in addition to showing the SnackBar.
        // ignore: avoid_print
        print('!!!!!!!!!! SUPABASE AUTH ERROR !!!!!!!!!!!');
        // ignore: avoid_print
        print('Supabase error message: ${error.message}');
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } catch (error) {
       if (mounted) {
        // This will catch any other unexpected errors.
        // ignore: avoid_print
        print('!!!!!!!!!! UNEXPECTED ERROR !!!!!!!!!!!');
        // ignore: avoid_print
        print('Error details: $error');

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('An unexpected error occurred.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
       }
    } finally {
        // This 'finally' block ensures the loading state is always reset.
        if (mounted) {
            setState(() { _isLoading = false; });
        }
    }
    // --- END OF DEBUGGING ---
  }

  @override
  Widget build(BuildContext context) {
    return PulsatingGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Atelier',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The Social Marketplace for Creators.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 60),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _signIn,
                          child: const Text('Login'),
                        ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

