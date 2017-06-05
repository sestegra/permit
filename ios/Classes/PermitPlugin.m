#import "PermitPlugin.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>


@implementation PermitPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"permit"
            binaryMessenger:[registrar messenger]];
  PermitPlugin* instance = [[PermitPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
  self = [super init];
  if (self != nil) {
    self.clLocationManager = [[CLLocationManager alloc] init];
    self.clLocationManager.delegate = self;
  }
  return self;
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
  NSMutableDictionary *resultsDictionary = [[NSMutableDictionary alloc] init];
  for (NSNumber *permissionNumber in permissions) {
    // The default status will be unavailable for any permission type
    long permissionTypeLong = [permissionNumber longValue];
    int permissionStatus = PermissionResultUnavailable;
    
    if (permissionTypeLong == PermitTypeWhenInUseLocation
        || permissionTypeLong == PermitTypeAlwaysLocation) {
      // Location permissions check
      CLAuthorizationStatus clAuthStatus =
        [CLLocationManager authorizationStatus];
      
      // Default to denied, which would be the final else case
      permissionStatus = PermissionResultDenied;
      if (clAuthStatus == kCLAuthorizationStatusNotDetermined) {
        permissionStatus = PermissionResultUnknown;
      } else if ((clAuthStatus == kCLAuthorizationStatusAuthorizedAlways) ||
                 (clAuthStatus == kCLAuthorizationStatusAuthorizedWhenInUse &&
                 permissionTypeLong == PermitTypeWhenInUseLocation)) {
        // This checks if the status is always granted, or if it is only
        // when in use, check if that was what was requested.
        permissionStatus = PermissionResultGranted;
      }
    }
    [resultsDictionary setObject:[NSNumber numberWithInt:permissionStatus]
                          forKey:[NSNumber numberWithLong:permissionTypeLong]];
  }
  NSLog(@"returning with check results: %@", resultsDictionary);
  result(resultsDictionary);
}

- (void)requestPermissions:(NSArray*)permissions result:(FlutterResult)result {
  NSMutableDictionary *resultsDictionary = [[NSMutableDictionary alloc] init];
  for (NSNumber *permissionNumber in permissions) {
    long permissionTypeLong = [permissionNumber longValue];
    if (permissionTypeLong == PermitTypeAlwaysLocation) {
      [self.clLocationManager requestAlwaysAuthorization];
      self.locationPermissionRequestCallback = ^(CLAuthorizationStatus status ) {
        PermissionResult finalResult = PermissionResultDenied;
        if (status == kCLAuthorizationStatusAuthorizedAlways) {
          finalResult = PermissionResultGranted;
        }
        [resultsDictionary setObject:[NSNumber numberWithInt:finalResult]
                              forKey:[NSNumber numberWithLong:permissionTypeLong]];
        result(resultsDictionary);
        return;
        
      };
    } else if (permissionTypeLong == PermitTypeWhenInUseLocation) {
      [self.clLocationManager requestWhenInUseAuthorization];
      self.locationPermissionRequestCallback = ^(CLAuthorizationStatus status ) {
        PermissionResult finalResult = PermissionResultDenied;
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
          finalResult = PermissionResultGranted;
        }
        [resultsDictionary setObject:[NSNumber numberWithInt:finalResult]
                              forKey:[NSNumber numberWithLong:permissionTypeLong]];
        
        result(resultsDictionary);
        return;
      };
    }
  }
}


- (BOOL)isImplementedMethodCall:(NSString*)callMethod {
  if ([callMethod isEqualToString:@"check"] ||
      [callMethod isEqualToString:@"request"]) {
    return YES;
  } 
  return NO;
}

// CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  if (self.locationPermissionRequestCallback != nil) {
    self.locationPermissionRequestCallback(status);
  }
}

@end
