import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String,dynamic>>? getFirebaseDoc(String path, String id)async{
  var d = await FirebaseFirestore.instance.collection(path).doc(id).get();
  Map<String,dynamic> s = d.data() ?? {};
  s.addAll({'id':id});
  return s;
}