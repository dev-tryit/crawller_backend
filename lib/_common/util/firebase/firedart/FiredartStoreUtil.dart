import 'package:crawller_backend/MySetting.dart';
import 'package:firedart/firedart.dart';
import 'package:crawller_backend/_common/abstract/WithDocId.dart';
import 'package:crawller_backend/_common/util/UUIDUtil.dart';
import 'package:crawller_backend/_common/util/firebase/FirebaseStoreUtilInterface.dart';

class FiredartStoreUtil<Type extends WithDocId>
    extends FirebaseStoreUtilInterface<Type> {
  FiredartStoreUtil(
      {required String collectionName,
      required Type Function(Map<String, dynamic> map) fromMap,
      required Map<String, dynamic> Function(Type instance) toMap})
      : super(collectionName: collectionName, fromMap: fromMap, toMap: toMap) {
    try{
      Firestore.initialize(MySetting.firebaseWebConfig["projectId"]);
    }
    catch(pass){}
  }

  @override
  CollectionReference cRef() {
    return Firestore.instance.collection(collectionName);
  }

  @override
  DocumentReference dRef({int? documentId}) {
    return documentId != null
        ? cRef().document(documentId.toString())
        : cRef().document(UUIDUtil().makeUuid());
  }

  @override
  Future<Map<String, dynamic>> dRefToMap(dRef) async => (await dRef.get()).map;

  @override
  Map<String, dynamic> dSnapshotToMap(dSnapshot) => dSnapshot.map;

  @override
  Future<List> cRefToList() async => (await cRef().get());

  @override
  Future<List> queryToList(query) async => (await query.get());
}
