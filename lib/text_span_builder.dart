import 'package:flutter/cupertino.dart';

typedef WidgetBuilder = InlineSpan Function(String value);

/// 范围样式，给定不同
class TextSpanBuilder extends Comparable<TextSpanBuilder> {
  /// 范围
  final TextRange range;

  /// 组件构建器
  final WidgetBuilder builder;

  TextSpanBuilder({@required this.range, this.builder});

  @override
  int compareTo(TextSpanBuilder other) {
    return range.start.compareTo(other.range.start);
  }
}
