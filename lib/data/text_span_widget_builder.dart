import 'package:flutter/cupertino.dart';
import 'package:text_span_field/build_callback_types.dart';

/// TextSpan 库定义的基本组件构建
/// 此组件使用限制：
///   每一个 range 范围，只能有一个组件，
class TextSpanWidgetBuilder extends Comparable<TextSpanWidgetBuilder> {
  /// 范围
  final TextRange range;

  /// 是否以块的形式展示，当 black 为true时，范围内的内容将不能被光标定位，且删除内容时会将一整块的内容均删除
  final bool block;

  /// 组件构建器
  final InlineSpanBuilder build;

  TextSpanWidgetBuilder({@required this.range, this.block: false, this.build});

  @override
  int compareTo(TextSpanWidgetBuilder other) {
    return range.start.compareTo(other.range.start);
  }
}
