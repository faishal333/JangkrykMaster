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

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  Future<void> _signOut() async {
    try {
      await GoogleSignIn().signOut(); // Sign out from Google
      await FacebookAuth.instance.logOut(); // Sign out from Facebook
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
    } catch (e) {
      if (kDebugMode) print('Error signing out: $e');
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }

  Future<void> _checkLoginStatus() async {
    // Memastikan framework flutter terinisiasi dengan penuh
    WidgetsFlutterBinding.ensureInitialized();

    // Inisiasi firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

    // SharedPreferences check
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingPage()),);
      return;
    }

    // Firebase user status
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Pengguna belum login, arahkan ke OnboardingPage()
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingPage()),);
      return;
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
      _signOut();
      // Pengguna belum login, arahkan ke OnboardingPage()
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingPage()),);
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
      (Route<dynamic> route) => false, // Menghapus semua halaman dalam stack
    );
  }

  @override
  void initState() {
    super.initState();

    // Step 1: Splash screen muncul dan tunggu 3 detik
    //Future.delayed(const Duration(seconds: 1), () {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
      });

      // Step 2: Meload nextPage di background
      Future(() async {
        // Simulasikan loading halaman berikutnya
        await Future.delayed(const Duration(seconds: 1)); // ganti dengan loading sesungguhnya

        // Step 3: Setelah halaman selesai diload, tunggu 2 detik
        await Future.delayed(const Duration(seconds: 1));

        // Step 4: Pindah ke halaman berikutnya
        // ignore: use_build_context_synchronously
        _checkLoginStatus();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'JangkrykMaster',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}