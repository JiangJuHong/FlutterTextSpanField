# text_span_field
[![pub package](https://img.shields.io/pub/v/text_span_field.svg)](https://pub.dartlang.org/packages/text_span_field)

Flutter自定义文本样式输入框，可以让你在TextField中显示不同样式的文本，例如 #话题# @用户 效果

## Getting Started

### Flutter
```
text_span_field: 1.0.0
```

### Android 端集成
无需额外配置，已内部打入混淆配置

### IOS
无需额外配置

## 效果图
<img src="https://raw.githubusercontent.com/JiangJuHong/access-images/master/FlutterTextSpanField/iShot2020-03-2711.59.23.png" height="300em" style="max-width:100%;display: inline-block;"/>

## 使用
```dart
TextSpanField(
            controller: TextEditingController(
              text: "这是一条测试信息,你们看他的颜色",
            ),
            rangeStyles: [
              RangeStyle(
                range: TextRange(start: 0, end: 1),
                style: TextStyle(color: Color(0xFF5BA2FF)),
              ),
              RangeStyle(
                range: TextRange(start: 3, end: 4),
                style: TextStyle(color: Color(0xFF9C7BFF)),
              ),
            ],
          ),
```