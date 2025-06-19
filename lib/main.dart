import 'package:atelier/screens/auth/login_screen.dart';
import 'package:atelier/screens/main_navigation/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:atelier/core/theme/app_theme.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    print("--- Step 1: Loading .env file ---");
    await dotenv.load(fileName: ".env");
    print("✅ .env file found and loaded.");

    print("--- Step 2: Checking environment variables ---");
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      // This will now be our specific error if the URL is missing
      throw Exception("FATAL: SUPABASE_URL is not found in .env file or is empty.");
    }
    if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
      // This will be our specific error if the key is missing
      throw Exception("FATAL: SUPABASE_ANON_KEY is not found in .env file or is empty.");
    }
    print("✅ Variables loaded from .env successfully.");
    
    print("--- Step 3: Initializing Supabase ---");
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    print("✅ Supabase initialized successfully! Starting app...");

    runApp(const AtelierApp());

  } catch (e) {
    print('---------------------------------------------------------');
    print('!!!!!!!!!! FATAL ERROR DURING INITIALIZATION !!!!!!!!!!!');
    print('The specific error is: ${e.runtimeType}');
    print(e.toString());
    print('---------------------------------------------------------');
  }
}

// Global shortcut to the Supabase client
final supabase = Supabase.instance.client;

class AtelierApp extends StatelessWidget {
  const AtelierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atelier',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
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