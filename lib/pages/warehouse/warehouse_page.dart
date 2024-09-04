import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jangkrykmaster/pages/farm_data_provider.dart';

class WarehousePage extends StatefulWidget {
  const WarehousePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WarehousePageState createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {

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
        title: const Text('Gudang'),
      ),
      body: Column(
        children: [
          // ListView 2 kolom untuk warehouse_core
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('farms/${farmDataProvider!.farmId??''}/warehouse_core')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Tidak ada item lain.'));
                }

                var items = snapshot.data!.docs;
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var item = items[index];
                    return 
                    Card(
                      margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                child: SvgPicture.asset(
                                  'assets/images/${item.id}.svg',
                                  width: 64,
                                  height: 64,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      item['count'].toString(),
                                      style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      item['unit'].toString(),
                                      style: const TextStyle(color: Colors.black38, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 30,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.vertical(),
                            ),
                            child: Text(
                              item['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
         
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Fungsi untuk menambahkan item baru
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}