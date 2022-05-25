import 'dart:io';

import 'package:crawller_backend/_common/util/firebase/firedart/FiredartAuthSingleton.dart';
import 'package:hive/hive.dart';

class HiveUtil {
  static Future<void> init() async {
    Hive.init(Directory.current.absolute.path);
    Hive.registerAdapter(TokenAdapter());
  }
}
