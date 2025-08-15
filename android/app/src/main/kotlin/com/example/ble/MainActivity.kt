package com.example.ble
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.os.Bundle
import android.os.ParcelUuid
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity: FlutterActivity() {
  private val CHANNEL = "com.example.ble/advertiser"
  private var advertiser: BluetoothLeAdvertiser? = null
  private var advertiseCallback: AdvertiseCallback? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, result ->
      when (call.method) {
        "startAdvertising" -> {
          val uuidString = call.argument<String>("uuid")?:"0000180F-0000-1000-8000-00805f9b34fb"
          val manufacturerId = call.argument<Int>("manufacturerId") ?: 0x1234
          val manufacturerDataList = call.argument<List<Int>>("manufacturerData") ?: listOf(1, 2, 3, 4)
          val manufacturerData = manufacturerDataList.map { it.toByte() }.toByteArray()
          val success = startBleAdvertising(uuidString,manufacturerId,manufacturerData)
          result.success(if (success) "Started advertising" else "Failed to advertise")
        }
        "stopAdvertising" -> {
          stopBleAdvertising()
          result.success("Stopped advertising")
        }
        else -> result.notImplemented()
      }
    }
  }

  private fun startBleAdvertising(uuidStr: String,manufacturerId:Int,manufacturerData:ByteArray ): Boolean {
    val uuid = UUID.fromString(uuidStr)
    Log.d("BLE", "Advertising UUID: $uuid")
    val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    val bluetoothAdapter = bluetoothManager.adapter
    advertiseCallback = object : AdvertiseCallback() {}
    if (!bluetoothAdapter.isEnabled || !bluetoothAdapter.isMultipleAdvertisementSupported) return false

    advertiser = bluetoothAdapter.bluetoothLeAdvertiser

    val settings = AdvertiseSettings.Builder()
      .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
      .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
      .setConnectable(false)
      .build()

    val data = AdvertiseData.Builder()
      .setIncludeDeviceName(true)
      .addServiceUuid(ParcelUuid(uuid)) // Battery service UUID (can be custom)
      .addManufacturerData(manufacturerId, manufacturerData)
      .build()
    
    advertiser?.startAdvertising(settings, data, advertiseCallback)
    return true
  }

  private fun stopBleAdvertising() {
    advertiser?.stopAdvertising(advertiseCallback)
    advertiseCallback = null
    advertiser = null
  }
}
