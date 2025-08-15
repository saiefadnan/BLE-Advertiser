import 'package:ble/models/ble_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BotPage extends StatefulWidget {
  const BotPage({super.key});

  @override
  State<BotPage> createState() => _BotPageState();
}

class _BotPageState extends State<BotPage> {
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

  Future<void> sendCommand(String command) async {
    channel.sink.add(command);
    print('Sent: $command');
  }

  void handleCommand(String command) {
    String botResponse;

    switch (command) {
      case 'Deliver':
        sendCommand('deliver');
        stopAdvertising();
        botResponse = 'On my way!';
        break;
      case 'Meet me':
        startAdvertising();
        sendCommand('meet');
        botResponse = 'Sure, wait till i arrive';
        break;
      case 'Tell me a joke':
        botResponse =
            'Why don’t skeletons fight each other? They don’t have the guts!';
        break;
      case 'Goodbye':
        botResponse = 'Goodbye! Have a great day!';
        break;
      default:
        botResponse = 'I don’t understand that command.';
    }

    setState(() {
      chatMessages.add({'sender': 'You', 'message': command});
      chatMessages.add({'sender': 'Bot', 'message': botResponse});
    });
  }

  @override
  void initState() {
    super.initState();
    // Replace with your ESP32 IP
    channel = WebSocketChannel.connect(Uri.parse('ws://192.168.1.100:81'));
    channel.stream.listen(
      (message) {
        setState(() {
          chatMessages.add({'sender': 'Bot', 'message': message});
        });
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket closed');
      },
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bot Chat'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final chat = chatMessages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Align(
                    alignment: chat['sender'] == 'You'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: chat['sender'] == 'You'
                            ? Colors.deepOrange.withOpacity(0.8)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${chat['sender']}: ${chat['message']}',
                        style: TextStyle(
                          color: chat['sender'] == 'You'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Choose a command',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 16,
                  children: commands
                      .where(
                        (command) =>
                            !(bleservice.started == true &&
                                command == "Meet me"),
                      )
                      .map((command) {
                        return ElevatedButton(
                          onPressed: () => handleCommand(command),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                          ),
                          child: Text(
                            command,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      })
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
