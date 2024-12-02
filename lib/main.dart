import 'package:fishers_e_register/screens/auth.dart';
import 'package:fishers_e_register/screens/home.dart';
import 'package:fishers_e_register/screens/login.dart';
import 'package:fishers_e_register/screens/sign_up.dart';
import 'package:fishers_e_register/screens/process.dart';
import 'package:fishers_e_register/screens/status.dart';
import 'package:fishers_e_register/screens/notification.dart';
import 'package:fishers_e_register/admin/admin_login.dart';
import 'package:fishers_e_register/admin/admin_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize bindings first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Fisher's eRegister",
      initialRoute: '/admin',
      routes: {
        '/': (context) => const Authentication(),
        '/home': (context) => const Home(),
        '/login': (context) => const Login(),
        '/register': (context) => const SignUp(),
        '/process': (context) => const Process(),
        '/status': (context) => Status(),
        '/notification': (context) => NotificationScreen(),
        '/admin': (context) => const AdminLogin(),
        '/adminpage': (context) => const AdminPage(),
      },
    );
  }
}
