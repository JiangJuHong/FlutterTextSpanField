# text_span_field
[![pub package](https://img.shields.io/pub/v/text_span_field.svg)](https://pub.dartlang.org/packages/text_span_field)

Flutter自定义文本样式输入框，可以让你在TextField中显示不同样式的文本，例如 #话题# @用户 效果

## Getting Started
实现思路已在博客园发表，[点击进入](https://www.cnblogs.com/adversary/p/12580658.html)


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


## 其它插件
````
我同时维护的还有如下插件，如果您感兴趣与我一起进行维护，请通过Github联系我，欢迎 issues 和 PR。
````
| 平台 | 插件  |  描述  |  版本  | - |
| ---- | ----  | ---- |  ---- | ---- |
| Flutter | [FlutterTencentImPlugin](https://github.com/JiangJuHong/FlutterTencentImPlugin)  | 腾讯云IM插件 | [![pub package](https://img.shields.io/pub/v/tencent_im_plugin.svg)](https://pub.dartlang.org/packages/tencent_im_plugin) | ![](https://img.shields.io/github/stars/JiangJuHong/FlutterTencentImPlugin?style=social) |
| Flutter | [FlutterTencentRtcPlugin](https://github.com/JiangJuHong/FlutterTencentRtcPlugin)  | 腾讯云Rtc插件 | [![pub package](https://img.shields.io/pub/v/tencent_rtc_plugin.svg)](https://pub.dartlang.org/packages/tencent_rtc_plugin) | ![](https://img.shields.io/github/stars/JiangJuHong/FlutterTencentRtcPlugin?style=social) |
| Flutter | [FlutterXiaoMiPushPlugin](https://github.com/JiangJuHong/FlutterXiaoMiPushPlugin)  | 小米推送SDK插件 | [![pub package](https://img.shields.io/pub/v/xiao_mi_push_plugin.svg)](https://pub.dartlang.org/packages/xiao_mi_push_plugin) | ![](https://img.shields.io/github/stars/JiangJuHong/FlutterXiaoMiPushPlugin?style=social) |
| Flutter | [FlutterTextSpanField](https://github.com/JiangJuHong/FlutterTextSpanField)  | 自定义文本样式输入框 | [![pub package](https://img.shields.io/pub/v/text_span_field.svg)](https://pub.dartlang.org/packages/text_span_field) | ![](https://img.shields.io/github/stars/JiangJuHong/FlutterTextSpanField?style=social) |
| Flutter | [FlutterQiniucloudLivePlugin](https://github.com/JiangJuHong/FlutterQiniucloudLivePlugin)  | Flutter 七牛云直播云插件 | 暂未发布，通过 git 集成 | ![](https://img.shields.io/github/stars/JiangJuHong/FlutterQiniucloudLivePlugin?style=social) |
