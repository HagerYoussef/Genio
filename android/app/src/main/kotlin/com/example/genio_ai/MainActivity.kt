package com.example.genio_ai

//import io.flutter.embedding.android.FlutterActivity
//class MainActivity : FlutterActivity()

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.call" // 1- ده تعريف القناة فوق

    // 2- ده لازم يبقى جوه الكلاس
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "callPhone") {
                    val number = call.argument<String>("number")
                    val intent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:$number"))
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}

