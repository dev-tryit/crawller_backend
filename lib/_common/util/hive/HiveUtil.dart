import 'package:crawller_backend/_common/util/firebase/firedart/FiredartAuthSingleton.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class HiveUtil {
  static Future<void> init() async {
    var appDir = await getApplicationDocumentsDirectory();
    Hive.init(join(appDir.path, null));
    Hive.registerAdapter(TokenAdapter());
  }
}
