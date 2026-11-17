package com.pseudolearn.app

import android.content.Context

object PlatformCertificateVerifier {
    private const val BRIDGE_LIBRARY = "pseudolearn_bridge"

    @Volatile
    private var initialized = false

    @Synchronized
    fun initializeOnce(context: Context) {
        if (initialized) return
        System.loadLibrary(BRIDGE_LIBRARY)
        initialize(context.applicationContext)
        initialized = true
    }

    @JvmStatic
    private external fun initialize(applicationContext: Context)
}
