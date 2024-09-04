import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jangkrykmaster/user_data_provider.dart';

class FarmDataProvider extends ChangeNotifier {
  final UserDataProvider userDataProvider;
  StreamSubscription<DocumentSnapshot>? _subscription;
  String? _farmId;
  DocumentSnapshot? _farm;

  String? get farmId => _farmId;
  DocumentSnapshot? get farm => _farm;
  
  FarmDataProvider({required this.userDataProvider});

  Future<void> init() async {
    await _initializeListener();
    userDataProvider.addListener(_onUserDataChanged);
  }

  Future<void> _initializeListener() async {
    try {
      String? farmId = userDataProvider.farmId;

      if (farmId == null || farmId.isEmpty) {
        // Tidak perlu membuat listener
        _farm = null;
        notifyListeners(); // Memberikan notifikasi jika tidak ada farmId
        return;
      }

      _farmId = farmId;

      DocumentReference farmDoc = FirebaseFirestore.instance.collection('farms').doc(farmId);
      _farm = await farmDoc.get();

      _subscription = FirebaseFirestore.instance
          .collection('farms')
          .doc(farmId)
          .snapshots()
          .listen((snapshot) {
            _farm = snapshot;
            notifyListeners(); // Notifikasi jika data farm berubah
          }, onError: (error) {
            if (kDebugMode) {
              print('Error listening to farm data: $error');
            }
          });
    } catch (e) {
      if (kDebugMode) {
        print('Error in _initializeFarmData: $e');
      }
    }
  }


  void _onUserDataChanged() {
    try {
      String? farmId = userDataProvider.farmId;

      if (_farmId != farmId) {
        _farmId = farmId;
        if (farmId == null || farmId.isEmpty) {
          _farm = null;
          _subscription?.cancel(); // Membatalkan listener sebelumnya jika ada
          notifyListeners(); // Memberikan notifikasi jika tidak ada farmId
          return; // Langsung kembali, tidak perlu membuat listener
        }

        _farm = null;
        _subscription?.cancel(); // Membatalkan listener sebelumnya jika ada
        
        _subscription = FirebaseFirestore.instance
            .collection('farms')
            .doc(farmId)
            .snapshots()
            .listen((snapshot) {
              
              _farm = snapshot;
              notifyListeners(); // Notifikasi jika data farm berubah
            }, onError: (error) {
              if (kDebugMode) {
                print('Error listening to farm data: $error');
              }
            });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in _onUserDataChanged: $e');
      }
    }
  }

  @override
  void dispose() {
    userDataProvider.removeListener(_onUserDataChanged);
    _subscription?.cancel(); // Membatalkan listener jika ada
    _farm = null;
    super.dispose();
  }

}

FarmDataProvider? farmDataProvider;