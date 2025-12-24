package com.example.fitness_app

import android.Manifest
import android.content.Context
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : FlutterActivity(), SensorEventListener {
    private val TAG = "StepDetector"
    private val STEP_CHANNEL = "com.example.fitness_app/step_detector"
    private val STEP_EVENT_CHANNEL = "com.example.fitness_app/step_events"
    private val PREFS_NAME = "FlutterSharedPreferences"
    private val STEP_COUNT_KEY = "flutter.native_step_count"
    private val STEP_DATE_KEY = "flutter.native_step_date"
    private val PERMISSION_REQUEST_CODE = 1001

    private var sensorManager: SensorManager? = null
    private var stepDetector: Sensor? = null
    private var eventSink: EventChannel.EventSink? = null
    private var prefs: SharedPreferences? = null
    private var isListening: Boolean = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d(TAG, "configureFlutterEngine called")
        
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        stepDetector = sensorManager?.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
        prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        Log.d(TAG, "Step detector available: ${stepDetector != null}")
        
        // List all available sensors for debugging
        val sensors = sensorManager?.getSensorList(Sensor.TYPE_ALL)
        sensors?.forEach { sensor ->
            if (sensor.name.contains("step", ignoreCase = true)) {
                Log.d(TAG, "Found step sensor: ${sensor.name} (type: ${sensor.type})")
            }
        }

        // Reset for new day if needed
        checkAndResetForNewDay()

        // Method channel for control
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STEP_CHANNEL).setMethodCallHandler { call, result ->
            Log.d(TAG, "Method call: ${call.method}")
            when (call.method) {
                "startListening" -> {
                    // Request permission first, then start listening
                    requestActivityPermission()
                    Log.d(TAG, "startListening called, permission requested")
                    result.success(stepDetector != null)
                }
                "stopListening" -> {
                    stopListening()
                    result.success(true)
                }
                "getStepCount" -> {
                    checkAndResetForNewDay()
                    val count = prefs?.getInt(STEP_COUNT_KEY, 0) ?: 0
                    Log.d(TAG, "getStepCount: $count")
                    result.success(count)
                }
                "resetStepCount" -> {
                    prefs?.edit()?.putInt(STEP_COUNT_KEY, 0)?.apply()
                    result.success(true)
                }
                "isAvailable" -> {
                    val available = stepDetector != null
                    Log.d(TAG, "isAvailable: $available")
                    result.success(available)
                }
                "requestPermission" -> {
                    requestActivityPermission()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Event channel for real-time step events
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, STEP_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    Log.d(TAG, "EventChannel onListen")
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    Log.d(TAG, "EventChannel onCancel")
                    eventSink = null
                }
            }
        )

        // Don't auto-request permission - let Dart control timing (after login)
        // Permission will be requested via method channel when startListening is called
    }

    private fun requestActivityPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACTIVITY_RECOGNITION) 
                != PackageManager.PERMISSION_GRANTED) {
                Log.d(TAG, "Requesting ACTIVITY_RECOGNITION permission")
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.ACTIVITY_RECOGNITION),
                    PERMISSION_REQUEST_CODE
                )
            } else {
                Log.d(TAG, "ACTIVITY_RECOGNITION permission already granted")
                startListening()
            }
        } else {
            Log.d(TAG, "Android < Q, no permission needed")
            startListening()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Log.d(TAG, "ACTIVITY_RECOGNITION permission granted")
                startListening()
            } else {
                Log.e(TAG, "ACTIVITY_RECOGNITION permission denied")
            }
        }
    }

    private fun checkAndResetForNewDay() {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
        val savedDate = prefs?.getString(STEP_DATE_KEY, null)
        
        if (savedDate != today) {
            Log.d(TAG, "New day detected, resetting step count")
            prefs?.edit()?.apply {
                putInt(STEP_COUNT_KEY, 0)
                putString(STEP_DATE_KEY, today)
                apply()
            }
        }
    }

    private fun startListening(): Boolean {
        if (stepDetector == null) {
            Log.e(TAG, "Step detector sensor not available on this device")
            return false
        }
        
        if (isListening) {
            Log.d(TAG, "Already listening")
            return true
        }
        
        val registered = sensorManager?.registerListener(
            this,
            stepDetector,
            SensorManager.SENSOR_DELAY_FASTEST
        ) ?: false
        
        isListening = registered
        Log.d(TAG, "Sensor listener registered: $registered")
        return registered
    }

    private fun stopListening() {
        if (!isListening) return
        
        sensorManager?.unregisterListener(this)
        isListening = false
        Log.d(TAG, "Sensor listener unregistered")
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_STEP_DETECTOR) {
            checkAndResetForNewDay()
            
            // Increment and save step count
            val currentSteps = prefs?.getInt(STEP_COUNT_KEY, 0) ?: 0
            val newSteps = currentSteps + 1
            prefs?.edit()?.putInt(STEP_COUNT_KEY, newSteps)?.apply()

            Log.d(TAG, "Step detected! Total: $newSteps")

            // Send to Flutter if listening
            eventSink?.success(mapOf(
                "steps" to newSteps,
                "timestamp" to System.currentTimeMillis()
            ))
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        Log.d(TAG, "Sensor accuracy changed: $accuracy")
    }

    override fun onResume() {
        super.onResume()
        Log.d(TAG, "onResume - starting listener")
        startListening()
    }

    override fun onPause() {
        super.onPause()
        Log.d(TAG, "onPause - keeping listener active")
        // Don't stop - keep counting in background
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "onDestroy")
        // Don't stop - we want to keep counting
    }
}
