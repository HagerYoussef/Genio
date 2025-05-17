import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<List<Map<String, dynamic>>> getAllDocuments(String collection) async {
    final snapshot = await _db.collection(collection).get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Future<Map<String, dynamic>?> getDocumentById(String collection, String docId) async {
    final doc = await _db.collection(collection).doc(docId).get();
    return doc.exists ? doc.data() : null;
  }

  static Future<List<Map<String, dynamic>>> queryDocuments(
      String collection,
      String field,
      dynamic value,
      ) async {
    final snapshot = await _db.collection(collection).where(field, isEqualTo: value).get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }
}















/*
  static Future<void> addData(String collection, Map<String, dynamic> data) async {
    await _db.collection(collection).add(data);
  }

  static Future<void> updateData(String collection, String docId, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(docId).update(data);
  }

  static Future<void> deleteData(String collection, String docId) async {
    await _db.collection(collection).doc(docId).delete();
  }
 */
