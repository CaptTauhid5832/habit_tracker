import 'package:flutter/material.dart';
import 'user_profile_storage.dart';
import 'user_data_storage.dart';

// Screen that shows stored data using conditional rendering
class StoredDataScreen extends StatefulWidget {
  const StoredDataScreen({super.key});

  @override
  State<StoredDataScreen> createState() => _StoredDataScreenState();
}

class _StoredDataScreenState extends State<StoredDataScreen> {
  Map<String, dynamic>? _profile;
  List<String> _actions = [];
  List<String> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Retrieve all stored data
  Future<void> _loadData() async {
    final profile = await getUserProfile();
    final actions = await getUserActions();
    final notifications = await getNotifications();
    setState(() {
      _profile = profile;
      _actions = actions;
      _notifications = notifications;
      _isLoading = false;
    });
  }

  // Save sample data so you can see it appear
  Future<void> _addSampleData() async {
    await saveUserProfile({'username': 'HabitUser', 'email': 'user@example.com'});
    await saveUserAction('Completed habit: Drink water');
    await saveNotification('Reminder: Time for your daily walk');
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Stored Data')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleData,
        child: const Icon(Icons.add),
      ),
      // Conditional rendering: loading spinner OR the data
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // Show profile if saved, otherwise a message
                _profile != null
                    ? Text('Name: ${_profile!['username']}\nEmail: ${_profile!['email']}')
                    : const Text('No profile saved yet.'),
                const SizedBox(height: 20),

                const Text('Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // Show actions if any, otherwise a message
                if (_actions.isEmpty)
                  const Text('No actions yet.')
                else
                  ..._actions.map((a) => ListTile(title: Text(a))),
                const SizedBox(height: 20),

                const Text('Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // Show notifications if any, otherwise a message
                if (_notifications.isEmpty)
                  const Text('No notifications yet.')
                else
                  ..._notifications.map((n) => ListTile(title: Text(n))),
              ],
            ),
    );
  }
}
