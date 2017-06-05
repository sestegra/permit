#import "PermitPlugin.h"
#import <AVFoundation/AVFoundation.h>

@implementation PermitPlugin

const int CAMERA_PERMISSION_VALUE = 0;
const int COARSE_LOCATION_PERMISSION_VALUE = 1;
const int FINE_LOCATION_PERMISSION_VALUE = 2;
const int PHONE_PERMISSION_VALUE = 3;
const int PUSH_PERMISSION_VALUE = 4;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"permit"
            binaryMessenger:[registrar messenger]];
  PermitPlugin* instance = [[PermitPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([self isImplementedMethodCall:call.method]) {
    NSLog(@"Method call was %@, invoking plugin", call.method);
    NSArray* permissions = (NSArray*)call.arguments[@"permissions"];
    if (permissions == nil || permissions.count == 0) {
      NSLog(@"No permissions were passed");
      result([FlutterError errorWithCode:@"701"
                                 message:@"No permissions were passed"
                                 details:nil]);
      return;
    }
    if ([call.method isEqualToString:@"check"]) {
      [self checkPermissions:permissions result:result];
    } else if ([call.method isEqualToString:@"request"]) {
      [self requestPermissions:permissions result:result];
    }
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)checkPermissions:(NSArray*)permissions result:(FlutterResult)result {
  for (NSNumber *permissionInt in permissions) {
    if (permissionInt == CAMERA_PERMISSION_VALUE) {
      AVAuthorizationStatus avStatus =
      [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    }
  }
  result([FlutterError errorWithCode:@"701"
                             message:@"check permissions not implemented"
                             details:nil]);
}

- (void)requestPermissions:(NSArray*)permissions result:(FlutterResult)result {
  result([FlutterError errorWithCode:@"701"
                             message:@"request permissions not implemented"
                             details:nil]);
}

- (BOOL)isImplementedMethodCall:(NSString*)callMethod {
  if ([callMethod isEqualToString:@"check"] || [callMethod isEqualToString:@"request"]) {
    return YES;
  } 
  return NO;
}

@end
