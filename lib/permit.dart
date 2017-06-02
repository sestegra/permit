import 'dart:async';

import 'dart:collection';
import 'package:flutter/services.dart';

enum PermitType {
  camera,
  coarseLocation,
  fineLocation,
  phone,
  push
}


class PermitResult {

  static final _mapKeyResult = "result";
  static final _mapKeyErrorCode = "errorCode";
  static final _mapKeyErrorMessage = "errorMessage";

  static final resultCodePermitted = 1;
  static final resultCodeNotPermitted = -1;
  static final resultCodeRequiresJustification = 2;
  static final resultUnknown = 0;

  static final errorCodeGeneral = 500;

  // generic error result
  static PermitResult error = new PermitResult(resultCodePermitted, errorCode: errorCodeGeneral,
      errorMessage: "Permissions Check Failed");

  // constructors
  PermitResult(this.result, {this.errorCode = 0, this.errorMessage});

  PermitResult.fromMap(Map<String, dynamic> map) :
      this.result = map[_mapKeyResult] ?? -1,
      this.errorCode = map[_mapKeyErrorCode],
      this.errorMessage = map[_mapKeyErrorMessage];

  /// see: https://developer.android.com/training/permissions/requesting.html#perm-request
  /// NOTE: needsJustification will always be false on iOS as you can only request
  /// permissions once
  final int result;
  /// if there was an error returned while trying to check the permission status
  final int errorCode;
  /// if the platform plugin has provided an error message
  final String errorMessage;
}


class Permit {

  static const MethodChannel _channel = const MethodChannel('permit');

  // plugin functions
  static Future<Map<PermitType, PermitResult>> checkPermissions(List<PermitType> permissions) async {
    var intPermissionsSet = new Set<int>.from(permissions.map((type) => type.index));
    try {
      Map<String, dynamic> resultsMap = await _channel.invokeMethod('check',
          {'permissions': intPermissionsSet.toList()});
      if (resultsMap == null) {
        print("Check permissions failed: no resultsMap was returned from invokeMethod");
      } else {
        // Loop through each result and check permissions
        if (resultsMap.containsKey("results") && resultsMap["results"] is LinkedHashMap<int, int>) {
          LinkedHashMap<int, int> map = resultsMap["results"];
          Map<PermitType, PermitResult> permitMap = new Map<PermitType, PermitResult>();
          map.forEach((permitTypeInt, permitResultInt) {
            PermitType permitType = _permitTypeFromInt(permitTypeInt);
            if (permitType != null) {
              print(permitType.toString());
              PermitResult permitResult = new PermitResult(permitResultInt);
              permitMap[permitType] = permitResult;
            }
          });
          return permitMap;
        } else {
          print("Check permissions failed: permissions map was null or of the wrong type");
        }
      }
    }  on PlatformException catch (e) {
      print("Check permissions failed: ${e.message}");
    }
    return null;
  }

  static Future<Map<PermitType, PermitResult>> requestPermissions(List<PermitType> permissions) async {
    var intPermissionsSet = new Set<int>.from(permissions.map((type) => type.index));
    Map<String, dynamic> permissionsMap = await _channel.invokeMethod('request',
        {'permissions' : intPermissionsSet.toList()});
    if (permissionsMap == null) {
//      return new PermitResult.fromMap(permissionsMap);
    }
//    return new PermitResult.fromMap(permissionsMap);
  return null;
  }

  static PermitType _permitTypeFromInt(int permitTypeInt) {
    if (permitTypeInt >= 0 && permitTypeInt < PermitType.values.length) {
      return PermitType.values[permitTypeInt];
    }
    return null;
  }


}
