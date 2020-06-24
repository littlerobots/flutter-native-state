#import "FlutterNativeStatePlugin.h"

#if __has_include(<native_state/native_state-Swift.h>)
#import <native_state/native_state-Swift.h>
#else
#import "native_state-Swift.h"
#endif

@implementation FlutterNativeStatePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterNativeStatePlugin registerWithRegistrar:registrar];
}
@end
