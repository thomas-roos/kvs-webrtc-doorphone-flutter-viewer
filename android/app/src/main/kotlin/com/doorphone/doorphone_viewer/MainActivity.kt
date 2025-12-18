package com.doorphone.doorphone_viewer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import android.content.Intent
import android.net.Uri
import android.os.Bundle

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.doorphone.doorphone_viewer/native"
    private lateinit var kvsWebRTCPlugin: KVSWebRTCPlugin

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize KVS WebRTC plugin
        kvsWebRTCPlugin = KVSWebRTCPlugin(this)
        
        // Set up method channel for native functionality
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "handleDeepLink" -> {
                    val deepLink = call.argument<String>("deepLink")
                    handleDeepLink(deepLink)
                    result.success(null)
                }
                "requestPermissions" -> {
                    requestNecessaryPermissions()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Set up KVS WebRTC method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.doorphone.doorphone_viewer/kvs_webrtc")
            .setMethodCallHandler(kvsWebRTCPlugin)
            
        // Set up KVS WebRTC event channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.doorphone.doorphone_viewer/kvs_webrtc_events")
            .setStreamHandler(kvsWebRTCPlugin)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Handle deep link if app was opened from notification
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        if (::kvsWebRTCPlugin.isInitialized) {
            kvsWebRTCPlugin.dispose()
        }
    }

    private fun handleIntent(intent: Intent?) {
        intent?.let {
            if (it.action == Intent.ACTION_VIEW) {
                val data = it.data
                data?.let { uri ->
                    handleDeepLink(uri.toString())
                }
            }
        }
    }

    private fun handleDeepLink(deepLink: String?) {
        deepLink?.let {
            // Parse deep link and navigate to appropriate screen
            // This will be handled by the Flutter side
            println("Deep link received: $it")
        }
    }

    private fun requestNecessaryPermissions() {
        // Request camera and microphone permissions
        // This is handled by the permission_handler plugin
    }
}