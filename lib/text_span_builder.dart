import 'package:flutter/material.dart';
import 'package:text_span_field/xlog.dart';

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
  String _lastText;

  /// 最后一次操作的光标
  TextSelection _lastTextSelection;

  /// 绑定数据值组件
  void bind({
    TextEditingController textEditingController,
  }) {
    if (this._textEditingController != null)
      this._textEditingController.removeListener(this._textControllerListener);
    this._textEditingController = textEditingController;
    this._lastTextSelection = textEditingController.selection;
    this._lastText = textEditingController.text;
    if (this._textEditingController != null)
      this._textEditingController.addListener(this._textControllerListener);
  }

  /// 控制器监听器
  _textControllerListener() {
    String text = this._textEditingController.text;
    String oldText = this._lastText;
    TextSelection selection = this._textEditingController.selection;
    TextSelection oldSelection = this._lastTextSelection;

    // 文本变化
    if (text != oldText) {
      this._lastText = text;
      this._textChangeListener(oldText, text, oldSelection, selection);
    }

    // 文本变化可能会修改 _lastTextSelection 和 _textEditingController.selection
    // 需重新赋值
    oldSelection = this._lastTextSelection;
    selection = this._textEditingController.selection;

    // 光标变化
    if (oldSelection.start != selection.start ||
        oldSelection.end != selection.end) {
      this._lastTextSelection = selection;
      this._selectionChangeListener(oldText, text, oldSelection, selection);
    }
  }

  /// 文本改变监听器
  /// [oldText] 旧文本
  /// [newText] 新文本
  /// [oldSelection] 旧的文本光标
  /// [newSelection] 新的文本光标
  _textChangeListener(String oldText, String newText,
      TextSelection oldSelection, TextSelection newSelection) {
    // print(oldText + " -- " + newText);

    // 如果是选中粘贴
    if (oldSelection.start != oldSelection.end) {
      this._pasteLimit(oldText, newText, oldSelection, newSelection);
      return;
    }

    // 如果是删除
    if (oldText.length > newText.length) {
      this._deleteLimit(oldText, newText, oldSelection, newSelection);
      return;
    }

    // 如果是添加，则更新组件
    if (oldText.length < newText.length) {
      this._addLimit(oldText, newText, oldSelection, newSelection);
      return;
    }
  }

  /// 光标改变监听器
  /// [oldSelection] 旧光标
  /// [newSelection] 新光标
  _selectionChangeListener(String oldText, String newText,
      TextSelection oldSelection, TextSelection newSelection) {
    this._cursorPositionLimit(oldText, newText, oldSelection, newSelection);
  }

  /// 替换限制，如果选中一段并粘贴，则会自动删除选中区域里的整块内容
  /// [oldText] 旧文本
  /// [newText] 新文本
  /// [oldSelection] 旧的文本光标
  /// [newSelection] 新的文本光标
  void _pasteLimit(String oldText, String newText, TextSelection oldSelection,
      TextSelection newSelection) {
    // 组件处理，如果组件在删除范围内，则把整块内容进行删除。
    // 如果组件不在删除范围内，但是在受影响范围内，则更新组件最新下标。
    List<int> removeIndex = [];
    for (var i = 0; i < this._customWidgets.length; i++) {
      TextSpanWidget item = this._customWidgets[i];
      TextRange range = item.range;

      // 检测是否在删除范围内
      if (range.start >= oldSelection.start && range.end <= oldSelection.end) {
        removeIndex.add(i);
      } else if (range.start >= oldSelection.end) {
        // 删除范围之后的需更新整块内容的位置
        item.range = _updateRange(item.range, newText.length - oldText.length);
      }
    }

    // 删除下标内容
    removeIndex.reversed
        .forEach((index) => this._customWidgets.removeAt(index));
  }

  /// 删除限制,如果组件是成块删除，则会自动删除整块内容
  /// [oldText] 旧文本
  /// [newText] 新文本
  /// [oldSelection] 旧的文本光标
  /// [newSelection] 新的文本光标
  void _deleteLimit(String oldText, String newText, TextSelection oldSelection,
      TextSelection newSelection) {
    if (this._customWidgets.length == 0) return;

    // 获得删除范围
    TextRange deleteRange;
    if (oldSelection.baseOffset != oldSelection.extentOffset) {
      deleteRange = TextRange(
          start: oldSelection.baseOffset, end: oldSelection.extentOffset);
    } else {
      deleteRange = TextRange(
          start: newSelection.baseOffset,
          end: oldText.length == newSelection.baseOffset
              ? newSelection.baseOffset
              : newSelection.baseOffset + oldText.length - newText.length);
    }
    XLog.log('range--$deleteRange');

    // 组件处理，如果组件在删除范围内，则把整块内容进行删除。如果组件不在删除范围内，但是在受影响范围内，则更新组件最新下标。
    List<int> removeIndex = [];
    bool changed = false;
    for (var i = 0; i < this._customWidgets.length; i++) {
      TextSpanWidget item = this._customWidgets[i];

      // 检测是否在删除范围内
      bool deleted = item.range == deleteRange;
      if (!deleted) {
        for (var index = deleteRange.start; index <= deleteRange.end; index++) {
          if (index > item.range.start && index < item.range.end) {
            deleted = true;
            changed = true;
          }
        }
      }

      // 更新删除范围
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
      if (deleteRange.end <= item.range.start + (deleteRange.end - deleteRange.start) &&
              (deleteRange.start > 0 && oldText.substring(deleteRange.start - 1, deleteRange.start) !=
                  newText.substring(deleteRange.start - 1, deleteRange.start)) ||
          (oldText.length - newText.length > 1 && !deleted)) {
        item.range = _updateRange(item.range, -(oldText.length - newText.length));
      } else {
        item.range = _updateRange(item.range, -(deleteRange.end - deleteRange.start));
      }

      this._customWidgets[i] = item;
      changed = true;
    }

    // 删除下标内容
    removeIndex.reversed
        .forEach((index) => this._customWidgets.removeAt(index));

    String finalText;
    TextSelection finalTextSelection;
    // 获得最终的的文本和光标
    if (oldText.substring(deleteRange.start - 1, deleteRange.start) !=
        newText.substring(deleteRange.start - 1, deleteRange.start) || (oldText.length - newText.length > 1 && removeIndex.isEmpty) ) {
      XLog.log('deleteStart--${deleteRange.start}');
      XLog.log('extent--${deleteRange.end}');
      finalText = newText;
      finalTextSelection = TextSelection(baseOffset: deleteRange.start, extentOffset: deleteRange.start);
    } else {
      finalText = this._lastText =
          oldText.replaceRange(deleteRange.start, deleteRange.end, "");
      finalTextSelection = this._lastTextSelection = TextSelection(
          baseOffset: deleteRange.start, extentOffset: deleteRange.start);
    }

    // 内容相同则不进行更新
    if (!changed || finalText == newText) {
      return;
    }

    // 更新文本和光标
    this._textEditingController.value = TextEditingValue(
      text: finalText,
      selection: finalTextSelection,
    );
  }

  /// 添加限制，添加内容时，应该同步更新组件的范围
  /// [oldText] 旧文本
  /// [newText] 新文本
  /// [oldSelection] 旧的文本光标
  /// [newSelection] 新的文本光标
  void _addLimit(String oldText, String newText, TextSelection oldSelection,
      TextSelection newSelection) {
    if (this._customWidgets.length == 0) return;

    // 获得添加的内容长度
    XLog.log('添加的内容长度: $oldText -- $newText');
    int length = newText.length - oldText.length;

    // 获得添加的内容的范围
    TextRange appendRange = TextRange(
        start: newSelection.extentOffset - length,
        end: newSelection.extentOffset);

    XLog.log('range: $appendRange');
    // -1代表光标没在文本框，则默认为是在末尾追加 的内容，不进行处理
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

  /// 光标位置限制，根据当前组件列表和光标位置，对光标进行限制操作
  /// 如果组件不允许点击，则会自动跳到前面或后面
  /// [oldText] 旧文本
  /// [newText] 新文本
  /// [oldSelection] 旧的文本光标
  /// [newSelection] 新的文本光标
  void _cursorPositionLimit(String oldText, String newText,
      TextSelection oldSelection, TextSelection newSelection) {
    for (var item in this._customWidgets) {
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
          item.range, newSelection.baseOffset, newText.length);
      int end = this._calculationCursorPosition(
          item.range, newSelection.extentOffset, newText.length);

      // 如果位置发生改变，则进行应用
      if (start != newSelection.baseOffset ||
          end != newSelection.extentOffset) {
        this._textEditingController.selection =
            TextSelection(baseOffset: start, extentOffset: end);
        break;
      }
    }
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
    this._currentWidgets =
        this._buildTextSpanWidget(this._textEditingController.text);

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
    this._customWidgets.clear();
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
