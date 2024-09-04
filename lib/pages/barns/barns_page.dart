import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jangkrykmaster/user_data_provider.dart';

class BarnsPage extends StatefulWidget {
  const BarnsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BarnsPageState createState() => _BarnsPageState();
}

class _BarnsPageState extends State<BarnsPage> {
  List<BarnData> barns = [];
  List<String> selectedBarnIds = [];
  bool isEditing = false;
  String? _farmId;

  StreamSubscription<QuerySnapshot>? _subscriptionBarnsCollection;


void initDataListener() async {
  if (userDataProvider!.farmId != null) {
    // Query untuk mendapatkan jumlah kandang
    _subscriptionBarnsCollection = FirebaseFirestore.instance
        .collection('farms')
        .doc(userDataProvider!.farmId)
        .collection('barns')
        .snapshots()
        .listen((snapshot) async {
          List<BarnData> newBarns = [];
          for (var barnDoc in snapshot.docs) {
            BarnData barnData = BarnData(barnDoc.id, barnDoc.get('name') as String?, barnDoc.get('creator_uid') as String?, barnDoc.get('creation_date') as Timestamp?);
            // Mendapatkan subkoleksi `boxes` dari setiap `barn`
            CollectionReference boxesCol = barnDoc.reference.collection('boxes');
            QuerySnapshot boxesSnapshot = await boxesCol.get();
              for (var boxDoc in boxesSnapshot.docs) {
                BoxData boxData = BoxData(boxDoc.id, boxDoc.get('name') as String?, boxDoc.get('creator_uid') as String?, boxDoc.get('creation_date') as Timestamp?);
                barnData.boxes.add(boxData);
              }
              newBarns.add(barnData);
          }

          setState(() {
            barns = newBarns;
          });

        }, onError: (error) {
          if (kDebugMode) {
            print('Error listening to farm data: $error');
          }
        });
  }
}


  void _onUserDataChanged() {
    try {
      String? farmId = userDataProvider?.farmId;
      if (_farmId != farmId) {
        if (_subscriptionBarnsCollection!=null) _subscriptionBarnsCollection!.cancel();

        _farmId = farmId;
        if (farmId == null || farmId.isEmpty) {
          setState(() {
            barns = [];
          });
          return; // Langsung kembali, tidak perlu membuat listener
        }

        initDataListener();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in _onUserDataChanged: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initDataListener();
      userDataProvider!.addListener(_onUserDataChanged);
    });
    
  
  }

  @override
  void dispose() {
    super.dispose();
    userDataProvider!.removeListener(_onUserDataChanged);
    if (_subscriptionBarnsCollection!=null) _subscriptionBarnsCollection!.cancel();
  }

  Future<List<BarnData>> _readBarnsCollection() async {
      List<BarnData> barns = [];

      String? farmId = userDataProvider?.farmId;
      if (farmId == null || farmId.isEmpty) return barns;

      CollectionReference barnCol = FirebaseFirestore.instance.collection('farms').doc(farmId).collection('barns');
      QuerySnapshot barnsSnapshot = await barnCol.get();
      
      for (var barnDoc in barnsSnapshot.docs) {
        BarnData barnData = BarnData(barnDoc.id, barnDoc.get('name') as String?, barnDoc.get('creator_uid') as String?, barnDoc.get('creation_date') as Timestamp?);

        // Mendapatkan subkoleksi `boxes` dari setiap `barn`
        CollectionReference boxesCol = barnDoc.reference.collection('boxes');
        QuerySnapshot boxesSnapshot = await boxesCol.get();
          for (var boxDoc in boxesSnapshot.docs) {
            BoxData boxData = BoxData(boxDoc.id, boxDoc.get('name') as String?, boxDoc.get('creator_uid') as String?, boxDoc.get('creation_date') as Timestamp?);
            barnData.boxes.add(boxData);
          }
          barns.add(barnData);
      }
      
      return barns;
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      selectedBarnIds.clear(); // Reset selection when toggling edit mode
    });
  }

  void _selectAll(bool selectAll) {
    setState(() {
      if (selectAll) {
        selectedBarnIds.clear();
        for (BarnData barn in barns) {
          if (barn.id == null) continue;
          if (barn.id!.isEmpty) continue;
          selectedBarnIds.add(barn.id!);
        }
      } else {
        selectedBarnIds.clear();
      }
    });
  }

  void _deleteSelectedBarns() async {
    if (selectedBarnIds.isEmpty) return;

    String? farmId = userDataProvider?.farmId;
    if (farmId==null || farmId.isEmpty) return;

    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Anda yakin ingin menghapus kandang yang dipilih?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed) {
      for (var barnId in selectedBarnIds) {
        await FirebaseFirestore.instance
            .collection('farms')
            .doc(farmId)
            .collection('barns')
            .doc(barnId)
            .delete();
      }

      setState(() {
        selectedBarnIds.clear();
      });
    }
  }

void _addNewBarn(BuildContext context) async {
  String? farmId = userDataProvider?.farmId;
  // Alert jika farmId tidak valid
  if (farmId == null || farmId.isEmpty) {
    _showErrorDialog(context, 'Ada yang error, silahkan lakukan login ulang');
    return;
  }

  // Menampilkan dialog untuk menginputkan nama kandang
  String? barnName = await _showInputDialog(context, 'Masukkan nama kandang');

  // Jika barnName null atau kosong, proses dihentikan
  if (barnName == null || barnName.isEmpty) {
    // Pembatalan proses jika user menekan tombol "Batal" atau tidak mengisi input
    return;
  }

  // Fetch the current count of barns
  final barnsCollection = FirebaseFirestore.instance
      .collection('farms')
      .doc(farmId)
      .collection('barns');

  // Tambahkan dokumen baru ke barns dengan nama yang diinput
  final barnDocRef = await barnsCollection.add({
    'name': barnName,
    'creator_uid': FirebaseAuth.instance.currentUser!.uid,
    'creation_date': FieldValue.serverTimestamp(),
  });

  final boxesCollection = barnDocRef.collection('boxes');

  // Menambahkan box 1
  await boxesCollection.add({
    'name': 'Box 1',
    'creator_uid': FirebaseAuth.instance.currentUser!.uid,
    'creation_date': FieldValue.serverTimestamp(),
  });

  final barnsData = await _readBarnsCollection();
  setState(() {
      barns = barnsData;
  });
  
  if (kDebugMode) {
    print('Kandang baru dengan sub-koleksi boxes berhasil ditambahkan.');
  }
}

// Fungsi untuk menampilkan AlertDialog error
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

// Fungsi untuk menampilkan AlertDialog input nama kandang
Future<String?> _showInputDialog(BuildContext context, String title) async {
  TextEditingController controller = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Nama kandang'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null); // Mengembalikan null jika batal
          },
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(controller.text); // Mengirim hasil input
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return     
    Scaffold(
      appBar: AppBar(
        title: Text('Kandang (${barns.length})'),
        actions: [
          if (isEditing)
            Row(
              children: [
                Checkbox(
                  value: selectedBarnIds.length == barns.length,
                  onChanged: (bool? value) {
                    _selectAll(value ?? false);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedBarns,
                ),
                IconButton(
                  icon: const Icon(Icons.done_all),
                  onPressed: _toggleEdit,
                ),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      body: (userDataProvider?.farmId==null || userDataProvider!.farmId!.isEmpty) ?
    const Row(
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
    ) :
    ListView.builder(
        itemCount: barns.length,
        itemBuilder: (context, index) {
          final barn = barns[index];
          final barnId = barn.id!; // Pastikan BarnData memiliki 'id'
          final barnName = barn.name ?? 'Kandang'; // Pastikan BarnData memiliki 'name'
          final boxCount = barn.boxes.length; // Misalnya barns memiliki daftar boxes

          return GestureDetector(
            onTap: () {
              if (isEditing) {
                setState(() {
                  if (selectedBarnIds.contains(barnId)) {
                    selectedBarnIds.remove(barnId);
                  } else {
                    selectedBarnIds.add(barnId);
                  }
                });
              } else {
                // Navigate to detail page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BarnDetailPage(
                        barnId: barnId, farmId: userDataProvider?.farmId),
                  ),
                );
              }
            },
            child: Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  if (isEditing)
                    Checkbox(
                      value: selectedBarnIds.contains(barnId),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedBarnIds.add(barnId);
                          } else {
                            selectedBarnIds.remove(barnId);
                          }
                        });
                      },
                    ),
                  SvgPicture.asset(
                    'assets/images/simple_barn.svg',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(barnName, style: const TextStyle(fontSize: 16)),
                        Text(
                          'Jumlah box: $boxCount',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (isEditing)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        // Konfirmasi dan hapus kandang
                        bool confirmDelete = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Konfirmasi Hapus'),
                            content: const Text('Hapus kandang ini?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );

                        if (confirmDelete) {
                          // Implementasikan logika penghapusan jika diperlukan
                        }
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewBarn(context), //ini kenapa error
        child: const Icon(Icons.add),
      ),

    );
  }
}

// Dummy detail page for navigation demonstration
class BarnDetailPage extends StatelessWidget {
  final String? farmId;
  final String? barnId;

  const BarnDetailPage({super.key, required this.farmId, required this.barnId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kandang')),
      body: Center(child: Text('Detail kandang dengan ID: $barnId')),
    );
  }
}


class BarnData {
  String? id;
  String? name;
  String? creatorUid;
  Timestamp? creationDate;
  List<BoxData> boxes = [];
  BarnData(this.id, this.name, this.creatorUid, this.creationDate);
  
}

class BoxData {
  String? id;
  String? name;
  String? creatorUid;
  Timestamp? creationDate;
  BoxData(this.id, this.name, this.creatorUid, this.creationDate);
}
