import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jangkrykmaster/pages/auth/sign_in_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut() async {
    try {
      await _googleSignIn.signOut(); // Sign out from Google
      await FacebookAuth.instance.logOut(); // Sign out from Facebook
      await _auth.signOut(); // Sign out from Firebase
    } catch (e) {
      if (kDebugMode) print('Error signing out: $e');
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100.0, // Tinggi maksimum saat di-expand
            collapsedHeight: kToolbarHeight, // Set height saat collapsed
            pinned: false, // Tetap muncul di bagian atas saat di-scroll
            automaticallyImplyLeading: false, // Menghilangkan tombol back
            backgroundColor: Colors.green,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.green,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.0, MediaQuery.of(context).padding.top + 16.0, 16.0, 16.0), // Beri jarak sesuai status bar
      child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40.0,
                        backgroundColor: Colors.white,
                        backgroundImage: user?.photoURL != null 
                            ? NetworkImage(user!.photoURL!) 
                            : null,
                        child: user?.photoURL == null 
                            ? const Icon(
                                Icons.person,
                                size: 50.0,
                                color: Colors.green,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 225), // Batasi lebar maksimal
                          child: Text(user == null ? "Anonymous" : (user.displayName ?? "Anonymous"),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 20.0, color: Colors.white)),
                      ),
                          Text(user == null ? "Anonymous" : (user.email ?? "Anonymous"),
                              style: const TextStyle(
                                  fontSize: 14.0, color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildMenuSection('Pengaturan Umum', [
                  _buildFlatMenuItem(Icons.settings, 'Pengaturan', onTap: () {
                    // Navigasi ke halaman Pengaturan
                  }),
                  _buildFlatMenuItem(Icons.security, 'Keamanan', onTap: () {
                    // Navigasi ke halaman Keamanan
                  }),
                  _buildFlatMenuItem(Icons.language, 'Bahasa', onTap: () {
                    // Navigasi ke halaman Bahasa
                  }),
                  _buildFlatMenuItem(Icons.notifications, 'Notifikasi', onTap: () {
                    // Navigasi ke halaman Notifikasi
                  }),
                  _buildFlatMenuItem(Icons.access_time, 'Waktu', onTap: () {
                    // Navigasi ke halaman Waktu
                  }),
                  _buildFlatMenuItem(Icons.accessibility, 'Aksesibilitas', onTap: () {
                    // Navigasi ke halaman Aksesibilitas
                  }),
                ]),
                const SizedBox(height: 10.0),
                _buildMenuSection('Bantuan & Dukungan', [
                  _buildFlatMenuItem(Icons.help, 'Bantuan', onTap: () {
                    // Navigasi ke halaman Bantuan
                  }),
                  _buildFlatMenuItem(Icons.contact_support, 'Hubungi Kami', onTap: () {
                    // Navigasi ke halaman Hubungi Kami
                  }),
                  _buildFlatMenuItem(Icons.feedback, 'Kirim Feedback', onTap: () {
                    // Navigasi ke halaman Kirim Feedback
                  }),
                  _buildFlatMenuItemWithText(Icons.info, 'Tentang Aplikasi', 'Versi 1.0', onTap: () {
                    // Navigasi ke halaman Tentang Aplikasi
                  }),
                  _buildFlatMenuItem(Icons.privacy_tip, 'Kebijakan Privasi', onTap: () {
                    // Navigasi ke halaman Kebijakan Privasi
                  }),
                ]),
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutConfirmation(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('keluar'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50), // Full-width button
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                _signOut();
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const SignInPage(),
                ));
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Background color
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildFlatMenuItem(IconData icon, String title, {Function()? onTap}) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        backgroundColor: Colors.transparent, // Background transparan
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        foregroundColor: Colors.green,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 16.0),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.black))),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildFlatMenuItemWithText(IconData icon, String title, String trailingText, {Function()? onTap}) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        backgroundColor: Colors.transparent, // Background transparan
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        foregroundColor: Colors.green,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 16.0),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.black))),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(trailingText, style: const TextStyle(color: Colors.grey)),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}