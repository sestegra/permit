/*
 * Permit
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2017 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
package com.goposse.permit.types

import android.Manifest
import com.goposse.permit.common.PERMIT_NOT_USED

enum class PermitType(val value: Int) {
	camera(0) {
		override fun permission() = Manifest.permission.CAMERA
	},
	coarseLocation(1) {
		override fun permission() = Manifest.permission.ACCESS_COARSE_LOCATION
	},
	fineLocation(2) {
		override fun permission() = Manifest.permission.ACCESS_FINE_LOCATION
	},
	whenInUseLocation(3) {
		override fun permission() = PERMIT_NOT_USED;
	},
	alwaysLocation(4) {
		override fun permission() = PERMIT_NOT_USED;
	},
	phone(5) {
		override fun permission() = Manifest.permission.CALL_PHONE
	},
	push(6) {
		override fun permission() = PERMIT_NOT_USED
	};

	abstract fun permission(): String

	companion object {
		val valueMap = mapOf(
				0 to camera,
				1 to coarseLocation,
				2 to fineLocation,
				3 to whenInUseLocation,
				4 to alwaysLocation,
				5 to phone,
				6 to push
		)

		val stringMap = mapOf(
				camera.permission() to camera,
				coarseLocation.permission() to coarseLocation,
				fineLocation.permission() to fineLocation,
				phone.permission() to phone
		)

		fun fromInt(intValue: Int): PermitType? = valueMap[intValue]
		fun fromString(stringValue: String): PermitType? = stringMap[stringValue]
	}
}
