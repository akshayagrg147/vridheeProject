package com.mafatlal.lms

import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.bluetooth.BluetoothManager
import android.content.Context
import android.os.Build
import androidx.core.content.ContextCompat
import com.tag_hive.taghive_device_sdk.*
import io.flutter.plugin.common.EventChannel
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import android.util.Log
class MainActivity: FlutterActivity() {
    private lateinit var mTagHiveTagDeviceRepository: TagHiveTagDeviceRepository
    private var bleDisposable: Disposable? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize SDK
        initTaghiveSdk()

        // Set up method and event channels
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example/clicker").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkPermissions" -> {
                        val permissions = checkBlePermissions()
                        result.success(permissions)
                        System.out.println("Permissions: $permissions") // Debug output
                    }
                    "startBleTask" -> {

                        startBleTask()
                        result.success(null)
                    }
                    "stopBleTask" -> {
                        stopBleTask()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }

        EventChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.example/clickerEvents").apply {
            setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    Log.d("MainActivity", "onListen called, starting BLE scanning")
                    eventSink = events
                    startObservingTagDetection(events)
                }

                override fun onCancel(arguments: Any?) {
                    Log.d("MainActivity", "onCancel called, stopping BLE scanning")
                    eventSink = null
                    stopObservingTagDetection()
                }
            })
        }
    }

    private fun initTaghiveSdk() {
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        val tagHiveRadixHelper = TagHiveRadixHelperImpl()
        val tagHiveBluetoothAndroidDeviceSource = TagHiveBluetoothAndroidDeviceSourceImpl(bluetoothManager, tagHiveRadixHelper)
        mTagHiveTagDeviceRepository = TagHiveTagDeviceRepositoryImpl(tagHiveBluetoothAndroidDeviceSource, tagHiveRadixHelper)
    }

    private fun checkBlePermissions(): Boolean {
        val requiredPermissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            arrayOf(
                android.Manifest.permission.BLUETOOTH_SCAN,
                android.Manifest.permission.BLUETOOTH_CONNECT,
                android.Manifest.permission.ACCESS_FINE_LOCATION
            )
        } else {
            arrayOf(
                android.Manifest.permission.BLUETOOTH,
                android.Manifest.permission.BLUETOOTH_ADMIN,
                android.Manifest.permission.ACCESS_FINE_LOCATION
            )
        }

        return requiredPermissions.all {
            ContextCompat.checkSelfPermission(this, it) == android.content.pm.PackageManager.PERMISSION_GRANTED
        }
    }

    private fun startBleTask() {
        // Start BLE Scanning
        bleDisposable = mTagHiveTagDeviceRepository.startObservingTagDetection()
            .debounce(100, java.util.concurrent.TimeUnit.MILLISECONDS)
            .observeOn(AndroidSchedulers.mainThread())
            .subscribe({ tagHiveDevice ->
                // Handle the clicker events
                val event = mapOf(
                    "deviceId" to tagHiveDevice.mAddress,
                    "buttonPressed" to tagHiveDevice.mSwitchEvent.ordinal,
                    "batteryLevel" to tagHiveDevice.mBatteryEvent.name
                )

                // Log the event to the console
                System.out.println("Event: $event")

                // Send the event to Flutter via eventSink
                eventSink?.success(event)
            }, { error ->
                // Handle errors during BLE scanning
                System.err.println("Error during BLE scanning: ${error.message}")
                eventSink?.error("BLE_ERROR", "Error during BLE scanning: ${error.message}", null)
            })
    }

    private fun stopBleTask() {
        // Dispose of BLE scanning
        bleDisposable?.dispose()
        bleDisposable = null
    }

    private fun startObservingTagDetection(events: EventChannel.EventSink?) {
        // Start BLE Scanning when Flutter begins listening for events
        if (bleDisposable == null) {
            startBleTask()
        }
    }

    private fun stopObservingTagDetection() {
        // Stop BLE Scanning when Flutter cancels event listening
        stopBleTask()
    }
}