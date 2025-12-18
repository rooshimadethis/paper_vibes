package com.example.film_vibes

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.os.PowerManager

class MainActivity : FlutterActivity() {
    private val CHANNEL = "paper_vibes/overlay"
    private val OVERLAY_PERMISSION_REQUEST_CODE = 1

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermission" -> {
                    result.success(checkOverlayPermission())
                }
                "isOverlayRunning" -> {
                    result.success(CustomOverlayService.isRunning)
                }
                "requestPermission" -> {
                    if (checkOverlayPermission()) {
                        result.success(true)
                    } else {
                        requestOverlayPermission()
                        result.success(checkOverlayPermission())
                    }
                }
                "startOverlay" -> {
                    val baseOpacity = call.argument<Double>("baseOpacity") ?: 0.25
                    val grainOpacity = call.argument<Double>("grainOpacity") ?: 0.40
                    val tintOpacity = call.argument<Double>("tintOpacity") ?: 0.10

                    val intent = Intent(this, CustomOverlayService::class.java)
                    intent.putExtra("baseOpacity", baseOpacity)
                    intent.putExtra("grainOpacity", grainOpacity)
                    intent.putExtra("tintOpacity", tintOpacity)

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(null)
                }
                "stopOverlay" -> {
                    val intent = Intent(this, CustomOverlayService::class.java)
                    stopService(intent)
                    result.success(null)
                }
                "updateOverlaySettings" -> {
                    val baseOpacity = call.argument<Double>("baseOpacity") ?: 0.25
                    val grainOpacity = call.argument<Double>("grainOpacity") ?: 0.40
                    val tintOpacity = call.argument<Double>("tintOpacity") ?: 0.10
                    
                    val intent = Intent("com.example.paper_vibes.UPDATE_OVERLAY")
                    intent.setPackage(packageName)
                    intent.putExtra("baseOpacity", baseOpacity)
                    intent.putExtra("grainOpacity", grainOpacity)
                    intent.putExtra("tintOpacity", tintOpacity)
                    sendBroadcast(intent)
                    result.success(null)
                }
                "checkBatteryOptimization" -> {
                    result.success(checkBatteryOptimization())
                }
                "requestBatteryOptimization" -> {
                    requestBatteryOptimization()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivityForResult(intent, OVERLAY_PERMISSION_REQUEST_CODE)
        }
    }

    private fun checkBatteryOptimization(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            return powerManager.isIgnoringBatteryOptimizations(packageName)
        }
        return true
    }

    private fun requestBatteryOptimization() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent()
            intent.action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
            intent.data = Uri.parse("package:$packageName")
            startActivity(intent)
        }
    }
}
