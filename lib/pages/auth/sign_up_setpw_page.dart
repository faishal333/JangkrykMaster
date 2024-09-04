import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jangkrykmaster/pages/main_page.dart';

class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SetPasswordPageState createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  bool _isPasswordStrong(String password) {
    // Contoh kriteria kekuatan password
    RegExp lower = RegExp(r'[a-z]');
    RegExp upper = RegExp(r'[A-Z]');
    RegExp digits = RegExp(r'\d');
    RegExp special = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    return password.length >= 8 &&
        lower.hasMatch(password) &&
        upper.hasMatch(password) &&
        digits.hasMatch(password) &&
        special.hasMatch(password);
  }

Future<void> _submit() async {
  if (_formKey.currentState!.validate()) {
    try {
      // Mendapatkan status pengguna saat ini
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
          // Jika pendaftaran dengan Google, maka link dengan email & password
          AuthCredential emailCredential = EmailAuthProvider.credential(
            email: user.email ?? "",
            password: _passwordController.text,
          );

          // Menautkan credential email & password dengan akun yang ada
          UserCredential userCredential = await user.linkWithCredential(emailCredential);

          user = userCredential.user;
          if (user != null) {
            // Berhasil menautkan credential
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Password berhasil diatur. ${user.email}')),
            );

            // Navigasi ke halaman utama
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
              (Route<dynamic> route) => false, // Menghapus semua halaman dalam stack
            );
          } else {
            // Gagal menautkan password
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: user == null')),
            );
          }

      } else {
        // Jika pengguna tidak ada
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: user == null')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Menampilkan error jika terjadi masalah
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat kata sandi baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16,0,16,16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Kata sandi',
                  isDense: true, // Menjadikan field lebih padat dan memberikan ruang lebih untuk error text
                  //contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata sandi tidak boleh kosong';
                  }
                  if (!_isPasswordStrong(value)) {
                    return 'Kata sandi harus memiliki minimal 8 karakter,\ntermasuk huruf besar, huruf kecil, angka, dan\nkarakter khusus';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi kata sandi',
                  isDense: true, // Menjadikan field lebih padat dan memberikan ruang lebih untuk error text
                  //contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi Kata sandi tidak boleh kosong';
                  }
                  if (value != _passwordController.text) {
                    return 'Konfirmasi Kata sandi tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submit,
                style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
              ),

              child: const Text('Daftar',
              style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
