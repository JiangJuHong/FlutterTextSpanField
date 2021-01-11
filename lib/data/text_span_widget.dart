import 'package:flutter/cupertino.dart';

/// TextSpan 库定义的基本组件
class TextSpanWidget extends Comparable<TextSpanWidget> {
  /// 范围
  final TextRange range;

  /// 组件构建器
  final InlineSpan span;

  TextSpanWidget({@required this.range, this.span});

  @override
  int compareTo(TextSpanWidget other) {
    return range.start.compareTo(other.range.start);
  }
}
