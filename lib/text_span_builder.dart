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

  /// 最后一次操作的问题
  String _lastText = "";

  /// 绑定数据值组件
  void bind({
    TextSpanWidgetGroupBuilder widgetBuild,
    TextEditingController textEditingController,
    EditableTextSpan editableTextSpan,
  }) {
    if (this._textEditingController != null) this._textEditingController.removeListener(this._textControllerListener);
    this._widgetBuild = widgetBuild;
    this._editableTextSpan = editableTextSpan;
    this._textEditingController = textEditingController;
    this._textEditingController.addListener(this._textControllerListener);
  }

  /// 控制器监听器
  _textControllerListener() {
    String text = this._textEditingController.text;

    // 删除限制
    if (this._lastText.length - text.length == 1) {
      this._deleteLimit(this._currentWidgets);
    }
    this._lastText = text;

    // 光标位置限制
    this._cursorPositionLimit(this._currentWidgets);
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
        result.add(TextSpanWidget(range: item.range, block: item.block, span: span));
      }
    }
    return result;
  }

  /// 光标位置限制，根据当前组件列表和光标位置，对光标进行限制操作
  /// 如果组件不允许点击，则会自动跳到前面或后面
  void _cursorPositionLimit(List<TextSpanWidget> widget) {
    TextSelection selection = this._textEditingController.selection;
    String text = this._textEditingController.text;
    for (var item in widget) {
      // 非块组件不进行限制
      if (item.block != null && !item.block) {
        continue;
      }

      // 获得新的选择器位置
      int start = this._calculationCursorPosition(item.range, selection.baseOffset, text.length);
      int end = this._calculationCursorPosition(item.range, selection.extentOffset, text.length);

      // 如果位置发生改变，则进行应用
      if (start != selection.baseOffset || end != selection.extentOffset) {
        this._textEditingController.selection = TextSelection(baseOffset: start, extentOffset: end);
        break;
      }
    }
  }

  /// 删除限制,如果组件是成块删除，则会自动删除整块内容
  void _deleteLimit(List<TextSpanWidget> widget) {
    TextSelection selection = this._textEditingController.selection;
    for (var item in widget) {
      // 非块组件不进行限制
      if (item.block != null && !item.block) {
        continue;
      }

      // 如果光标在块末尾位置，则代表删除的是当前块。然后移除块的内容
      // 之所以需要 -1，是因为已经删除了一个字符，所以需要前移一位
      if (item.range.end - 1 == selection.baseOffset) {
        String newText = this._lastText.substring(item.range.end);
        if (item.range.start != 0) {
          newText = this._lastText.substring(0, item.range.start) + newText;
        }
        this._textEditingController.text = newText;

        // 重置光标到开始的位置
        this._textEditingController.selection = TextSelection(baseOffset: item.range.start, extentOffset: item.range.start);
      }
    }
  }

  /// 计算光标位置
  /// [range] 范围域
  /// [position] 当前位置
  /// [max] 最大值
  int _calculationCursorPosition(TextRange range, int position, int max) {
    if (position >= range.start && position <= range.end) {
      int median = range.start + (range.end - range.start) ~/ 2;
      if (position < median) {
        return range.start < 0 ? 0 : range.start;
      }
      return range.end > max ? max : range.end;
    }
    return position;
  }

  /// [公开方法] 根据文本构建 InlineSpan 内容
  List<InlineSpan> buildSpan(String text) {
    // 重置当前组件
    this._currentWidgets = this._buildTextSpanWidget(text);

    // 返回绘制内容
    return this._currentWidgets.map((item) => item.span).toList();
  }

  /// [公开方法] 获得组件列表
  List<TextSpanWidget> getWidgets() => this._currentWidgets;
}
