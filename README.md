

<div align="center">

[![All Contributors](https://img.shields.io/badge/all_contributors-3-orange.svg?style=flat-square)](#contributors-)
[![](https://img.shields.io/pub/v/text_span_field.svg)](https://pub.dartlang.org/packages/text_span_field)
[![](https://img.shields.io/github/license/JiangJuHong/FlutterTencentImPlugin)](https://www.apache.org/licenses/LICENSE-2.0)
[![](https://img.shields.io/badge/qq群-850923396-1)](https://jq.qq.com/?_wv=1027&k=QxCWMlUf)

</div>

# 什么是 TextSpanField ？

Flutter自定义块样式输入框，实现在输入框中自定义加入任意 TextSpan，并可获得加入的
TextSpan对象。  
通过此组件可以快速实现@功能值绑定，隐藏域值绑定！  
如果您觉得这个插件帮助了您，可以请我[喝一杯咖啡](https://www.yuque.com/jiangjuhong/default/aso8g5)

# 使用场景

* @功能 (用户绑定ID，即使重名也能精确的知道@的是哪个用户)
* 隐藏域场景
  (@一个用户，我们需要的实际是这个用户的ID，而不是用户名，通过此组件可以快速方便的实现)

# 使用限制

* 自定义组件仅能以"块"的形式出现，即一删除会删除整块内容，光标也无法定位到整快组件中间，可参考QQ的@功能
* 在存在自定义组件的情况下，禁止使用 controller.text
  进行赋值，如果你不得不添加或删除内容，请使用 `append` 和 `delete` 方法
* 自定义组件仅支持 `TextSpan` 及其子类，不支持 `WidgetSpan`

# 讨论群

欢迎进入QQ群讨论，[点击此处可以直接加入群聊](https://jq.qq.com/?_wv=1027&k=QxCWMlUf)

# Demo截图

<img src="https://raw.githubusercontent.com/JiangJuHong/access-images/master/FlutterTextSpanField/WechatIMG160.jpeg" height="300em" style="max-width:100%;display: inline-block;"/>

# 集成

### Flutter

```
text_span_field: 最新版本
```

### Android

无需额外配置，已内部打入混淆配置

### IOS

无需额外配置

# 使用

```dart
TextSpanField(
  maxLines: null,
  textSpanBuilder: _textSpanBuilder,
  decoration: InputDecoration(
    contentPadding: EdgeInsets.all(20),
    hintText: '分享你的点滴，记录这一刻...',
  ),
)
```

其中，textSpanBuilder 属性为 TextSpanBuilder 对象，此对象包含以下公开接口:

| 方法名              | 方法描述                            |
|:-------------------|:-----------------------------------|
| buildSpan          | 根据文本和自定义组件构建InlineSpan列表 |
| appendToEnd        | 追加自定义的 TextSpan 组件到末尾      |
| appendTextToEnd    | 追加普通文本到末尾                    |
| appendToCursor     | 追加自定义的 TextSpan 组件到光标位置   |
| appendTextToCursor | 追加普通文本光标位置                  |
| append             | 追加自定义的 TextSpan 组件到指定下标   |
| appendText         | 追加普通文本指定下标                  |
| delete             | 根据开始下标和结束下标删除文本内容      |
| clear              | 清空文本内容                         |
| getWidgets         | 获得自定义组件列表                    |

如果你要实现@功能的隐藏域，可以增加一个 AtTextSpan 类，并继承 TextSpan:

````dart
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
  }) : super(text: text, children: children, style: style, recognizer: recognizer, semanticsLabel: semanticsLabel);
}
````

然后在@的时候通过 appendToCursor 接口添加到编辑器，最后在获得值的时候调用
getWidgets 接口即可:  
添加：

````dart
 _textSpanBuilder.appendToCursor(AtTextSpan(id:"我是ID", text: "我是昵称", style: TextStyle(color: Color(0xFF5BA2FF))));
````

获取：

````dart
List<TextSpanWidget> widget = this._textSpanBuilder.getWidgets();
widget.forEach((element) {
  if (!(element.span is AtTextSpan)) {
    return;
  }
  AtTextSpan at = element.span;
  _valueContent += "名称:${at.text} \t\t ID:${at.id}\n";
});
````

# Other Plugins

````
我同时维护的还有以下插件，如果您感兴趣与我一起进行维护，请通过Github联系我，欢迎 issues 和 PR。
````

| 平台     | 插件                                                                                      | 描述                      | 版本                                                                                                                                 |
|:--------|:------------------------------------------------------------------------------------------|:-------------------------|:------------------------------------------------------------------------------------------------------------------------------------|
| Flutter | [FlutterVideoPlayerLibrary-Desc](https://github.com/JiangJuHong/FlutterVideoPlayerLibrary-Desc) | Flutter 最好用的播放器(UI库) | - |
| Flutter | [FlutterPerfectVolumeControl](https://github.com/JiangJuHong/FlutterPerfectVolumeControl) | Flutter 完美的音量控制器插件 | [![pub package](https://img.shields.io/pub/v/perfect_volume_control.svg)](https://pub.dartlang.org/packages/perfect_volume_control) |
| Flutter | [FlutterTencentImPlugin](https://github.com/JiangJuHong/FlutterTencentImPlugin)           | 腾讯云IM插件               | [![pub package](https://img.shields.io/pub/v/tencent_im_plugin.svg)](https://pub.dartlang.org/packages/tencent_im_plugin)           |
| Flutter | [FlutterTencentRtcPlugin](https://github.com/JiangJuHong/FlutterTencentRtcPlugin)         | 腾讯云Rtc插件              | [![pub package](https://img.shields.io/pub/v/tencent_rtc_plugin.svg)](https://pub.dartlang.org/packages/tencent_rtc_plugin)         |
| Flutter | [FlutterXiaoMiPushPlugin](https://github.com/JiangJuHong/FlutterXiaoMiPushPlugin)         | 小米推送SDK插件            | [![pub package](https://img.shields.io/pub/v/xiao_mi_push_plugin.svg)](https://pub.dartlang.org/packages/xiao_mi_push_plugin)       |
| Flutter | [FlutterHuaWeiPushPlugin](https://github.com/JiangJuHong/FlutterHuaWeiPushPlugin)         | 华为推送(HMS Push)插件     | [![pub package](https://img.shields.io/pub/v/hua_wei_push_plugin.svg)](https://pub.dartlang.org/packages/hua_wei_push_plugin)       |
| Flutter | [FlutterTextSpanField](https://github.com/JiangJuHong/FlutterTextSpanField)               | 自定义文本样式输入框         | [![pub package](https://img.shields.io/pub/v/text_span_field.svg)](https://pub.dartlang.org/packages/text_span_field)               |
| Flutter | [FlutterClipboardListener](https://github.com/JiangJuHong/FlutterClipboardListener)       | 粘贴板监听器               | [![pub package](https://img.shields.io/pub/v/clipboard_listener.svg)](https://pub.dartlang.org/packages/clipboard_listener)         |
| Flutter | [FlutterQiniucloudLivePlugin](https://github.com/JiangJuHong/FlutterQiniucloudLivePlugin) | Flutter 七牛云直播云插件    | 暂未发布，通过 git 集成                       
## Contributors ✨

Thanks goes to these wonderful people
([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/wenboLee"><img src="https://avatars.githubusercontent.com/u/16222902?v=4?s=100" width="100px;" alt=""/><br /><sub><b>wenbo_lee</b></sub></a><br /><a href="https://github.com/JiangJuHong/FlutterTextSpanField/commits?author=wenboLee" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/ConanXie"><img src="https://avatars.githubusercontent.com/u/10040846?v=4?s=100" width="100px;" alt=""/><br /><sub><b>xiejie</b></sub></a><br /><a href="https://github.com/JiangJuHong/FlutterTextSpanField/commits?author=ConanXie" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/cherrybiu"><img src="https://avatars.githubusercontent.com/u/26567876?v=4?s=100" width="100px;" alt=""/><br /><sub><b>淡航</b></sub></a><br /><a href="https://github.com/JiangJuHong/FlutterTextSpanField/commits?author=cherrybiu" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the
[all-contributors](https://github.com/all-contributors/all-contributors)
specification. Contributions of any kind welcome!
