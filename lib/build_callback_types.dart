import 'package:flutter/cupertino.dart';

import 'data/text_span_widget_builder.dart';

/// InlineSpanBuilder，根据文本内容构建 InlineSpan
typedef InlineSpanBuilder = InlineSpan Function(String value);

/// InlineSpanBuilder，根据文本内容构建 TextSpanWidgetBuilder 集合
typedef TextSpanWidgetGroupBuilder = List<TextSpanWidgetBuilder> Function(String value);
