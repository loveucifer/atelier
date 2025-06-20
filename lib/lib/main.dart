import 'package:atelier/screens/auth/login_screen.dart';
import 'package:atelier/screens/main_navigation/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

      // --- Re-enabling Authentication Flow ---
      // The StreamBuilder will now decide which screen to show.
      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // While waiting for the first auth event, show a loading screen
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If a user session exists, they are logged in. Show the main app.
          if (snapshot.hasData && snapshot.data!.session != null) {
            return const MainScreen();
          }

          // If there is no session, show the login screen.
          return const LoginScreen();
        },
      ),
    );
  }
}