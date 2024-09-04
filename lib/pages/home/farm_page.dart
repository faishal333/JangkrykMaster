import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FarmPage extends StatefulWidget {
  final String farmId;

  const FarmPage({super.key, required this.farmId});

  @override
  State<FarmPage> createState() => _FarmPageState();
}

class _FarmPageState extends State<FarmPage> {
  Future<String> getUserName(String userId) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    // Konversi data menjadi Map<String, dynamic>
    Map<String, dynamic>? data = userSnapshot.data() as Map<String, dynamic>?;
    return data?['name'] ?? 'Nama Tidak Ditemukan';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('farms').doc(widget.farmId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Farm');
            String farmName = snapshot.data?.get('name') ?? 'Farm Tanpa Nama';
            return Text(farmName);
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('farms').doc(widget.farmId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var farmData = snapshot.data!;
          var creationDate = farmData['creation_date'].toDate();
          var lastModifiedDate = farmData['last_modified_date'].toDate();
          String ownerUid = farmData['owner_uid'];

          return FutureBuilder<String>(
            future: getUserName(ownerUid),
            builder: (context, ownerNameSnapshot) {
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  //Text('Jumlah Kandang: ${farmData['barns']?.length ?? 0}'),
                  //Text('Jumlah Anggota: ${farmData['staff']?.length ?? 0}'),
                  //Text('Jumlah Proyek: ${farmData['projects']?.length ?? 0}'),
                  Text('Dibuat: ${creationDate.toLocal()}'),
                  Text('Terakhir di update: ${lastModifiedDate.toLocal()}'),
                  Text('Owner: ${ownerNameSnapshot.data ?? 'Nama Tidak Ditemukan'}'),
                ],
              );
            },
          );
        },
      ),
    );
  }
}