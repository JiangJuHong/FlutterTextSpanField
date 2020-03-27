#import "TextSpanFieldPlugin.h"
#if __has_include(<text_span_field/text_span_field-Swift.h>)
#import <text_span_field/text_span_field-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "text_span_field-Swift.h"
#endif

@implementation TextSpanFieldPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTextSpanFieldPlugin registerWithRegistrar:registrar];
}
@end
