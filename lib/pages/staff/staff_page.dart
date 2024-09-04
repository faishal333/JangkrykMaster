import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jangkrykmaster/pages/farm_data_provider.dart';
import 'package:jangkrykmaster/pages/staff/add_staff_page.dart';
import 'package:jangkrykmaster/pages/staff/detail_staff_page.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StaffPageState createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  bool isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return 
    (farmDataProvider!.farmId == null || farmDataProvider!.farmId!.isEmpty || farmDataProvider!.farm==null || !farmDataProvider!.farm!.exists)? 
    const Scaffold(appBar: null,
    body: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Anda belum bergabung ke farm manapun', overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 14)),
          Text('Buat farm sekarang', overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(color: Colors.blue, fontSize: 14)),
        ],
    ),
        ],
    ),
    )
    
    :

    Scaffold(
      appBar: AppBar(
        title: 
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Anggota ${farmDataProvider!.farm?.get('name') ?? "<Farm Tanpa Nama>"}'),
          ],
        ),

        toolbarHeight: 60,
      ),

      body: Column(
        children: [
          // Search bar dengan tombol Add dan Edit
          Padding(
            padding: const EdgeInsets.fromLTRB(8,0,16,0),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari user...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.add,),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddStaffPage(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(isEditMode ? Icons.done : Icons.edit),
                  onPressed: () {
                    setState(() {
                      isEditMode = !isEditMode;
                    });
                  },
                ),
              ],
            ),
          ),
          // Tombol aksi dalam mode edit
          if (isEditMode)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Logika untuk Select All
                  },
                  child: const Text('Select All'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Logika untuk Deselect All
                  },
                  child: const Text('Deselect All'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Logika untuk Hapus yang dipilih
                  },
                  child: const Text('Hapus'),
                ),
              ],
            ),
                    // ListView yang menampilkan daftar staff
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('farms/${farmDataProvider!.farmId}/staff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final staffDocs = snapshot.data?.docs ?? [];

                return ListView.builder(
                  itemCount: staffDocs.length,
                  itemBuilder: (context, index) {
                    var staffData = staffDocs[index].data() as Map<String, dynamic>;
                    String userId = staffDocs[index].id;

                    // Menggunakan FutureBuilder untuk mengambil nama staff dari /users/<user_uid>/name
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: const Text('Loading...'),
                            subtitle: Text(staffData['role'] ?? 'No role'),
                          );
                        }

                        if (userSnapshot.hasError) {
                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.error)),
                            title: const Text('Error loading user'),
                            subtitle: Text(staffData['role'] ?? 'No role'),
                          );
                        }

                        var userData = userSnapshot.data?.data() as Map<String, dynamic>?;

                        return ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailStaffPage(
                                  userId: userId,
                                  farmName: farmDataProvider!.farm!.get('name') ?? '<Farm Tanpa Nama>',
                                  staffData: staffData,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              const SizedBox(width: 10),
                              //Text(userData?['name'] ?? 'Unknown'),
                              Text(userData?['name'] ?? 'Unknowna'),
                              const Spacer(),
                              Text(staffData['role'] ?? 'No role'),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          
          
          ),
        
        ],
      ),
    );
  }
}