import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jangkrykmaster/pages/main_page.dart';
import 'package:jangkrykmaster/pages/auth/sign_up_page.dart';
import 'package:jangkrykmaster/pages/auth/sign_up_setpw_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _obscureText = true; // Untuk mengontrol visibilitas password
  bool _rememberMe = false; // Untuk mengontrol status "Ingat Saya"
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Proses sign in dibatalkan oleh pengguna
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      if (kDebugMode) print("Error during Google Sign-In: $e");
      return null;
    }
  }
  
  Future<void> saveLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }
  
    void _showSuccessNotification(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _SuccessNotification(message: message),
    );

    // Menampilkan notifikasi
    overlay.insert(overlayEntry);

    // Menghilangkan notifikasi setelah beberapa detik
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
          //title: const Text(
          //    'Jangkryk Master',
          //    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black54),
          //    textAlign: TextAlign.center,
          //  ),
      //),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Masuk',
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            //const Text(
            // 'Silakan masuk ke dalam akun Anda',
            //  textAlign: TextAlign.center,
            //  style: TextStyle(color: Colors.grey),
            //),
            const SizedBox(height: 20.0),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Masukkan alamat email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Masukkan kata sandi',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText; // Toggle visibility
                    });
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (bool? value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text('Ingat saya'),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Tambahkan eksekusi "Lupa Password?" di sini nanti
                  },
                  child: const Text('Lupa kata sandi?'),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Tambahkan eksekusi tombol Login di sini nanti
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.lightGreen),
              ),
              child: const Text('Masuk',
              style: TextStyle(color: Colors.black87),),
            ),
            const SizedBox(height: 10.0),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Atau",
                      style: TextStyle(fontSize: 12,color: Colors.grey),),
                    ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5.0),
            SignInButton(text: "Masuk dengan Google",
              Buttons.google,
              onPressed: () async {
                User? user = await _signInWithGoogle();
                if (user != null) {
                  if (kDebugMode) print('Successfully signed in: ${user.displayName}');
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
                      // Pengguna belum login, arahkan ke SetPasswordPage()
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SetPasswordPage()),);
                      return;
                    }

                    // User sudah membuat password

                    // Simpan status login
                    await saveLoginStatus();
                    
                    // Navigasi ke MainPage()
                    Navigator.pushAndRemoveUntil(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                      (Route<dynamic> route) => false, // Menghapus semua halaman dalam stack
                    );
                    
                } else {
                  if (kDebugMode) print('Sign in failed');
                }
              }
            ),
            const SizedBox(height: 0.0),
            SignInButton(
                text: "Masuk dgn Facebook",
                Buttons.facebookNew,
                onPressed: () async {
                }
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Belum punya akun? '),
                GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman daftar
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const SignUpPage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset(0.0, 0.0);
                          final tween = Tween(begin: begin, end: end);
                          final offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: const Text(
                    'Daftar sekarang',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              const Text(
                  'Powered by  ',
                  style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.normal, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),              
                const Text(
                  'JangkrykMaster ',
                  style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                SvgPicture.string(
                '''
                  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24"><path fill="#8A8A8A" d="M19.898.855a.4.4 0 0 0-.795 0c-.123 1.064-.44 1.802-.943 2.305-.503.503-1.241.82-2.306.943a.4.4 0 0 0 .001.794c1.047.119 1.801.436 2.317.942.512.504.836 1.241.93 2.296a.4.4 0 0 0 .796 0c.09-1.038.413-1.792.93-2.308.515-.516 1.269-.839 2.306-.928a.4.4 0 0 0 .001-.797c-1.055-.094-1.792-.418-2.296-.93-.506-.516-.823-1.27-.941-2.317Z"></path><path fill="#8A8A8A" d="M12.001 1.5a1 1 0 0 1 .993.887c.313 2.77 1.153 4.775 2.5 6.146 1.34 1.366 3.3 2.223 6.095 2.47a1 1 0 0 1-.003 1.993c-2.747.238-4.75 1.094-6.123 2.467-1.373 1.374-2.229 3.376-2.467 6.123a1 1 0 0 1-1.992.003c-.248-2.795-1.105-4.754-2.47-6.095-1.372-1.347-3.376-2.187-6.147-2.5a1 1 0 0 1-.002-1.987c2.818-.325 4.779-1.165 6.118-2.504 1.339-1.34 2.179-3.3 2.504-6.118A1 1 0 0 1 12 1.5ZM6.725 11.998c1.234.503 2.309 1.184 3.21 2.069.877.861 1.56 1.888 2.063 3.076.5-1.187 1.18-2.223 2.051-3.094.871-.87 1.907-1.55 3.094-2.05-1.188-.503-2.215-1.187-3.076-2.064-.885-.901-1.566-1.976-2.069-3.21-.505 1.235-1.19 2.3-2.081 3.192-.891.89-1.957 1.576-3.192 2.082Z"></path></svg>
                ''',
                  width: 16,
                  height: 16,
        ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessNotification extends StatefulWidget {
  final String message;

  const _SuccessNotification({required this.message});

  @override
  __SuccessNotificationState createState() => __SuccessNotificationState();
}

class __SuccessNotificationState extends State<_SuccessNotification> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _fadeOut();
  }

  void _fadeOut() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_opacity <= 0.0) {
        timer.cancel();
      } else {
        setState(() {
          double newOpacity = _opacity - 0.05;
          _opacity = newOpacity>=0?newOpacity:0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 500),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.message,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontStyle: FontStyle.normal),
          ),
        ),
      ),
    );
  }
}