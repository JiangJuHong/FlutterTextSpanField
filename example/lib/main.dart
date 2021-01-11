import 'package:flutter/material.dart';
import 'package:text_span_field/text_span_field.dart';
import 'package:text_span_field/data/text_span_widget_builder.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 话题正则
  RegExp topicReg = new RegExp(r"#([^#]{1,})#");

  /// 用户提醒(@开头,以空格、冒号、斜杠/ 结束，不以@结束)
  RegExp accountRemindReg = new RegExp(r"@([^\s|\/|:|@]+)");

  @override
  void initState() {
    super.initState();
  }

  TextSpan _atBuilder(String text) => TextSpan(text: text, style: TextStyle(color: Color(0xFF5BA2FF)));

  TextSpan _topicBuilder(String text) => TextSpan(text: text, style: TextStyle(color: Color(0xFF9C7BFF)));

  /// 获得文本输入框样式
  List<TextSpanWidgetBuilder> widgetBuild(String text) {
    List<TextSpanWidgetBuilder> result = [];

    // 匹配话题
    for (Match m in topicReg.allMatches(text)) {
      result.add(
        TextSpanWidgetBuilder(
          range: TextRange(start: m.start, end: m.end),
          block: true,
          build: _topicBuilder,
        ),
      );
    }

    // 匹配@
    for (Match m in accountRemindReg.allMatches(text)) {
      result.add(
        TextSpanWidgetBuilder(
          range: TextRange(start: m.start, end: m.end),
          build: _atBuilder,
        ),
      );
    }
    return result.length == 0 ? null : result;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: TextSpanField(
            maxLines: null,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(20),
              hintText: '分享你的点滴，记录这一刻...',
            ),
            widgetBuild: this.widgetBuild,
          ),
        ),
      ),
    );
  }
}
