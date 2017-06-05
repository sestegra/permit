/*
 * Permit
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2017 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
package com.goposse.permit.types

enum class PermitResult(val value: Int) {
	unknown(0),
	needsRationale(1),
	denied(2),
	granted(3);

	companion object {
		fun fromResultCode(resultCode: Int): PermitResult {
			if (resultCode == -1) {
				return denied
			} else if (resultCode == 0) {
				return granted
			}
			return unknown
		}
	}
}
