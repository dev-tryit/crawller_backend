import 'package:uuid/uuid.dart';

class UUIDUtil {
  String makeUuid(
      {bool isRandomBased = true, bool isTimeSpaceBased = false}) {
    var uuid = const Uuid();
    return (isRandomBased ? uuid.v4() : uuid.v1());
  }
}
