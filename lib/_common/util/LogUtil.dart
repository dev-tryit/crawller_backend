import 'package:crawller_backend/MySetting.dart';
import 'package:logger/logger.dart';
import "package:stack_trace/stack_trace.dart";

class MyFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    var shouldLog = false;
    if (event.level.index >= level!.index) {
      shouldLog = true;
    }
    return shouldLog;
  }
}

class LogUtil {
  static const bool _showLogLevel = false;
  static const bool _showAppName = false;
  static const bool _showMethodName = true;
  static final _filter = MySetting.isRelease ? DevelopmentFilter() : MyFilter(); //DevelopmentFilter는 release에서 작동안해서 테스트를 위해 사용.
  static final Logger _logger = Logger(
    filter: _filter,
    level: MySetting.isRelease ? Level.warning : Level.debug,
    printer: SimplePrinter(printTime: true, colors: true),
    // output: LogConsole.wrap(innerOutput: ConsoleOutput()),
    // printer: new PrettyPrinter(
    //     methodCount: 0,
    //     // // number of method calls to be displayed
    //     // errorMethodCount: 8,
    //     // // number of method calls if stacktrace is provided
    //     // lineLength: 600,
    //     // // width of the output
    //     colors: true,
    //     // // Colorful log messages
    //     // printEmojis: true,
    //     // // Print an emoji for each log message
    //     // printTime: true // Should each log print contain a timestamp
    //     ),
  );

  static void setDebugLevel() {
    _filter.level = Level.debug;
  }

  static void info(String msg) {
    _logger.i(makeLogString(msg));
  }

  static void debug(String msg) {
    _logger.d(makeLogString(msg));
  }

  static void warn(String msg) {
    _logger.w(makeLogString(msg));
  }

  static void error(String msg) {
    _logger.e(makeLogString(msg));
  }

  static String makeLogString(String msg) {
    String logStr = "";

    if (_showLogLevel) {
      String? logLevel = Trace?.current().frames[1].member;
      logLevel = logLevel != null ? logLevel.split(".")[1] : null;
      logStr += "[$logLevel] ";
    }

    if (_showAppName) {
      logStr += "[${MySetting.appName}_APP] ";
    }

    if (_showMethodName) {
      String? methodName = Trace?.current().frames[2].member;
      logStr += "[$methodName] ";
    }

    logStr += msg;
    return logStr;
  }
}
