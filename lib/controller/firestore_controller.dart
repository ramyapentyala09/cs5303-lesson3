import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';

class FirestoreController {
  static Future<String> addPhotoMemo({
    required PhotoMemo photoMemo,
  }) async 
  
  {
    DocumentReference ref = await FirebaseFirestore.instance.collection(Constant.PHOTOMEMO_COLLECTION)
    .add(photoMemo.toFirestoreDoc());
 return ref.id; // doc id
  }
}