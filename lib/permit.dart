import 'dart:async';

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

  static final resultCodePermitted = 0;
  static final resultCodeNotPermitted = -1;

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
    Map<String, dynamic> permissionsMap = await _channel.invokeMethod('check',
        {'permissions' : intPermissionsSet.toList()});
    if (permissionsMap == null) {
//      return new PermitResult.fromMap(permissionsMap);
    }
//    return new PermitResult.fromMap(permissionsMap);
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


}
