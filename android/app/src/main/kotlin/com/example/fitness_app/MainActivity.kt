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
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : FlutterActivity() {
    private val TAG = "StepDetector"
    private val STEP_CHANNEL = "com.example.fitness_app/step_detector"
    private val STEP_EVENT_CHANNEL = "com.example.fitness_app/step_events"
    private val PERMISSION_REQUEST_CODE = 1001

    private var eventSink: EventChannel.EventSink? = null
    
    // Helper to get listener from Application
    private val stepSensorListener: StepSensorListener?
        get() = FitnessApplication.stepSensorListener

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d(TAG, "configureFlutterEngine called")

        // Ensure listener is initialized (should be from App.onCreate, but just in case)
        if (FitnessApplication.stepSensorListener == null) {
             FitnessApplication.stepSensorListener = StepSensorListener(applicationContext)
        }
        
        // Update sink reference
        stepSensorListener?.setEventSink(null)

        // Method channel for control
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STEP_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startListening" -> {
                    // Request permission first
                    if (hasActivityPermission()) {
                        val wasAlreadyListening = stepSensorListener?.isListening == true
                        val started = stepSensorListener?.startListening() ?: false
                        
                        // Only show toast if it wasn't running and we just started it
                        if (started && !wasAlreadyListening) {
                            Toast.makeText(this, "Step Counter Started", Toast.LENGTH_SHORT).show()
                        } else if (!started) {
                             // Only show if we tried to start but failed (not available)
                            val available = stepSensorListener?.isSensorAvailable() ?: false
                            if (!available) {
                                Toast.makeText(this, "No Step Sensor Found", Toast.LENGTH_LONG).show()
                            }
                        }
                        result.success(started)
                    } else {
                        requestActivityPermission()
                        result.success(false)
                    }
                }
                "stopListening" -> {
                    stepSensorListener?.stopListening()
                    result.success(true)
                }
                "getStepCount" -> {
                    val count = stepSensorListener?.getStepCount() ?: 0
                    result.success(count)
                }
                "resetStepCount" -> {
                    stepSensorListener?.resetStepCount()
                    result.success(true)
                }
                "isAvailable" -> {
                    result.success(stepSensorListener?.isSensorAvailable() ?: false)
                }
                "requestPermission" -> {
                    requestActivityPermission()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Event channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, STEP_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    stepSensorListener?.setEventSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    stepSensorListener?.setEventSink(null)
                }
            }
        )
    }

    private fun hasActivityPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ContextCompat.checkSelfPermission(this, Manifest.permission.ACTIVITY_RECOGNITION) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun requestActivityPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            if (!hasActivityPermission()) {
                Log.d(TAG, "Requesting ACTIVITY_RECOGNITION permission")
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.ACTIVITY_RECOGNITION),
                    PERMISSION_REQUEST_CODE
                )
            }
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
                val started = stepSensorListener?.startListening() ?: false
                if (started) {
                     Toast.makeText(this, "Permission Granted & Started", Toast.LENGTH_SHORT).show()
                }
            } else {
                Log.e(TAG, "ACTIVITY_RECOGNITION permission denied")
                Toast.makeText(this, "Permission Denied - Steps won't count", Toast.LENGTH_LONG).show()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "MainActivity onDestroy - Step Listener continues in FitnessApplication")
    }
}

class StepSensorListener(private val context: Context) : SensorEventListener {
    private val TAG = "StepSensorListener"
    private val PREFS_NAME = "FlutterSharedPreferences"
    private val STEP_COUNT_KEY = "flutter.native_step_count"
    private val STEP_DATE_KEY = "flutter.native_step_date"

    private val sensorManager: SensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val stepDetector: Sensor? = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_DETECTOR)
    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    
    var isListening = false
        private set
    private var eventSink: EventChannel.EventSink? = null

    fun isSensorAvailable(): Boolean = stepDetector != null

    fun setEventSink(sink: EventChannel.EventSink?) {
        this.eventSink = sink
    }
    
    fun tryStartIfPermitted() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
           if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACTIVITY_RECOGNITION) == PackageManager.PERMISSION_GRANTED) {
               startListening()
           }
        } else {
            startListening()
        }
    }

    fun startListening(): Boolean {
        if (stepDetector == null) {
            Log.e(TAG, "No STEP_DETECTOR sensor found")
            return false
        }
        // If already listening, assume success and return true
        if (isListening) return true

        val registered = sensorManager.registerListener(
            this,
            stepDetector,
            SensorManager.SENSOR_DELAY_FASTEST
        )
        isListening = registered
        Log.d(TAG, "Started listening: $registered")
        return registered
    }

    fun stopListening() {
        if (isListening) {
            sensorManager.unregisterListener(this)
            isListening = false
            Log.d(TAG, "Stopped listening")
        }
    }

    fun getStepCount(): Int {
        checkAndResetForNewDay()
        return prefs.getInt(STEP_COUNT_KEY, 0)
    }

    fun resetStepCount() {
        prefs.edit().putInt(STEP_COUNT_KEY, 0).apply()
    }

    private fun checkAndResetForNewDay() {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date())
        val savedDate = prefs.getString(STEP_DATE_KEY, null)

        if (savedDate != today) {
            Log.d(TAG, "New day detected: $today (was $savedDate)")
            val previousSteps = prefs.getInt(STEP_COUNT_KEY, 0)
            
            prefs.edit().apply {
                if (savedDate != null) {
                    putString("flutter.previous_day_date", savedDate)
                    putInt("flutter.previous_day_steps", previousSteps)
                }
                putInt(STEP_COUNT_KEY, 0)
                putString(STEP_DATE_KEY, today)
                apply()
            }
        }
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_STEP_DETECTOR) {
            checkAndResetForNewDay()

            val currentSteps = prefs.getInt(STEP_COUNT_KEY, 0)
            val newSteps = currentSteps + 1
            
            prefs.edit().putInt(STEP_COUNT_KEY, newSteps).apply()
            
            Log.d(TAG, "Step detected: $newSteps")
            
            try {
                eventSink?.success(mapOf(
                    "steps" to newSteps,
                    "timestamp" to System.currentTimeMillis()
                ))
            } catch (e: Exception) {
                // Ignore channel errors
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // No op
    }
}
