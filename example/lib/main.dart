import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:text_span_field/text_span_field.dart';
import 'package:text_span_field/data/text_span_widget.dart';
import 'package:text_span_field/text_span_builder.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 构建器
  TextSpanBuilder _textSpanBuilder = TextSpanBuilder();

  /// @的用户名
  String _name = "张三";

  /// @的ID
  String _id = "100001";

  /// 删除开始的下标
  int _startIndex = 0;

  /// 删除结束下标
  int _endIndex = 1;

  /// 显示的值内容
  String _valueContent = "";

  @override
  void initState() {
    super.initState();
  }

  /// @用户按钮点击事件
  _atUser() async {
    _textSpanBuilder.appendToCursor(AtTextSpan(
        id: _id, text: "@$_name", style: TextStyle(color: Color(0xFF5BA2FF))));
  }

  /// 删除按钮点击事件
  _delete() {
    _textSpanBuilder.delete(_startIndex, _endIndex);
  }

  /// 获取值按钮点击事件
  _getValue() {
    List<TextSpanWidget> widget = this._textSpanBuilder.getWidgets();
    _valueContent = "";
    widget.forEach((element) {
      if (!(element.span is AtTextSpan)) {
        return;
      }

      AtTextSpan at = element.span;

      _valueContent += "名称:${at.text} \t\t ID:${at.id}\n";
    });
    this.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                TextSpanField(
                  maxLines: null,
                  textSpanBuilder: _textSpanBuilder,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(20),
                    hintText: '分享你的点滴，记录这一刻...',
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: _name),
                        decoration: InputDecoration(hintText: '请输入要@的昵称'),
                        onChanged: (text) => this._name = text,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: _id),
                        decoration: InputDecoration(hintText: '请输入要@的ID'),
                        onChanged: (text) => this._id = text,
                      ),
                    ),
                    Expanded(
                      child: RaisedButton(
                          onPressed: () => this._atUser(), child: Text("@用户")),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: "$_startIndex"),
                        decoration: InputDecoration(hintText: '删除的开始'),
                        onChanged: (text) => this._startIndex = int.parse(text),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: "$_endIndex"),
                        decoration: InputDecoration(hintText: '删除的结束下标'),
                        onChanged: (text) => this._endIndex = int.parse(text),
                      ),
                    ),
                    Expanded(
                      child: RaisedButton(
                          onPressed: () => this._delete(), child: Text("删除下标")),
                    ),
                  ],
                ),
                RaisedButton(onPressed: this._getValue, child: Text("获取值")),
                Container(height: 10),
                Text(_valueContent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// At功能的TextSpan
class AtTextSpan extends TextSpan {
  /// 被@用户的ID
  final String id;

  const AtTextSpan({
    @required this.id,
    String text,
    List<InlineSpan> children,
    TextStyle style,
    GestureRecognizer recognizer,
    String semanticsLabel,
  }) : super(
            text: text,
            children: children,
            style: style,
            recognizer: recognizer,
            semanticsLabel: semanticsLabel);
}
