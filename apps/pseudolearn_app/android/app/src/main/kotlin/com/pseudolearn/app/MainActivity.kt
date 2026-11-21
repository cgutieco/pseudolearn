package com.pseudolearn.app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        PlatformCertificateVerifier.initializeOnce(this)
        super.onCreate(savedInstanceState)
    }
}
