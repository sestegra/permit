/*
 * Permit
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2017 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
package com.goposse.permit.activities

import android.app.Activity
import android.os.Bundle
import android.os.ResultReceiver
import android.support.v4.app.ActivityCompat
import android.util.Log
import com.goposse.permit.common.PERMIT_PERMISSION_REQUEST_CODE
import com.goposse.permit.common.PERMIT_RECEIVER_CODE_INVALID_REQUEST
import com.goposse.permit.common.PERMIT_RECEIVER_CODE_VALID_REQUEST

class PermissionActivity : Activity() {

	val LOG_TAG = "PMT:A:Pmsn"

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		val permissions = intent.extras.getStringArray("permissions")
		if (permissions == null) {
			Log.w(LOG_TAG, "No Permissions were requested. Completing.")
			complete(resultCode = PERMIT_RECEIVER_CODE_INVALID_REQUEST)
			return
		}
		ActivityCompat.requestPermissions(this, permissions, PERMIT_PERMISSION_REQUEST_CODE)
	}

	override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>?, grantResults: IntArray?) {
		super.onRequestPermissionsResult(requestCode, permissions, grantResults)
		if (requestCode == PERMIT_PERMISSION_REQUEST_CODE) {
			Log.d(LOG_TAG, "Some permissions received. Completing.")
			complete(permissions, grantResults)
		}
	}

	private fun complete(permissions: Array<out String>? = null, grantResults: IntArray? = null,
						 resultCode: Int = PERMIT_RECEIVER_CODE_VALID_REQUEST) {
		val receiver = intent.extras.get("resultReceiver") as ResultReceiver
		val resultData = Bundle()
		if (permissions != null && grantResults != null) {
			resultData.putStringArray("permissions", permissions)
			resultData.putIntArray("grantResults", grantResults)
		}
		receiver.send(resultCode, resultData)
		finish()
	}
}