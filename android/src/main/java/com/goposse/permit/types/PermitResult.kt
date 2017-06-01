/*
 * Permit
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2017 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
package com.goposse.permit.types

enum class PermitResult(val value: Int) {
	granted(1),
	notGranted(-1),
	requiresJustification(2),
	unknown(0);

	companion object {
		fun fromResultCode(resultCode: Int): PermitResult {
			if (resultCode == -1) {
				return notGranted
			} else if (resultCode == 0) {
				return granted
			}
			return unknown
		}
	}
}
