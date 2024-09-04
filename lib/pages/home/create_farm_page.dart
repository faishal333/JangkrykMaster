import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateFarmPage extends StatefulWidget {
  const CreateFarmPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CreateFarmPageState createState() => _CreateFarmPageState();
}

class _CreateFarmPageState extends State<CreateFarmPage> {
  final TextEditingController _farmNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createFarm() async {
    String farmName = _farmNameController.text.trim();
    if (farmName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama farm tidak boleh kosong')),
      );
      return;
    }

    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User tidak terautentikasi')),
      );
      return;
    }

    // Membuat dokumen farm baru di Firestore
    DocumentReference farmRef = await _firestore.collection('farms').add({
      'name': farmName,
      'creation_date': Timestamp.now(),
      'last_modified_date': Timestamp.now(),
      'creator_uid': user.uid,
      'owner_uid': user.uid,
    });

    // Inisiasi collection warehouse_core
    Map<String, Map<String, dynamic>> initialWarehouseItems = {
      'ant_poison': {'count': 0, 'name': 'Racun Semut', 'unit': 'botol', 'usage': 0},
      'egg_tray': {'count': 0, 'name': 'Egg Tray', 'unit': 'ikat', 'usage': 0},
      'face_mask': {'count': 0, 'name': 'Masker', 'unit': 'box', 'usage': 0},
      'gasoline': {'count': 0, 'name': 'Bensin', 'unit': 'liter', 'usage': 0},
      'karung_25': {'count': 0, 'name': 'Karung', 'unit': 'lembar', 'usage': 0},
      'multivitamin': {'count': 0, 'name': 'Multivitamin', 'unit': 'botol', 'usage': 0},
      'rafia_rope': {'count': 0, 'name': 'Tali Rafia', 'unit': 'gulung', 'usage': 0},
      'sack_of_feeds': {'count': 0, 'name': 'Pur', 'unit': 'sak', 'usage': 0},
    };

    for (var entry in initialWarehouseItems.entries) {
      await farmRef.collection('warehouse_core').doc(entry.key).set(entry.value);
    }

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Farm berhasil dibuat')),
    );
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Farm Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _farmNameController,
              decoration: const InputDecoration(
                hintText: 'Nama farm',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: createFarm,
              child: const Text('Buat Farm'),
            ),
          ],
        ),
      ),
    );
  }
}