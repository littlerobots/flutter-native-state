#import "FlutterNativeStatePlugin.h"
#import <native_state/native_state-Swift.h>

@implementation FlutterNativeStatePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterNativeStatePlugin registerWithRegistrar:registrar];
}
@end
