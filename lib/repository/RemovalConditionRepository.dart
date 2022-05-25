import 'package:crawller_backend/_common/abstract/WithDocId.dart';
import 'package:crawller_backend/_common/util/firebase/FirebaseStoreUtilInterface.dart';

class RemovalCondition extends WithDocId {
  static const String className = "RemovalCondition";
  String? type;
  String? content;
  String? typeDisplay;

  RemovalCondition(
      {required this.type, required this.content, required this.typeDisplay});

  factory RemovalCondition.fromJson(Map<String, dynamic> json) => fromMap(json);

  Map<String, dynamic> toJson() => toMap(this);

  static RemovalCondition fromMap(Map<String, dynamic> map) {
    return RemovalCondition(
      type: map['type'],
      content: map['content'],
      typeDisplay: map['typeDisplay'],
    )
      ..documentId = map['documentId']
      ..email = map['email'];
  }

  static Map<String, dynamic> toMap(RemovalCondition instance) {
    return {
      'documentId': instance.documentId,
      'email': instance.email,
      'type': instance.type,
      'content': instance.content,
      'typeDisplay': instance.typeDisplay,
    };
  }
}

class RemovalConditionRepository {
  static final RemovalConditionRepository _singleton =
      RemovalConditionRepository._internal();

  factory RemovalConditionRepository() {
    return _singleton;
  }

  RemovalConditionRepository._internal();

  final FirebaseStoreUtilInterface<RemovalCondition> _ =
      FirebaseStoreUtilInterface.init<RemovalCondition>(
    collectionName: RemovalCondition.className,
    fromMap: RemovalCondition.fromMap,
    toMap: RemovalCondition.toMap,
  );

  Future<RemovalCondition?> add(
      {required RemovalCondition removalCondition}) async {
    return await _.saveByDocumentId(instance: removalCondition);
  }

  void update(RemovalCondition removalCondition) async {
    await _.saveByDocumentId(
      instance: removalCondition,
    );
  }

  Future<bool> existDocumentId({required String documentId}) async {
    return await _.exist(
      key: "documentId",
      value: documentId,
    );
  }

  Future<void> delete({required int documentId}) async {
    await _.deleteOne(documentId: documentId);
  }

  Future<RemovalCondition?> getOneByTitle({required String title}) async {
    return await _.getOneByField(
      key: "title",
      value: title,
      onlyMyData: true,
    );
  }

  Future<List<RemovalCondition>> getList() async {
    return await _.getList(onlyMyData: true);
  }

  Future<List<RemovalCondition>> getListByType({required String type}) async {
    return await _.getList(key: "type", value: type, onlyMyData: true);
  }
}
