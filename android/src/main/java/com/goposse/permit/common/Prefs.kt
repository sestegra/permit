package com.goposse.permit.common

import android.content.Context
import android.content.SharedPreferences

class Prefs(private val context: Context) {
    private val SHARED_PREFS_NAME = "org.goposse.permit.prefs"
    private val PERMISSION_REQUEST_COUNT_KEY_APPENDAGE = "_request_count"
    private var sharedPrefs: SharedPreferences

    init {
        sharedPrefs = context.getSharedPreferences(SHARED_PREFS_NAME, Context.MODE_PRIVATE)
    }

    fun getPermissionRequestCount(permission: String): Int {
        val fullPrefKey = "$permission$PERMISSION_REQUEST_COUNT_KEY_APPENDAGE"
        return sharedPrefs.getInt(fullPrefKey, 0);
    }

    fun incrementPermissionRequestCount(permission: String): Int {
        var currentCount = getPermissionRequestCount(permission)
        currentCount += 1
        putInt("$permission$PERMISSION_REQUEST_COUNT_KEY_APPENDAGE", currentCount)
        return currentCount
    }
    // preference save helpers
    fun putInt(key: String, value: Int) {
        sharedPrefs.edit().putInt(key, value).apply()
    }
}
