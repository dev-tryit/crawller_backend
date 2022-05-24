import 'package:hello_world_function/_common/abstract/WithDocId.dart';

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
