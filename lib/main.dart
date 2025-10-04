//main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/year_selection_page.dart';
import 'services/auth_service.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAuth.instance.signOut();
    print('User signed out');
  } catch (e) {
    print('Error: $e');
  }
  runApp(const IncomeApp());
}

class IncomeApp extends StatelessWidget {
  const IncomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Income Calculator",
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<User?>(
        stream: AuthService.authStateChanges, // Use AuthService
        builder: (context, snapshot) {
          print(
            'Snapshot state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, user: ${snapshot.data?.uid}',
          );

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const YearSelectionPage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
