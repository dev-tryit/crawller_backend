import 'dart:io';

import 'package:crawller_backend/_common/util/firebase/firedart/FiredartAuthSingleton.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';

class HiveUtil {
  static Future<void> init() async {
    String dirPath = dirname(Platform.script.toFilePath());
    Hive.init(dirPath);
    Hive.registerAdapter(TokenAdapter());
  }
}
