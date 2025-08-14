import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('com.example.ble/advertiser');
  String status = "Not advertising";
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
        setState(() => status = result);
      } catch (e) {
        setState(() => status = "Error: $e");
      }
    } else {
      setState(() => status = "Permission denied");
    }
  }

  Future<void> stopAdvertising() async {
    try {
      final String result = await platform.invokeMethod('stopAdvertising');
      setState(() => status = result);
    } catch (e) {
      setState(() => status = "Error: \$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('BLE Advertiser')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(status),
              ElevatedButton(
                onPressed: startAdvertising,
                child: Text('Start Advertising'),
              ),
              ElevatedButton(
                onPressed: stopAdvertising,
                child: Text('Stop Advertising'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
