#import "VideoEditorPlugin.h"
#if __has_include(<camera_filters/camera_filters-Swift.h>)
#import <camera_filters/camera_filters-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "camera_filters-Swift.h"
#endif

@implementation VideoEditorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftVideoEditorPlugin registerWithRegistrar:registrar];
}
@end
