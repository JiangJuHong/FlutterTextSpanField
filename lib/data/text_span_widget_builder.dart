import 'package:flutter/cupertino.dart';
import 'package:text_span_field/build_callback_types.dart';

/// TextSpan 库定义的基本组件构建
class TextSpanWidgetBuilder extends Comparable<TextSpanWidgetBuilder> {
  /// 范围
  final TextRange range;

  /// 组件构建器
  final InlineSpanBuilder build;

  TextSpanWidgetBuilder({@required this.range, this.build});

  @override
  int compareTo(TextSpanWidgetBuilder other) {
    return range.start.compareTo(other.range.start);
  }
}
