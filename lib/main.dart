// lib/main.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:atelier/screens/seller/my_products_screen.dart'; // Make sure this path is correct

void main() async {
  // WidgetsFlutterBinding.ensureInitialized() is required to ensure that
  // plugin services are initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase. This must be done before running the app.
  // IMPORTANT: Replace with your actual Supabase URL and Anon Key.
  await Supabase.initialize(
    url: 'https://jfbjcmdsvzdbjkjybuyv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmYmpjbWRzdnpkYmpranlidXl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAyNjc3NjAsImV4cCI6MjA2NTg0Mzc2MH0.uK7qo-s2AKeD5BH9aWhf_McHekqjegBc_ELUMMIavrc',
  );

  runApp(const AtelierApp());
}

// A handy global variable to access the Supabase client from anywhere.
final supabase = Supabase.instance.client;

class AtelierApp extends StatelessWidget {
  const AtelierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // This removes the "debug" banner in the top right corner.
      debugShowCheckedModeBanner: false,
      title: 'Atelier',
      theme: ThemeData(
        // Let's define a theme that fits our app's artistic feel.
        // You can play around with these colors.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        // Define the theme for our FloatingActionButtons
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo[700],
          foregroundColor: Colors.white,
        ),
        // Define the theme for Chips
        chipTheme: ChipThemeData(
          secondarySelectedColor: Colors.indigo,
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      // This is the most important part for now.
      // We are setting the `home` of our app to the screen we just built.
      home: const MyProductsScreen(),
    );
  }
}