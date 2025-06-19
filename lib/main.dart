import 'package:atelier/screens/auth/login_screen.dart';
import 'package:atelier/screens/main_navigation/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:atelier/core/theme/app_theme.dart';

Future<void> main() async {
  // All the initialization code stays the same
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    runApp(const AtelierApp());
  } catch (e) {
    print('!!!!!!!!!! FATAL ERROR DURING INITIALIZATION !!!!!!!!!!!');
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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      
      // --- CHANGE FOR DEVELOPMENT ---
      // We are temporarily bypassing the auth check and going straight to the main screen.
      home: const MainScreen(),

      /* // --- ORIGINAL AUTH CODE ---
      // To re-enable login, comment out the line above and uncomment this block.
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
      */
    );
  }
}