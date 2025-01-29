import 'package:cloud_firestore/cloud_firestore.dart';

class DataBaseService{
  final _store = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> fetchUserDetails(String uid) async {
    final doc = await _store.collection('users').doc(uid).collection('details').doc('info').get();
    if (doc.exists) {
      return doc.data();
    } else {
      print("User data not found");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchGuides(String uid) async{
    try{
      final guides = await _store.collection('users').doc(uid).collection('guides').get();
      //print(guides.docs.map((doc) => doc.data()).toList());
      return guides.docs.map((doc) => doc.data()).toList();
    }catch(e){
      throw Exception(e);
    }
  }

  addGuide(String uid, String guideID, Map<String, dynamic> guide) async {
    try{
      await _store.collection('users').doc(uid).collection('guides').doc(guideID).set(guide);
    }catch(e){
      throw Exception(e);
    }
  }

  delGuide(String uid, String guideID) async{
    try{
      await _store.collection('users').doc(uid).collection('guides').doc(guideID).delete();
    }catch(e){
      throw Exception(e);
    }
  }

  updateGuide(String uid, String guideID, Map<String, dynamic> updated_guide) async {
    try{
      await _store.collection('users').doc(uid).collection('guides').doc(guideID).update(updated_guide);
    }catch(e){
      throw Exception(e);
    }
  }

  addUser(String uid, String email, String name, String gender, String age) async {
    try{
       await _store
          .collection('users')
          .doc(uid)
          .collection('details')
          .doc('info')
          .set({
        "name": name,
        "email": email,
        "gender": gender,
        "age": age,
        "coins": 10,
      });
    }catch(e){
      throw Exception(e);
    }
  }

  Future<void> decrementCoinsSafely(String uid) async {
    final doc = await fetchUserDetails(uid);
    await _store
          .collection('users')
          .doc(uid)
          .collection('details')
          .doc('info')
          .update({
        "coins": FieldValue.increment(-5), // Decrement by 'amount'
      });

  }

  Future<void> incrementCoins(String uid) async {
    await _store
        .collection('users')
        .doc(uid)
        .collection('details')
        .doc('info')
        .update({"coins": FieldValue.increment(5)});
  }
}