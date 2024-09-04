import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jangkrykmaster/pages/main_page.dart';
import 'package:jangkrykmaster/pages/auth/sign_up_setpw_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:jangkrykmaster/pages/auth/sign_in_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscureText = true; // Untuk mengontrol visibilitas password
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
  
  Future<User?> _signInWithFacebook() async {
  try {
    // Login dengan Facebook
    final LoginResult result = await FacebookAuth.instance.login();

    // Periksa apakah login sukses
    if (result.status == LoginStatus.success) {
      // Ambil access token dari Facebook
      final AccessToken accessToken = result.accessToken!;

      // Buat credential untuk Firebase Auth
      final AuthCredential credential = FacebookAuthProvider.credential(accessToken.tokenString);

      // Sign-in ke Firebase dengan credential Facebook
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } else if (result.status == LoginStatus.cancelled) {
      // Pengguna membatalkan login
      print("Login dibatalkan oleh pengguna.");
      return null;
    } else {
      // Error lain
      print("Error saat login dengan Facebook: ${result.message}");
      return null;
    }
  } catch (e) {
    print("Error during Facebook Sign-In: $e");
    return null;
  }
}

  Future<void> saveLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> initializeAccount() async {
    
  }

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
  
  Future<bool> isEmailRegistered(String email) async {
    try {
      // ignore: deprecated_member_use
      final signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return signInMethods.isNotEmpty;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Error checking email registration: ${e.message}');
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _signOut();
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
              'Daftar',
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 1.0),
            const Text(
              'Buat akun Anda secara gratis',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30.0),
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
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text;

                // Cek apakah email sudah terdaftar
                final isRegistered = await isEmailRegistered(email);
                if (isRegistered) {
                  // Tampilkan pesan bahwa email sudah digunakan
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email sudah digunakan')),
                  );
                  return;
                }

                // Jika email belum terdaftar, navigasikan ke halaman SetPasswordPage()
                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SetPasswordPage()),);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
              ),
              child: const Text('Daftar',
              style: TextStyle(color: Colors.white),),
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
            SignInButton(text: "Daftar dengan Google",
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
                text: "Daftar dgn Facebook",
                Buttons.facebookNew,
                onPressed: () async {
                }
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Sudah punya akun? '),
                GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman masuk
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const SignInPage(),
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
                    'Masuk',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            RichText(
              textAlign: TextAlign.center, // Centered text
              text: TextSpan(
                text: 'Dengan mendaftar Anda menyetujui ',
                style: const TextStyle(color: Colors.black), // Default text style
                children: [
                  TextSpan(
                    text: 'Aturan Penggunaan',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Navigasi atau aksi untuk S&K
                      },
                  ),
                  const TextSpan(
                    text: ' dan ',
                  ),
                  TextSpan(
                    text: 'Kebijakan Privasi',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Navigasi atau aksi untuk Kebijakan Privasi
                      },
                  ),
                  const TextSpan(
                    text: ' JangkrykMaster.',
                  ),
                ],
              ),
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
                  'JangkrykMaster  ',
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