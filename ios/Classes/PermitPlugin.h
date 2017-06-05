#import <Flutter/Flutter.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, PermitType) {
  PermitTypeCamera = 0,
  PermitTypeCoarseLocation = 1,
  PermitTypeFineLocation = 2,
  PermitTypeWhenInUseLocation = 3,
  PermitTypeAlwaysLocation = 4,
  PermitTypePhone = 5,
  PermitTypePush = 6,
};

typedef NS_ENUM(NSInteger, PermissionResult) {
  PermissionResultUnknown = 0,
  PermissionResultNeedsRationale = 1,
  PermissionResultDenied = 2,
  PermissionResultGranted = 3,
  PermissionResultUnavailable = 4,
};

@interface PermitPlugin : NSObject<FlutterPlugin, CLLocationManagerDelegate>
  @property CLLocationManager *clLocationManager;
  @property (nonatomic, copy) void (^locationPermissionRequestCallback)(CLAuthorizationStatus);
@end

