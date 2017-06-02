import 'dart:async';

import 'dart:collection';
import 'package:flutter/services.dart';

enum PermitType { camera, coarseLocation, fineLocation, phone, push }

class PermitResult {
  static final _mapKeyResult = "result";
  static final _mapKeyErrorCode = "errorCode";
  static final _mapKeyErrorMessage = "errorMessage";

  static final resultCodePermitted = 1;
  static final resultCodeNotPermitted = -1;
  static final resultCodeRequiresJustification = 2;
  static final resultUnknown = 0;
  static final resultUnavailable = -2;

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
  final Map<PermitType, int> results;

  // Used to check if the result was successful, or if there was an error
  bool success() => errorCode == 0;

  int resultCodeForPermitType(PermitType permitType) {
    if (results != null && results.containsKey(permitType)) {
      return results[permitType];
    }
    return resultUnavailable;
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
      // channelResults should be a LinkedHashMap with int keys and map<string, dynamic> values
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
    return null;
  }

  static Future<Map<PermitType, PermitResult>> requestPermissions(
      List<PermitType> permissions) async {
    var intPermissionsSet =
        new Set<int>.from(permissions.map((type) => type.index));
    print("calling invoke");
    Map<String, dynamic> permissionsMap = await _channel
        .invokeMethod('request', {'permissions': intPermissionsSet.toList()});
    print("invoke returned");
    if (permissionsMap == null) {
      print("Hello!?");
      return new Map<PermitType, PermitResult>();
    }
    print("WHAT????");
    return new Map<PermitType, PermitResult>();
  }

  static Map<PermitType, int> _resultsFromMap(Map<int, int> resultsMap) {
    Map<PermitType, int> finalResults = new Map<PermitType, int>();
    resultsMap.forEach((permitTypeInt, permitTypeResult) {
      finalResults[_permitTypeFromInt(permitTypeInt)] = permitTypeResult;
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
