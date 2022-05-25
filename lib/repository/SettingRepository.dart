import 'package:crawller_backend/_common/abstract/WithDocId.dart';
import 'package:crawller_backend/_common/util/firebase/FirebaseStoreUtilInterface.dart';

class Setting extends WithDocId {
  static const String className = "Setting";
  String? sumgoId;
  String? sumgoPw;
  String? crallwerUrl;

  Setting(
      {required this.sumgoId,
        required this.sumgoPw,
        required this.crallwerUrl});

  factory Setting.fromJson(Map<String, dynamic> json) => fromMap(json);

  Map<String, dynamic> toJson() => toMap(this);

  static Setting fromMap(Map<String, dynamic> map) {
    return Setting(
      sumgoId: map['sumgoId'],
      sumgoPw: map['sumgoPw'],
      crallwerUrl: map['crallwerUrl'],
    )
      ..documentId = map['documentId']
      ..email = map['email'];
  }

  static Map<String, dynamic> toMap(Setting instance) {
    return {
      'documentId': instance.documentId,
      'email': instance.email,
      'sumgoId': instance.sumgoId,
      'sumgoPw': instance.sumgoPw,
      'crallwerUrl': instance.crallwerUrl,
    };
  }
}

class SettingRepository {
  static final SettingRepository _singleton = SettingRepository._internal();

  factory SettingRepository() {
    return _singleton;
  }

  SettingRepository._internal();

  final FirebaseStoreUtilInterface<Setting> _ =
      FirebaseStoreUtilInterface.init<Setting>(
    collectionName: Setting.className,
    fromMap: Setting.fromMap,
    toMap: Setting.toMap,
  );

  Future<Setting?> save({required Setting setting}) async {
    return await _.saveByDocumentId(instance: setting);
  }
  Future<bool> existDocumentId({required String documentId}) async {

    return await _.exist(
        query: _.cRef().where("documentId", isEqualTo: documentId));
  }

  Future<void> delete({required int documentId}) async {
    await _.deleteOne(documentId: documentId);
  }

  Future<Setting?> getOne({required int documentId}) async {
    return await _.getOne(documentId: documentId);
  }

  Future<List<Setting>> getList(String email) async {
    return await _.getList(query: _.cRef().where("email", isEqualTo: email));
  }
}
