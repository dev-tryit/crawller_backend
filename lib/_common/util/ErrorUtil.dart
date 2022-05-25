import 'dart:async';

import 'package:crawller_backend/_common/util/LogUtil.dart';
class ErrorUtil {
  static void catchError(Future<void> Function() init) {
    runZonedGuarded(() async {
      await init();
    }, (Object error, StackTrace stack) {
      LogUtil.error("runZonedGuarded error:${error.toString()}, stack:${stack.toString()}");
    });
  }
}