import 'package:firebase_auth/firebase_auth.dart';
import 'package:leafy_lenz/services/db_services.dart';

class AuthService{
  final _auth =  FirebaseAuth.instance;
  final _store = DataBaseService();

  String? getUserId(){
    final user = _auth.currentUser;
    return user!.uid;
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password, String name, String gender, String age) async {
    try{
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      await _store.addUser(user!.uid, email, name, gender, age);
      return user;
    }catch(e){
      throw Exception(e);
    }
  }

  String? getCurrentUserEmail() {
    User? user = _auth.currentUser;
    return user?.email;
  }

  bool? getCurrentUserEmailStatus(){
    User? user = _auth.currentUser;
    //return user?.emailVerified;
    return true;
  }

  Future<User?> signinUserWithEmailAndPassword(String email, String password) async {
    try{
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return cred.user;
    }catch(e){
      throw Exception(e);
    }
  }

  Future<void> signout() async{
    try{
      await _auth.signOut();
    }catch(e){
      throw Exception(e);
    }
}
}