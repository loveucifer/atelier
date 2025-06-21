import 'package:atelier/screens/auth/login_screen.dart';
import 'package:atelier/screens/main_navigation/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package.json';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:atelier/core/theme/app_theme.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    runApp(const AtelierApp());
  } catch (e) {
    // Using a print statement for simple error logging during initialization
    // ignore: avoid_print
    print('!!!!!!!!!! FATAL ERROR DURING INITIALIZATION !!!!!!!!!!!');
    // ignore: avoid_print
    print(e.toString());
  }
}

final supabase = Supabase.instance.client;

class AtelierApp extends StatelessWidget {
  const AtelierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atelier',
      // --- THEME CHANGES ---
      // Apply the new lightTheme
      theme: AppTheme.lightTheme, 
      // Set the app to always use light mode
      themeMode: ThemeMode.light, 
      debugShowCheckedModeBanner: false,

      // The authentication flow logic remains unchanged.
      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data!.session != null) {
            return const MainScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}