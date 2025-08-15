import 'package:ble/models/ble_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class BleFunctions extends StatefulWidget {
  const BleFunctions({super.key});

  @override
  _BleFunctionsState createState() => _BleFunctionsState();
}

class _BleFunctionsState extends State<BleFunctions> {
  static const platform = MethodChannel('com.example.ble/advertiser');
  final String uuidString = "0000180F-0000-1000-8000-00805f9b34fb";
  final manufacturerId = 0x1234; // example 2-byte manufacturer ID
  final manufacturerData = [1, 2, 3, 4]; // your custom data bytes
  Future<void> startAdvertising() async {
    if (await Permission.bluetoothAdvertise.request().isGranted) {
      try {
        final String result = await platform.invokeMethod('startAdvertising', {
          "uuid": uuidString,
          "manufacturerId": manufacturerId,
          "manufacturerData": manufacturerData,
        });
        setState(() {
          bleservice.status = result;
          bleservice.started = true;
        });
      } catch (e) {
        setState(() => bleservice.status = "Error: $e");
      }
    } else {
      setState(() => bleservice.status = "Permission denied");
    }
  }

  Future<void> stopAdvertising() async {
    try {
      final String result = await platform.invokeMethod('stopAdvertising');
      setState(() {
        bleservice.started = false;
        bleservice.status = result;
      });
    } catch (e) {
      setState(() => bleservice.status = "Error: \$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BLE Advertiser')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(bleservice.status),
            ElevatedButton(
              onPressed: bleservice.started ? null : startAdvertising,
              child: Text('Start Advertising'),
            ),
            ElevatedButton(
              onPressed: stopAdvertising,
              child: Text('Stop Advertising'),
            ),
          ],
        ),
      ),
    );
  }
}
