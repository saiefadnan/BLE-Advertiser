import 'package:flutter/material.dart';

class RequestPage extends StatelessWidget {
  final String contactName;

  const RequestPage({super.key, required this.contactName});

  @override
  Widget build(BuildContext context) {
    final TextEditingController requestController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Send Request to $contactName'),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'You can send a request to $contactName by filling out the form below. Make sure to include all necessary details.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            TextField(
              controller: requestController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Enter your request',
                hintText: 'Write your request here...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (requestController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Request sent to $contactName!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  requestController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a request'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                'Send Request',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            Text(
              'Note:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Requests should be clear and concise. Avoid including unnecessary information.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
