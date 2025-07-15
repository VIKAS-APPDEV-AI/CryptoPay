import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  // Sample notification data
  final List<Map<String, String>> notifications = const [
    {
      'title': 'New Message',
      'message': 'You received a new message from Admin.',
      'timestamp': '2025-04-24 10:30',
    },
    {
      'title': 'App Update',
      'message': 'A new version of the app is available.',
      'timestamp': '2025-04-24 09:15',
    },
    {
      'title': 'Reminder',
      'message': 'Your meeting starts in 1 hour.',
      'timestamp': '2025-04-24 08:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'No notifications available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      notification['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8.0),
                        Text(notification['message']!),
                        const SizedBox(height: 8.0),
                        Text(
                          notification['timestamp']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Handle notification tap
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tapped: ${notification['title']}'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}