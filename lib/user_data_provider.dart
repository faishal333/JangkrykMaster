import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataProvider extends ChangeNotifier {
  final User user;
  DocumentSnapshot? _user;
  StreamSubscription<DocumentSnapshot>? _subscription;

  String? get farmId => _user?.get('farm_id'); // Mendapatkan farmId dari data user

  UserDataProvider({required this.user});

  Future<void> init() async {
    await _initializeUserDatabase();
    await _initializeListener();
  }

  Future<void> _initializeUserDatabase() async {
    try {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      DocumentSnapshot docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        // Set data awal user jika dokumen belum ada
        await userDoc.set({
          'name': user.displayName ?? 'User${Random().nextInt(100000)}',
          'email': user.email ?? '',
          'creation_time': FieldValue.serverTimestamp(),
          'birth_date': FieldValue.serverTimestamp(),
          'address': '',
          'gender': '',
          'nik': '',
          'phone_number': user.phoneNumber ?? '',
          'photo_url': user.photoURL ?? '',
          'farm_id': '', // Field farm_id
        });

        docSnapshot = await userDoc.get();
      }

      _user = docSnapshot;
    } catch (e) {
      if (kDebugMode) {
        print('Error in _initializeUserDatabase: $e');
      }
    }
  }

  Future<void> _initializeListener() async {
    try {
      _subscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen(
            (snapshot) {
              _user = snapshot;
              notifyListeners(); // Notifikasi jika data user berubah
            },
            onError: (error) {
              if (kDebugMode) {
                print('Error listening to user data: $error');
              }
            },
          );
    } catch (e) {
      if (kDebugMode) {
        print('Error in UserDataProvider._initializeListener: $e');
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Membatalkan listener jika ada
    _user = null;
    super.dispose();
  }
}

UserDataProvider? userDataProvider;