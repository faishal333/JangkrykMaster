import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jangkrykmaster/firebase_options.dart';
import 'package:jangkrykmaster/pages/main_page.dart';
import 'package:jangkrykmaster/pages/auth/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AuthCheckPageState createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool isLoggedIn = await _checkLoginStatus();

      if (!isLoggedIn) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingPage()),);
      } else {
        Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
          (Route<dynamic> route) => false, // Menghapus semua halaman dalam stack
        );
      }

    });
  }

  Future<bool> _checkLoginStatus() async {
    // Memastikan framework flutter terinisiasi dengan penuh
    WidgetsFlutterBinding.ensureInitialized();

    // Memastikan firebase terinisiasi dengan penuh
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

    // SharedPreferences isLoggedIn check
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn) {
      return false;
    }

    // Firebase user status
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Pengguna belum login, arahkan ke OnboardingPage()
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      // ignore: use_build_context_synchronously
      return false;
    }
    
    // Sampai sini, Pengguna sudah berhasil login
    
    //cek apakah user sudah menambahkan provider password?
    bool hasPasswordProvider = false;

    // Loop untuk memeriksa setiap provider yang ditautkan
    for (UserInfo userInfo in user.providerData) {
      // Cek apakah providerId adalah 'password'
      if (userInfo.providerId == 'password') {
        hasPasswordProvider = true;
        break;  // Stop loop jika ditemukan
      }
    }

    //jika Pengguna belum menambahkan password, logout dan arahkan user ke halaman OnboardingPage() untuk mengulang proses signup
    if (!hasPasswordProvider) {
      await _signOut();
      // Pengguna belum login, arahkan ke OnboardingPage()
      // ignore: use_build_context_synchronously
      return false;
    }

    // Pengguna sudah login, arahkan ke MainPage()
    return true;
  }

  Future<void> _signOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);

      await GoogleSignIn().signOut(); // Sign out from Google
      await FacebookAuth.instance.logOut(); // Sign out from Facebook
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
    } catch (e) {
      if (kDebugMode) print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: CircularProgressIndicator(), // Tampilkan loading saat pengecekan berlangsung
      ),
    );
  }
}