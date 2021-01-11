import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:text_span_field/text_span_builder.dart';

/// 自定义文本编辑器
/// 1. 重写 buildTextSpan 方法达到样式控制
/// 2. 增加 style 属性达到动态样式控制
class EditableTextSpan extends EditableText {
  /// 自定义范围样式
  final List<TextSpanBuilder> builder;

  EditableTextSpan({
    Key key,
    this.builder,
    @required controller,
    @required focusNode,
    readOnly = false,
    obscureText = false,
    autocorrect = true,
    enableSuggestions = true,
    @required style,
    StrutStyle strutStyle,
    @required cursorColor,
    @required backgroundCursorColor,
    textAlign = TextAlign.start,
    textDirection,
    locale,
    textScaleFactor,
    maxLines = 1,
    minLines,
    expands = false,
    forceLine = true,
    textWidthBasis = TextWidthBasis.parent,
    autofocus = false,
    bool showCursor,
    showSelectionHandles = false,
    selectionColor,
    selectionControls,
    TextInputType keyboardType,
    textInputAction,
    textCapitalization = TextCapitalization.none,
    onChanged,
    onEditingComplete,
    onSubmitted,
    onSelectionChanged,
    onSelectionHandleTapped,
    List<TextInputFormatter> inputFormatters,
    rendererIgnoresPointer = false,
    cursorWidth = 2.0,
    cursorRadius,
    cursorOpacityAnimates = false,
    cursorOffset,
    paintCursorAboveText = false,
    scrollPadding = const EdgeInsets.all(20.0),
    keyboardAppearance = Brightness.light,
    dragStartBehavior = DragStartBehavior.start,
    enableInteractiveSelection = true,
    scrollController,
    scrollPhysics,
    toolbarOptions = const ToolbarOptions(
      copy: true,
      cut: true,
      paste: true,
      selectAll: true,
    ),
  }) : super(
          key: key,
          controller: controller,
          focusNode: focusNode,
          readOnly: readOnly,
          obscureText: obscureText,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          style: style,
          strutStyle: strutStyle,
          cursorColor: cursorColor,
          backgroundCursorColor: backgroundCursorColor,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          minLines: minLines,
          expands: expands,
          forceLine: forceLine,
          textWidthBasis: textWidthBasis,
          autofocus: autofocus,
          showCursor: showCursor,
          showSelectionHandles: showSelectionHandles,
          selectionColor: selectionColor,
          selectionControls: selectionControls,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          onSubmitted: onSubmitted,
          onSelectionChanged: onSelectionChanged,
          onSelectionHandleTapped: onSelectionHandleTapped,
          inputFormatters: inputFormatters,
          rendererIgnoresPointer: rendererIgnoresPointer,
          cursorWidth: cursorWidth,
          cursorRadius: cursorRadius,
          cursorOpacityAnimates: cursorOpacityAnimates,
          cursorOffset: cursorOffset,
          paintCursorAboveText: paintCursorAboveText,
          scrollPadding: scrollPadding,
          keyboardAppearance: keyboardAppearance,
          dragStartBehavior: dragStartBehavior,
          enableInteractiveSelection: enableInteractiveSelection,
          scrollController: scrollController,
          scrollPhysics: scrollPhysics,
          toolbarOptions: toolbarOptions,
        );

  @override
  createState() => _EditableTextSpan();
}

class _EditableTextSpan extends EditableTextState {
  @override
  EditableTextSpan get widget => super.widget;

  @override
  TextSpan buildTextSpan() {
    final String text = textEditingValue.text;
    if (widget.builder != null) {
      var children = <InlineSpan>[];
      for (var item in this.getRanges()) {
        // 在范围内才进行添加
        if (item.range.end <= text.length) {
          String currentText = item.range.textInside(text);
          InlineSpan span = TextSpan(text: currentText);
          if (item.builder != null) {
            span = item.builder(currentText);
          }
          children.add(span);
        }
      }

      return new TextSpan(style: widget.style, children: children);
    }
    return new TextSpan(style: widget.style, text: text);
  }

  /// 根据范围获得样式
  List<TextSpanBuilder> getRanges() {
    var source = widget.builder;
    source.sort();
    var result = new List<TextSpanBuilder>();
    TextSpanBuilder prev;
    for (var item in source) {
      if (prev == null) {
        // First item, check if we need one before it.
        if (item.range.start > 0) {
          result.add(TextSpanBuilder(
            range: TextRange(start: 0, end: item.range.start),
          ));
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
          result.add(TextSpanBuilder(
            range: TextRange(start: prev.range.end, end: item.range.start),
          ));
        }
        // Also add current annotation
        result.add(item);
        prev = item;
      }
    }
    // Also check for trailing range
    final String text = textEditingValue.text;
    if (result.last.range.end < text.length) {
      result.add(TextSpanBuilder(
        range: TextRange(start: result.last.range.end, end: text.length),
      ));
    }
    return result;
  }
}
