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
        query: _.cRef().where("documentId", isEqualTo: documentId));
  }

  Future<void> delete({required int documentId}) async {
    await _.deleteOne(documentId: documentId);
  }

  Future<RemovalCondition?> getOneByTitle(
      {required String email, required String title}) async {
    return await _.getOneByField(
        query: _
            .cRef()
            .where("email", isEqualTo: email)
            .where("title", isEqualTo: title));
  }

  Future<List<RemovalCondition>> getList(String email) async {
    return await _.getList(query: _.cRef().where("email", isEqualTo: email));
  }

  Future<List<RemovalCondition>> getListByType(
      {required String email, required String type}) async {
    return await _.getList(
        query: _
            .cRef()
            .where("email", isEqualTo: email)
            .where("type", isEqualTo: type));
  }
}

class RemovalType {
  static RemovalType get best => const RemovalType.internal("최우선키워드", "best");

  static RemovalType get include => const RemovalType.internal("포함", "include");

  static RemovalType get exclude => const RemovalType.internal("제외", "exclude");

  static List<RemovalType> get values => [
        RemovalType.include,
        RemovalType.exclude,
        RemovalType.best,
      ];

  final String display;
  final String value;

  const RemovalType.internal(this.display, this.value);
}
