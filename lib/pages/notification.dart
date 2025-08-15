import 'package:ble/models/ble_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<Map<String, dynamic>> notifications = [
    {'message': 'Your order has been shipped.', 'hasButtons': true},
    {'message': 'Your package is out for delivery.', 'hasButtons': true},
    {'message': 'Your subscription has been renewed.', 'hasButtons': false},
    {'message': 'New updates are available.', 'hasButtons': false},
    {'message': 'Your payment was successful.', 'hasButtons': true},
  ];
  static const platform = MethodChannel('com.example.ble/advertiser');
  final String uuidString = "0000180F-0000-1000-8000-00805f9b34fb";
  final manufacturerId = 0x1234; // example 2-byte manufacturer ID
  final manufacturerData = [1, 2, 3, 4]; // your custom data bytes
  late WebSocketChannel channel;
  final List<Map<String, String>> chatMessages = []; // Stores chat messages
  final List<String> commands = [
    'Deliver',
    'Meet me',
    'Tell me a joke',
    'Goodbye',
  ];

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
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Advertising started: $result')));
      } catch (e) {
        setState(() => bleservice.status = "Error: $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting advertising: $e')),
        );
      }
    } else {
      setState(() => bleservice.status = "Permission denied");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied for advertising')),
      );
    }
  }

  Future<void> stopAdvertising() async {
    try {
      final String result = await platform.invokeMethod('stopAdvertising');
      setState(() {
        bleservice.started = false;
        bleservice.status = result;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Advertising stopped: $result')));
    } catch (e) {
      setState(() => bleservice.status = "Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error stopping advertising: $e')));
    }
  }

  void _handleAccept(String notification, int index) {
    startAdvertising();
    setState(() {
      notifications[index]['hasButtons'] = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Accepted: $notification'),
        backgroundColor: Colors.green,
        // behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleReject(String notification, int index) {
    stopAdvertising();
    setState(() {
      notifications[index]['hasButtons'] = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rejected: $notification'),
        backgroundColor: Colors.red,
        // behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications, color: Colors.deepOrange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notification['message'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (notification['hasButtons']) ...[
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                _handleAccept(notification['message'], index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Accept'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                _handleReject(notification['message'], index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Reject'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
