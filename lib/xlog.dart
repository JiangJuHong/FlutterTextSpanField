/// 日志工具类
class Utils {
  /// 输出和log
  ///
  /// [showTime]  默认为true，会输出当前的时间
  /// [showLine]  默认为true，会输出当前调用方法的包路径
  static void log(String message, {bool showTime: true, bool showLine: true, String type: 'LOG',}) {
    _print(message, showTime: showTime, showLine: showLine, type: type);
  }

  static void _print(String message, {bool showTime: true, String type: 'info', bool showLine: true}) {

    print("[$type] ${showTime ? '[${DateTime.now()}]' : ''} \t $message ");
    if (showLine) {
      String stackTrace = StackTrace.current.toString();
      // 第0个，是当前_print，第1个是log，第2个是调用输出
      var line = stackTrace.split("\n")[2].replaceAll(' ', '').replaceAll('#1', '');
      print("[堆栈] $line");
    }
  }
}