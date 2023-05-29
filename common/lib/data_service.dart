import 'package:cloud_firestore/cloud_firestore.dart';

class DataService {
  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentSession() {
    return FirebaseFirestore.instance.collection('gigs').doc('current').get();
  }
}
