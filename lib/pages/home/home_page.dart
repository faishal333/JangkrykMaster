import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jangkrykmaster/pages/farm_data_provider.dart';
import 'package:jangkrykmaster/pages/home/create_farm_page.dart';
import 'package:jangkrykmaster/pages/home/widgets/cricketmarket_chart.dart';
import 'package:jangkrykmaster/pages/home/farm_page.dart';
import 'package:jangkrykmaster/pages/home/widgets/reminder_list.dart';
import 'package:jangkrykmaster/user_data_provider.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class AnimatedLabelData {
  bool state = true;
  int currentIndex = 0;
  final List<String> items;
  AnimatedLabelData({required this.items});
}

class _HomePageState extends State<HomePage> {
  String? _farmId;
  String? farmName;

  final AnimatedLabelData farmSubText = AnimatedLabelData(
   items : [
    'Memuat...', //jumlah kandang
    'Memuat...', //jumlah box
    'Memuat...', //jumlah proyek
    'Memuat...', //jumlah staff
    'Memuat...', //jumlah item gudang
  ]
  );

  StreamSubscription<DocumentSnapshot>? _subscriptionFarmDocument;
  StreamSubscription<QuerySnapshot>? _subscriptionBarnsCollection;
  StreamSubscription<QuerySnapshot>? _subscriptionProjectsCollection;
  StreamSubscription<QuerySnapshot>? _subscriptionStaffCollection;
  StreamSubscription<QuerySnapshot>? _subscriptionWarehouseCoreCollection;
  StreamSubscription<QuerySnapshot>? _subscriptionWarehouseOtherCollection;

void initDataListener() async {
  if (farmDataProvider!.farm != null) {

    // Query untuk mendapatkan data farm
    _subscriptionFarmDocument = FirebaseFirestore.instance
        .collection('farms')
        .doc(farmDataProvider!.farmId)
        .snapshots()           
        .listen((snapshot) async {
        // Update UI menggunakan setState setelah data diambil
        setState(() {
          farmName = snapshot.get('name') as String?;
        });

        }, onError: (error) {
          if (kDebugMode) {
            print('Error listening to farm data: $error');
          }
        });

    // Query untuk mendapatkan jumlah kandang, box
    _subscriptionBarnsCollection = FirebaseFirestore.instance
        .collection('farms')
        .doc(farmDataProvider!.farmId)
        .collection('barns')
        .snapshots()           
        .listen((snapshot) async {
        // Menghitung jumlah total box dari setiap kandang
        int jumlahBox = 0;
        for (var barn in snapshot.docs) {
          // Mendapatkan subkoleksi `boxes` dari setiap `barn`
          CollectionReference boxesCol = barn.reference.collection('boxes');
          QuerySnapshot boxesSnapshot = await boxesCol.get();
          jumlahBox += boxesSnapshot.size;
        }

        // Update UI menggunakan setState setelah data diambil
        setState(() {
          farmSubText.items[0] = 'Kandang : ${snapshot.size}';
          farmSubText.items[1] = 'Box : $jumlahBox';
        });

        }, onError: (error) {
          if (kDebugMode) {
            print('Error listening to farm data: $error');
          }
        });
    
    // Query untuk mendapatkan jumlah proyek
    _subscriptionProjectsCollection = FirebaseFirestore.instance
        .collection('farms')
        .doc(farmDataProvider!.farmId)
        .collection('projects')
        .snapshots()           
        .listen((snapshot) async {
        
        // Update UI menggunakan setState setelah data diambil
        setState(() {
          farmSubText.items[2] = 'Proyek : ${snapshot.size}';
        });

        }, onError: (error) {
          if (kDebugMode) {
            print('Error listening to farm data: $error');
          }
        });
    
    // Query untuk mendapatkan jumlah staff
    _subscriptionStaffCollection = FirebaseFirestore.instance
        .collection('farms')
        .doc(farmDataProvider!.farmId)
        .collection('staff')
        .snapshots()           
        .listen((snapshot) async {
        
        // Update UI menggunakan setState setelah data diambil
        setState(() {
          farmSubText.items[3] = 'Staff : ${snapshot.size}';
        });

        }, onError: (error) {
          if (kDebugMode) {
            print('Error listening to farm data: $error');
          }
        });
    
    // Query untuk mendapatkan jumlah warehouse_core
    _subscriptionWarehouseCoreCollection = FirebaseFirestore.instance
        .collection('farms')
        .doc(farmDataProvider!.farmId)
        .collection('warehouse_core')
        .snapshots()           
        .listen((snapshot) async {

        CollectionReference warehouseOtherCol = FirebaseFirestore.instance
            .collection('farms')
            .doc(farmDataProvider!.farmId)
            .collection('warehouse_other');
        QuerySnapshot warehouseOtherSnapshot = await warehouseOtherCol.get();
        int jumlahItems = warehouseOtherSnapshot.size + snapshot.size;
        
        // Update UI menggunakan setState setelah data diambil
        setState(() {
            farmSubText.items[4] = 'Gudang : $jumlahItems';
        });

        }, onError: (error) {
          if (kDebugMode) {
            print('Error listening to farm data: $error');
          }
        });

    // Query untuk mendapatkan jumlah warehouse_core
    _subscriptionWarehouseOtherCollection = FirebaseFirestore.instance
        .collection('farms')
        .doc(farmDataProvider!.farmId)
        .collection('warehouse_other')
        .snapshots()           
        .listen((snapshot) async {

        CollectionReference warehouseCoreCol = FirebaseFirestore.instance
            .collection('farms')
            .doc(farmDataProvider!.farmId)
            .collection('warehouse_core');
        QuerySnapshot warehouseCoreSnapshot = await warehouseCoreCol.get();
        int jumlahItems = warehouseCoreSnapshot.size + snapshot.size;
        
        // Update UI menggunakan setState setelah data diambil
        setState(() {
            farmSubText.items[4] = 'Gudang : $jumlahItems';
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
        if (_subscriptionFarmDocument!=null) _subscriptionFarmDocument!.cancel();
        if (_subscriptionBarnsCollection!=null) _subscriptionBarnsCollection!.cancel();
        if (_subscriptionProjectsCollection!=null) _subscriptionProjectsCollection!.cancel();
        if (_subscriptionStaffCollection!=null) _subscriptionStaffCollection!.cancel();
        if (_subscriptionWarehouseCoreCollection!=null) _subscriptionWarehouseCoreCollection!.cancel();
        if (_subscriptionWarehouseOtherCollection!=null) _subscriptionWarehouseOtherCollection!.cancel();

        _farmId = farmId;
        if (farmId == null || farmId.isEmpty) {
          //_farm = null;
          //_subscription?.cancel(); // Membatalkan listener sebelumnya jika ada
          //notifyListeners(); // Memberikan notifikasi jika tidak ada farmId
          
          setState(() {
            farmName = null;
            farmSubText.items[0] = 'Memuat...';
            farmSubText.items[1] = 'Memuat...';
            farmSubText.items[2] = 'Memuat...';
            farmSubText.items[3] = 'Memuat...';
            farmSubText.items[4] = 'Memuat...';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initDataListener();
      userDataProvider!.addListener(_onUserDataChanged);
    });
  }

  @override
  void dispose() {
    super.dispose();
    userDataProvider!.removeListener(_onUserDataChanged);
    if (_subscriptionFarmDocument!=null) _subscriptionFarmDocument!.cancel();
    if (_subscriptionBarnsCollection!=null) _subscriptionBarnsCollection!.cancel();
    if (_subscriptionProjectsCollection!=null) _subscriptionProjectsCollection!.cancel();
    if (_subscriptionStaffCollection!=null) _subscriptionStaffCollection!.cancel();
    if (_subscriptionWarehouseCoreCollection!=null) _subscriptionWarehouseCoreCollection!.cancel();
    if (_subscriptionWarehouseOtherCollection!=null) _subscriptionWarehouseOtherCollection!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: const Text('Home Page')),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: 
      SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(5.0, MediaQuery.of(context).padding.top, 5.0, 16.0), // Beri jarak sesuai status bar
        child: 

        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
      
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//TOPBAR/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

          Container(
            height: 70.0,
            alignment: Alignment.center,
            margin: const EdgeInsets.fromLTRB(0,8,0,8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8.0),),
            ),

            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
              
              TextButton(onPressed: () { 
                if (farmDataProvider!.farm == null) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CreateFarmPage()),);
                      
                } else {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FarmPage(farmId: farmDataProvider!.farm!.id)),);
                  
                }
               },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(8.0),
                backgroundColor: Colors.transparent, // Background transparan
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                foregroundColor: Colors.black,
              ),
              child: 
                Container(
                  width: 125.0,
                  margin: const EdgeInsets.all(0.0),
                  padding: const EdgeInsets.all(0.0),
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [const Icon(Icons.warehouse, color: Colors.amber, size: 24.0),
                        const SizedBox(width: 5.0),
                        Expanded(  // Tambahkan Expanded di sini agar TextOverflow.ellipsis bekerja
                        child: Text(
                          
                          (farmDataProvider!.farm == null)
                              ? 'Buat sekarang' // Teks jika farm_id kosong
                              : (farmDataProvider!.farm!.get('name') as String?) ?? 'Memuat...', // Teks jika farm_id terisi
                          
                          overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87, fontSize: 12.0, fontWeight: FontWeight.w500)),
                        ),
                      ],),

                      Row(
                        children: [
                        
                          (farmDataProvider!.farm == null) ?
                          Container(color: Colors.transparent, alignment: Alignment.centerLeft, child: const Text('Buat farm sekarang', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black45, fontSize: 11)))
                        : ClipRect( // Membatasi area animasi
                          child: SizedBox(
                            width: 125,
                            height: 20,
                            child: 
                            
                            WidgetAnimator(incomingEffect: WidgetTransitionEffects.incomingSlideInFromBottom(
                                    offset: const Offset(0, 7),
                                    duration: const Duration(milliseconds: 500), // Ubah durasi sesuai kebutuhan
                                  ),
                                  onIncomingAnimationComplete: (p0) async {
                                    await Future.delayed(const Duration(milliseconds: 5000)); // Delay selama 1 detik
                                    setState(() {
                                      farmSubText.state = !farmSubText.state;
                                      farmSubText.currentIndex = (farmSubText.currentIndex + 1) % farmSubText.items.length; // Update index

                                    });
                                  },
                                  outgoingEffect: WidgetTransitionEffects.outgoingSlideOutToTop(
                                    offset: const Offset(0, -7),
                                    duration: const Duration(milliseconds: 500), // Ubah durasi sesuai kebutuhan
                                  ),
                                  onOutgoingAnimationComplete: (p0) async {
                                  },
                              child: (farmSubText.state)
                                  ? Container(key: const ValueKey('blue'), color: Colors.transparent, alignment: Alignment.centerLeft, child: Text(farmSubText.items[farmSubText.currentIndex], overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black45, fontSize: 11)))
                                  : Container(key: const ValueKey('red'), color: Colors.transparent, alignment: Alignment.centerLeft, child: Text(farmSubText.items[farmSubText.currentIndex], overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black45, fontSize: 11))),
                            ),
                          
                          ),
                        ),
                      
                      
                      ],),



                    ]
                  ),
                  ),
                  
              ),
              
              Container(width: 1,
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
              child: Container(color: Colors.black12,)
              ,),

              (farmDataProvider!.farm == null)?
              Container():
              TextButton(onPressed: () {  },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(8.0),
                backgroundColor: Colors.transparent, // Background transparan
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                foregroundColor: Colors.black,
              ),
              child: 
                Container(
                  width: 115.0,
                  margin: const EdgeInsets.all(0.0),
                  padding: const EdgeInsets.all(0.0),
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Icon(Icons.dashboard, color: Colors.blue, size: 24.0),
                        SizedBox(width: 5.0),
                        Text("Proyek", style: TextStyle(color: Colors.black87, fontSize: 12.0, fontWeight: FontWeight.w500)),
                      ],),

                      Row(
                        children: [
                        const SizedBox(width: 5.0),
                        ClipRect( // Membatasi area animasi
                          child: SizedBox(
                            height: 20,
                            child: Container(color: Colors.transparent, alignment: Alignment.centerLeft, 
                            child: 
                            const Text("Kelola sekarang", style: TextStyle(color: Colors.black45, fontSize: 11))),
                          ),
                        ),
                      ],),



                    ]
                  ),
                  ),
                  
              ),
              
              
              (farmDataProvider!.farm == null)?
              Container():
              Container(width: 1,
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
              child: Container(color: Colors.black12,)
              ,),


              TextButton(onPressed: () {  },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(8.0),
                backgroundColor: Colors.transparent, // Background transparan
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                foregroundColor: Colors.black,
              ),
              child: 
                Container(
                  width: 130.0,
                  margin: const EdgeInsets.all(0.0),
                  padding: const EdgeInsets.all(0.0),
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Icon(Icons.monetization_on, color: Colors.green, size: 24.0),
                        SizedBox(width: 5.0),
                        Text("Keuangan", style: TextStyle(color: Colors.black87, fontSize: 12.0, fontWeight: FontWeight.w500)),
                      ],),

                      Row(
                        children: [
                        const SizedBox(width: 5.0),
                        ClipRect( // Membatasi area animasi
                          child: SizedBox(
                            height: 20,
                            child: Container(color: Colors.transparent, alignment: Alignment.centerLeft, 
                            child: 
                            const Text("Kelola sekarang", style: TextStyle(color: Colors.black45, fontSize: 11))),
                          ),
                        ),
                      ],),


                    ]
                  ),
                  ),
                  
              ),
              


              ],
            ),
          ),

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//MISIHARIAN/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

          Container(
            height: 100.0,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8.0),),
            ),
            child: 
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Tugas harian : ", style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.w400)),
                const SizedBox(height: 5.0),
                SizedBox(
                  width: 1000.0,
                  height: 60.0,
                  child: 
                  ElevatedButton(
                    onPressed: () {  },
                    style: ElevatedButton.styleFrom(
                      //padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      backgroundColor: Colors.green, // Background transparan
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                      foregroundColor: Colors.black,
                    ), child: const Text("Yuk perbarui data peternakan Anda", style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ),
              
            ],)


          ),


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//CHART//////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

          Container(
            height: 150.0,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            margin: const EdgeInsets.fromLTRB(0,8,0,8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8.0),),
            ),
            child: const PriceChartWidget(
              harga: [80000, 90000, 100000, 120000, 150000, 160000, 170000, 150000, 140000, 160000, 180000, 190000, 200000, 180000, 170000, 160000, 150000, 140000, 130000, 140000, 160000, 180000, 200000, 220000, 250000],
              volume: [50, 60, 55, 70, 85, 90, 75, 65, 80, 95, 100, 85, 70, 60, 55, 65, 70, 60, 50, 65, 75, 85, 95, 100, 80],),

            ),


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//REMINDERLIST//////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////



          Container(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            decoration: const BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.all(Radius.circular(8.0),),
            ),
            child: Column(children: [
            const Text(
                    "Reminder",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black45, fontSize: 16.0, fontWeight: FontWeight.w400),
                  ),

            ReminderList(
                                reminders: [
                                  Reminder(
                                    title: const Text("Jangkrik siap panen", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 14.0, fontWeight: FontWeight.w400)), 
                                    description: const Text("5 hari lagi (box no.6)", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black45, fontSize: 11.0, fontWeight: FontWeight.normal))
                                  ),
                                    
                                  Reminder(
                                    title: const Text("Telur jangkrik menetas", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 14.0, fontWeight: FontWeight.w400)), 
                                    description: const Text("3 hari lagi (box no.17)", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black45, fontSize: 11.0, fontWeight: FontWeight.normal))
                                  ),

                                  Reminder(
                                    title: const Text("Stock egg tray menipis", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 14.0, fontWeight: FontWeight.w400)), 
                                    description: const Text("Tersisa 50 lembar", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.red, fontSize: 11.0, fontWeight: FontWeight.normal))
                                  ),

                                  Reminder(
                                    title: const Text("Stock pakan menipis", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 14.0, fontWeight: FontWeight.w400)), 
                                    description: const Text("Tersisa 23 kg", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.red, fontSize: 11.0, fontWeight: FontWeight.normal))
                                  ),

                                  Reminder(
                                    title: const Text("Stock pakan menipis", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 14.0, fontWeight: FontWeight.w400)), 
                                    description: const Text("Tersisa 23 kg", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.red, fontSize: 11.0, fontWeight: FontWeight.normal))
                                  ),

                                  Reminder(
                                    title: const Text("Stock pakan menipis", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 14.0, fontWeight: FontWeight.w400)), 
                                    description: const Text("Tersisa 23 kg", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.red, fontSize: 11.0, fontWeight: FontWeight.normal))
                                  ),

                                  Reminder(
                                    title: const Text("Stock pakan menipis", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 14.0, fontWeight: FontWeight.w400)), 
                                    description: const Text("Tersisa 23 kg", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.red, fontSize: 11.0, fontWeight: FontWeight.normal))
                                  ),

                                  Reminder(
                                    title: const Text("Stock pakan menipis", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 14.0, fontWeight: FontWeight.w400)), 
                                    description: const Text("Tersisa 23 kg", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.red, fontSize: 11.0, fontWeight: FontWeight.normal))
                                  ),

                                  Reminder(
                                    title: const Text("Stock pakan menipis", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 14.0, fontWeight: FontWeight.w400)), 
                                    description: const Text("Tersisa 23 kg", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.red, fontSize: 11.0, fontWeight: FontWeight.normal))
                                  ),

                                  Reminder(
                                    title: const Text("Stock pakan menipis", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 14.0, fontWeight: FontWeight.w400)), 
                                    description: const Text("Tersisa 23 kg", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.red, fontSize: 11.0, fontWeight: FontWeight.normal))
                                  ),

                                  Reminder(
                                    title: const Text("Stock pakan menipis", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 14.0, fontWeight: FontWeight.w400)), 
                                    description: const Text("Tersisa 23 kg", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.red, fontSize: 11.0, fontWeight: FontWeight.normal))
                                  ),

                                  Reminder(
                                    title: const Text("Stock pakan menipis", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 14.0, fontWeight: FontWeight.w400)), 
                                    description: const Text("Tersisa 23 kg", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.red, fontSize: 11.0, fontWeight: FontWeight.normal))
                                  ),

                                  Reminder(
                                    title: const Text("Stock pakan menipis", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black87, fontSize: 14.0, fontWeight: FontWeight.w400)), 
                                    description: const Text("Tersisa 23 kg", overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.red, fontSize: 11.0, fontWeight: FontWeight.normal))
                                  ),


                                ],
                              ),
                      

            ],)
            ),

          
          
          ]
        ),
      
      
      )
    );
  }
}
