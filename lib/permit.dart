import 'dart:async';

import 'dart:collection';
import 'package:flutter/services.dart';

enum PermitType { camera, coarseLocation, fineLocation, phone, push }
enum PermissionStatus { unknown, needsRationale, denied, granted }

class PermitResult {
  static final errorCodeGeneral = 500;

  // generic error result
  static PermitResult error = new PermitResult(null,
      errorCode: errorCodeGeneral, errorMessage: "Permissions Check Failed");

  // constructors
  PermitResult(this.results, {this.errorCode = 0, this.errorMessage});

  /// if there was an error returned while trying to check the permission status
  final int errorCode;

  /// if the platform plugin has provided an error message
  final String errorMessage;

  /// see: https://developer.android.com/training/permissions/requesting.html#perm-request
  /// NOTE: needsJustification will always be false on iOS as you can only request
  /// permissions once
  final Map<PermitType, PermissionStatus> results;

  // Used to check if the result was successful, or if there was an error
  bool success() => errorCode == 0;

  PermissionStatus resultCodeForPermitType(PermitType permitType) {
    return results[permitType];
  }
}

class Permit {
  static const MethodChannel _channel = const MethodChannel('permit');

  // plugin functions
  static Future<PermitResult> checkPermissions(
      List<PermitType> permissions) async {
    var intPermissionsSet =
        new Set<int>.from(permissions.map((type) => type.index));
    try {
      // channelResults should be a LinkedHashMap with int keys and int values
      var channelResults = await _channel.invokeMethod('check', {
        'permissions': intPermissionsSet.toList(),
      });

      if (channelResults == null) {
        return new PermitResult(
          null,
          errorCode: PermitResult.errorCodeGeneral,
          errorMessage: "Check permissions failed: null channel results",
        );
      } else {
        return new PermitResult(_resultsFromMap(channelResults));
      }
    } on PlatformException catch (e) {
      return new PermitResult(
        null,
        errorCode: PermitResult.errorCodeGeneral,
        errorMessage: "Check permissions failed: ${e.message}",
      );
    }
  }

  static Future<PermitResult> requestPermissions(
      List<PermitType> permissions) async {
    var intPermissionsSet =
        new Set<int>.from(permissions.map((type) => type.index));

    try {
      // channelResults should be a LinkedHashMap with int keys and int values
      var channelResults = await _channel.invokeMethod('request', {
        'permissions': intPermissionsSet.toList(),
      });

      if (channelResults == null) {
        return new PermitResult(
          null,
          errorCode: PermitResult.errorCodeGeneral,
          errorMessage: "Check permissions failed: null channel results",
        );
      } else {
        return new PermitResult(_resultsFromMap(channelResults));
      }
    } on PlatformException catch (e) {
      return new PermitResult(
        null,
        errorCode: PermitResult.errorCodeGeneral,
        errorMessage: "Check permissions failed: ${e.message}",
      );
    }
  }

  static Map<PermitType, PermissionStatus> _resultsFromMap(
      Map<int, int> resultsMap) {
    Map<PermitType, PermissionStatus> finalResults =
        new Map<PermitType, PermissionStatus>();
    resultsMap.forEach((permitTypeInt, permissionResult) {
      finalResults[_permitTypeFromInt(permitTypeInt)] =
          PermissionStatus.values[permissionResult];
    });
    return finalResults;
  }

  static PermitType _permitTypeFromInt(int permitTypeInt) {
    if (permitTypeInt >= 0 && permitTypeInt < PermitType.values.length) {
      return PermitType.values[permitTypeInt];
    }
    return null;
  }
}
