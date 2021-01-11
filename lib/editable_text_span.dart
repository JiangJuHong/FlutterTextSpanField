import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:text_span_field/text_span_builder.dart';

/// 自定义文本编辑器
/// 1. 重写 buildTextSpan 方法达到样式控制
/// 2. 增加 style 属性达到动态样式控制
class EditableTextSpan extends EditableText {
  /// 构建器
  final TextSpanBuilder builder;

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
    return new TextSpan(style: widget.style, children: widget.builder.buildSpan(text));
  }
}
