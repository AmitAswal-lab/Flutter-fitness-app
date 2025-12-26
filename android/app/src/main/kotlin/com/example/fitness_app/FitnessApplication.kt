package com.example.fitness_app

import io.flutter.app.FlutterApplication
import android.content.Context
import android.util.Log

class FitnessApplication : FlutterApplication() {
    private val TAG = "FitnessApplication"
    
    // Global access to the listener
    companion object {
        var stepSensorListener: StepSensorListener? = null
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "FitnessApplication onCreate - Initializing core services")
        
        // Initialize the sensor listener immediately when the process starts.
        // This ensures step counting continues even if the MainActivity is destroyed
        // but the process remains alive (e.g. by the Foreground Service).
        if (stepSensorListener == null) {
            stepSensorListener = StepSensorListener(applicationContext)
            
            // Attempt to start listening immediately if permission is already granted.
            // This restores functionality after a process death/restart without requiring UI interaction.
            stepSensorListener?.tryStartIfPermitted() 
        }
    }
}
