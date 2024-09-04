import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jangkrykmaster/pages/auth/sign_in_page.dart';
import 'package:jangkrykmaster/pages/barns/barns_page.dart';
import 'package:jangkrykmaster/pages/farm_data_provider.dart';
import 'package:jangkrykmaster/pages/home/home_page.dart';
import 'package:jangkrykmaster/pages/more/more_page.dart';
import 'package:jangkrykmaster/pages/staff/staff_page.dart';
import 'package:jangkrykmaster/pages/warehouse/warehouse_page.dart';
import 'package:jangkrykmaster/user_data_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late Future<void> _initDataProviderFuture;

  // Daftar halaman untuk setiap tab
  final List<Widget> _pages = <Widget>[
    const HomePage(),
    const BarnsPage(),
    const WarehousePage(),
    const StaffPage(),
    const MorePage(),
  ];

  Future<void> initDataProvider(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Jika user tidak ada, navigasi ke halaman login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
        (route) => false, // Menghapus semua rute sebelumnya
      );
      return;
    }

    // Inisialisasi UserDataProvider dan FarmDataProvider
    userDataProvider = UserDataProvider(user: user);
    farmDataProvider = FarmDataProvider(userDataProvider: userDataProvider!);
    await userDataProvider!.init();
    await farmDataProvider!.init();
  }

@override
  void initState() {
    super.initState();
    // Memanggil initDataProvider() dan menyimpan Future-nya
    _initDataProviderFuture = initDataProvider(context);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (farmDataProvider!=null) farmDataProvider!.dispose();
    if (userDataProvider!=null) userDataProvider!.dispose();
    farmDataProvider = null;
    userDataProvider = null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initDataProviderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: null,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // Tampilan yang ditampilkan setelah inisialisasi selesai
          return 
                Scaffold(
            appBar: null,
            body: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.warehouse),
                  label: 'Kandang',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shelves),
                  label: 'Gudang',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'Staf',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz),
                  label: 'Lainnya',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed, // Menampilkan semua teks
            ),
          );
        }
      },
    );
  }
}