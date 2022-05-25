import 'dart:io';

import 'package:crawller_backend/_common/util/firebase/firedart/FiredartAuthSingleton.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';

class HiveUtil {
  static Future<void> init() async {
    Hive.init(join(Platform.script.toFilePath(), null));
    Hive.registerAdapter(TokenAdapter());
  }
}
