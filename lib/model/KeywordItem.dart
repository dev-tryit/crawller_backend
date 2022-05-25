
import 'package:crawller_backend/_common/abstract/WithDocId.dart';

class KeywordItem extends WithDocId {
  static const String className = "KeywordItem";
  String? keyword;
  int? count;

  KeywordItem({required this.keyword, required this.count});

  factory KeywordItem.fromJson(Map<String, dynamic> json) => fromMap(json);

  Map<String, dynamic> toJson() => toMap(this);

  static KeywordItem fromMap(Map<String, dynamic> map) {
    return KeywordItem(
      keyword: map['keyword'],
      count: map['count'],
    )
      ..documentId = map['documentId']
      ..email = map['email'];
  }

  static Map<String, dynamic> toMap(KeywordItem instance) {
    return {
      'documentId': instance.documentId,
      'email': instance.email,
      'keyword': instance.keyword,
      'count': instance.count,
    };
  }
}