import 'package:flutter/material.dart';

import 'data/text_span_widget.dart';

/// 构建器
class TextSpanBuilder {
  /// 文本域控制器
  TextEditingController _textEditingController;

  /// 当前组件列表
  List<TextSpanWidget> _currentWidgets = [];

  /// 自定义组件列表
  List<TextSpanWidget> _customWidgets = [];

  /// 最后一次操作的文本
  String _lastText = "";

  /// 最后一次操作的光标
  TextSelection _lastTextSelection =
      TextSelection(baseOffset: 0, extentOffset: 0);

  /// 删除锁
  bool _deleteLock = false;

  /// 绑定数据值组件
  void bind({
    TextEditingController textEditingController,
  }) {
    if (this._textEditingController != null)
      this._textEditingController.removeListener(this._textControllerListener);
    this._textEditingController = textEditingController;
    if (this._textEditingController != null)
      this._textEditingController.addListener(this._textControllerListener);
  }

  /// 控制器监听器
  _textControllerListener() {
    String text = this._textEditingController.text;

    // 正在执行删除时，不允许进行操作
    if (_deleteLock) return;

    // 删除控制
    if (this._lastText.length > text.length) {
      _deleteLock = true;
      this._deleteLimit();
      _deleteLock = false;
    }

    // 添加控制
    if (this._lastText.length < text.length) {
      this._addLimit();
    }

    // 更新上一次的文本和位置，此处必须重新取值，因为 _deleteLimit 等操作中可能会对值进行改变
    this._lastText = this._textEditingController.text;
    this._lastTextSelection = this._textEditingController.selection;

    // 光标位置限制
    this._cursorPositionLimit(this._currentWidgets);
  }

  /// 根据文本构建TextSpanWidget组件
  /// [text] 文本内容
  List<TextSpanWidget> _buildTextSpanWidget(String text) {
    // 没有节点就创建普通文本节点
    if (this._customWidgets.length == 0)
      return [
        TextSpanWidget(
            range: TextRange(start: 0, end: text.length),
            span: TextSpan(text: text))
      ];

    // 初始化节点
    List<TextSpanWidget> source = this._customWidgets;
    List<TextSpanWidget> result = [];

    // 节点排序，方便序列化
    source.sort();

    // 循环节点
    TextRange prevItemRange = TextRange(start: 0, end: 0);
    for (var item in source) {
      TextRange itemRange = item.range;

      // 如果前一个节点和当前节点有间隙，则创建普通组件
      if (itemRange.start != prevItemRange.end) {
        TextRange targetRange =
            TextRange(start: prevItemRange.end, end: itemRange.start);
        result.add(TextSpanWidget(
            range: targetRange,
            span: TextSpan(text: targetRange.textInside(text))));
      }

      // 当前节点在文本范围内才进行添加
      result.add(item);

      prevItemRange = item.range;
    }

    // 如果最后一个节点和末尾有间隙，则进行增加
    if (prevItemRange.end != text.length) {
      TextRange targetRange =
          TextRange(start: prevItemRange.end, end: text.length);
      result.add(TextSpanWidget(
          range: targetRange,
          span: TextSpan(text: targetRange.textInside(text))));
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
      if (item.block == null || !item.block) {
        continue;
      }

      // 组件只有一个字符时不进行限制
      if (item.span.text.length <= 1) {
        continue;
      }

      // 获得新的选择器位置
      int start = this._calculationCursorPosition(
          item.range, selection.baseOffset, text.length);
      int end = this._calculationCursorPosition(
          item.range, selection.extentOffset, text.length);

      // 如果位置发生改变，则进行应用
      if (start != selection.baseOffset || end != selection.extentOffset) {
        this._textEditingController.selection =
            TextSelection(baseOffset: start, extentOffset: end);
        break;
      }
    }
  }

  /// 删除限制,如果组件是成块删除，则会自动删除整块内容
  void _deleteLimit() {
    // 获得删除的内容的范围
    TextRange deleteRange;
    TextSelection selection = this._textEditingController.selection;
    if (_lastTextSelection.baseOffset != _lastTextSelection.extentOffset) {
      deleteRange = TextRange(
          start: _lastTextSelection.baseOffset,
          end: _lastTextSelection.extentOffset);
    } else {
      deleteRange = TextRange(
          start: selection.baseOffset,
          end: this._lastText.length == selection.baseOffset
              ? selection.baseOffset
              : selection.baseOffset + 1);
    }

    // 组件处理
    // 如果组件在删除范围内，且是块组件，则一并删除
    // 如果组件在受影响范围内，但是不是块组件，则更新组件的范围
    List<int> removeIndex = [];
    for (var i = 0; i < this._customWidgets.length; i++) {
      TextSpanWidget item = this._customWidgets[i];

      // 检测是否在删除范围内
      bool deleted = item.range.start == deleteRange.start &&
          item.range.end == deleteRange.end;
      if (!deleted) {
        for (var index = deleteRange.start; index <= deleteRange.end; index++) {
          if (index > item.range.start && index < item.range.end) {
            deleted = true;
          }
        }
      }

      // 删除组件后更新删除范围
      if (deleted) {
        removeIndex.add(i);
        deleteRange = TextRange(
            start: item.range.start < deleteRange.start
                ? item.range.start
                : deleteRange.start,
            end: item.range.end > deleteRange.end
                ? item.range.end
                : deleteRange.end);
        continue;
      }

      // 如果组件没有在删除范围内，则判断是否需要更新位置
      // 如果删除的开始在组件末尾以后，则不需要更新
      if (deleteRange.start >= item.range.end) {
        continue;
      }

      // 更新位置
      item.range =
          _updateRange(item.range, -(deleteRange.end - deleteRange.start));
      this._customWidgets[i] = item;
    }

    // 删除下标内容
    removeIndex.forEach((index) => this._customWidgets.removeAt(index));

    // 获得最新的文本和光标
    String newText =
        this._lastText.replaceRange(deleteRange.start, deleteRange.end, "");
    TextSelection newTextSelection = TextSelection(
        baseOffset: deleteRange.start, extentOffset: deleteRange.start);

    // 更新文本和光标
    this._textEditingController.value = this
        ._textEditingController
        .value
        .copyWith(
            text: newText,
            selection: newTextSelection,
            composing: TextRange.empty);
  }

  /// 添加限制，添加内容时，应该同步更新组件的范围
  void _addLimit() {
    // 获得添加的内容长度
    int length =
        this._textEditingController.text.length - this._lastText.length;

    // 获得添加的内容的范围
    TextSelection selection = this._textEditingController.selection;
    TextRange appendRange = TextRange(
        start: selection.extentOffset - length, end: selection.extentOffset);

    // -1代表光标没在文本框，则默认为是在末尾追加的内容，不进行处理
    if (appendRange.start == -1 && appendRange.end == -1) {
      return;
    }

    // 由于同时添加相同数量的内容，会导致
    for (var i = 0; i < this._customWidgets.length; i++) {
      TextSpanWidget item = this._customWidgets[i];
      // 如果是在组件前面追加，则更新
      if (appendRange.end <=
          item.range.start + (appendRange.end - appendRange.start)) {
        item.range =
            _updateRange(item.range, appendRange.end - appendRange.start);
        this._customWidgets[i] = item;
      }
    }
  }

  /// 更新范围
  /// [source] 原始数据
  /// [offset] 偏移量
  TextRange _updateRange(TextRange source, int offset) {
    return TextRange(start: source.start + offset, end: source.end + offset);
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

  /// 追加组件到末尾
  void appendToEnd(TextSpan span) {
    this.append(span, this._textEditingController.text.length);
  }

  /// 追加普通文本到末尾
  void appendTextToEnd(String text) {
    this.appendText(text, this._textEditingController.text.length);
  }

  /// 追加组件到光标处
  void appendToCursor(TextSpan span) {
    int index = this._lastTextSelection.start;
    if (index == -1) {
      this.appendToEnd(span);
    } else {
      this.append(span, index);
    }
  }

  /// 追加普通文本到光标处
  void appendTextToCursor(String text) {
    int index = this._lastTextSelection.start;
    if (index == -1) {
      this.appendTextToEnd(text);
    } else {
      this.appendText(text, index);
    }
  }

  /// 在指定下标后面添加内容
  void append(TextSpan span, int index) {
    String text = span.text ?? "";

    // 增加普通文本
    this.appendText(text, index);

    // 添加组件
    this._customWidgets.add(TextSpanWidget(
        range: TextRange(start: index, end: index + text.length),
        block: true,
        span: span));
  }

  /// 追加普通文本
  /// [text] 文本内容
  void appendText(String text, int index) {
    String oldText = this._textEditingController.text;
    String newText =
        oldText.substring(0, index) + text + oldText.substring(index);

    this._textEditingController.value =
        this._textEditingController.value.copyWith(
              text: newText,
              selection: TextSelection.collapsed(offset: index + text.length),
              composing: TextRange.empty,
            );
  }

  /// 根据文本范围对内容进行删除
  /// [start] 开始范围，可以理解为开始下标
  /// [end] 结束范围，可以理解为要删除的长度
  void delete(int start, int end) {
    // 获得旧文本
    String oldText = this._textEditingController.text;
    int startIndex = start > oldText.length ? oldText.length : start;
    int endIndex = end > oldText.length ? oldText.length : end;

    // 选中删除的内容
    this._textEditingController.selection =
        TextSelection(baseOffset: startIndex, extentOffset: endIndex);

    // 更新内容
    String newText =
        oldText.substring(0, startIndex) + oldText.substring(endIndex);
    this._textEditingController.value =
        this._textEditingController.value.copyWith(
              text: newText,
              selection: TextSelection.collapsed(offset: startIndex),
              composing: TextRange.empty,
            );
  }

  /// 清空文本
  void clear() {
    String oldText = this._textEditingController.text;
    if (oldText.length == 0) {
      return;
    }
    this.delete(0, oldText.length);
  }

  /// [公开方法] 获得组件列表
  List<TextSpanWidget> getWidgets() => this._customWidgets;

  /// [公开方法] 获得Controller
  TextEditingController get controller => _textEditingController;
}
