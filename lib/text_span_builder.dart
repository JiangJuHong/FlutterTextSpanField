import 'package:flutter/material.dart';
import 'package:text_span_field/build_callback_types.dart';
import 'package:text_span_field/data/text_span_widget_builder.dart';
import 'package:text_span_field/editable_text_span.dart';

import 'data/text_span_widget.dart';

/// 构建器
class TextSpanBuilder {
  /// Widget构建属性列表
  TextSpanWidgetGroupBuilder _widgetBuild;

  /// 文本域控制器
  TextEditingController _textEditingController;

  /// 文本编辑器
  EditableTextSpan _editableTextSpan;

  /// 当前组件列表
  List<TextSpanWidget> _currentWidgets = [];

  /// 绑定数据值组件
  void bind({
    TextSpanWidgetGroupBuilder widgetBuild,
    TextEditingController textEditingController,
    EditableTextSpan editableTextSpan,
  }) {
    _widgetBuild = widgetBuild;
    this._editableTextSpan = editableTextSpan;
    this._textEditingController = textEditingController;
  }

  /// 根据文本创建组件构建列表，此操作会对用户传入进来Widget构建列表二次变更
  /// [text] 当前的文本内容
  List<TextSpanWidgetBuilder> _createTextSpanWidgetList(String text) {
    var source = this._widgetBuild(text) ?? <TextSpanWidgetBuilder>[];

    if (source.length == 0) {
      return <TextSpanWidgetBuilder>[];
    }

    source.sort();
    var result = new List<TextSpanWidgetBuilder>();
    TextSpanWidgetBuilder prev;
    for (var item in source) {
      if (prev == null) {
        // First item, check if we need one before it.
        if (item.range.start > 0) {
          result.add(TextSpanWidgetBuilder(range: TextRange(start: 0, end: item.range.start)));
        }
        result.add(item);
        prev = item;
        continue;
      } else {
        // Consequent item, check if there is a gap between.
        if (prev.range.end > item.range.start) {
          // Invalid ranges
          throw new StateError('Invalid (intersecting) ranges for annotated field');
        } else if (prev.range.end < item.range.start) {
          result.add(TextSpanWidgetBuilder(range: TextRange(start: prev.range.end, end: item.range.start)));
        }
        // Also add current annotation
        result.add(item);
        prev = item;
      }
    }

    // Also check for trailing range
    if (result.last.range.end < text.length) {
      result.add(TextSpanWidgetBuilder(range: TextRange(start: result.last.range.end, end: text.length)));
    }
    return result;
  }

  /// 根据文本构建TextSpanWidget组件
  /// [text] 文本内容
  List<TextSpanWidget> _buildTextSpanWidget(String text) {
    List<TextSpanWidgetBuilder> builder = this._createTextSpanWidgetList(text);
    if (builder.length == 0) {
      return [TextSpanWidget(range: TextRange(start: 0, end: text.length), span: TextSpan(text: text))];
    }

    List<TextSpanWidget> result = [];
    for (var item in builder) {
      // 在范围内才进行添加
      if (item.range.end <= text.length) {
        String currentText = item.range.textInside(text);
        InlineSpan span = TextSpan(text: currentText);
        if (item.build != null) {
          span = item.build(currentText);
        }
        result.add(TextSpanWidget(range: item.range, span: span));
      }
    }
    return result;
  }

  /// 根据文本构建 InlineSpan 内容
  List<InlineSpan> buildSpan(String text) {
    this._currentWidgets = this._buildTextSpanWidget(text);
    return this._currentWidgets.map((item) => item.span).toList();
  }

  /// 获得组件列表
  List<TextSpanWidget> getWidgets() => this._currentWidgets;
}
