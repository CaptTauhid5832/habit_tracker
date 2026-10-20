import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_data_storage.dart';

/// Shows the data saved in local storage (SharedPreferences).
class StoredDataScreen extends StatefulWidget {
  const StoredDataScreen({super.key});

  @override
  State<StoredDataScreen> createState() => _StoredDataScreenState();
}

class _StoredDataScreenState extends State<StoredDataScreen> {
  Map<String, String> _account = {};
  Map<String, String> _todo = {};
  Map<String, String> _done = {};
  Map<String, String> _settings = {};
  List<String> _actions = [];
  List<String> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final actions = await getUserActions();
    final notifications = await getNotifications();

    setState(() {
      _account = {
        'Name': prefs.getString('name') ?? '-',
        'Username': prefs.getString('username') ?? '-',
        'Email': prefs.getString('email') ?? '-',
        'Age': (prefs.getDouble('age') ?? 0).round().toString(),
        'Country': prefs.getString('country') ?? '-',
      };
      _todo = Map<String, String>.from(
          jsonDecode(prefs.getString('selectedHabitsMap') ?? '{}'));
      _done = Map<String, String>.from(
          jsonDecode(prefs.getString('completedHabitsMap') ?? '{}'));
      _settings = {
        'Notifications':
            (prefs.getBool('notificationsEnabled') ?? false) ? 'On' : 'Off',
        'Reminder time': prefs.getString('reminderTime') ?? 'Morning',
        'Show completed':
            (prefs.getBool('showCompletedHabits') ?? true) ? 'Yes' : 'No',
      };
      _actions = actions.reversed.toList();
      _notifications = notifications.reversed.toList();
      _isLoading = false;
    });
  }

  Widget _header(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _keyValueCard(Map<String, String> data) {
    return Card(
      child: Column(
        children: data.entries
            .map((e) => ListTile(
                  dense: true,
                  title: Text(e.key),
                  trailing: Text(e.value,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ))
            .toList(),
      ),
    );
  }

  Widget _listCard(List<String> items, String emptyText) {
    return Card(
      child: items.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Text(emptyText,
                  style: const TextStyle(color: Colors.grey)),
            )
          : Column(
              children: items
                  .map((i) => ListTile(dense: true, title: Text(i)))
                  .toList(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        title: const Text('Stored Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Everything below is read from local storage '
                  '(SharedPreferences) and stays after the app is closed.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                _header('Account', Icons.person),
                _keyValueCard(_account),
                _header('Habits to do (${_todo.length})', Icons.list),
                _listCard(_todo.keys.toList(), 'No habits saved yet.'),
                _header('Completed habits (${_done.length})', Icons.done_all),
                _listCard(_done.keys.toList(), 'No completed habits yet.'),
                _header('Settings', Icons.settings),
                _keyValueCard(_settings),
                _header('Recent actions', Icons.history),
                _listCard(_actions.take(10).toList(), 'No actions yet.'),
                _header('Notifications sent', Icons.notifications),
                _listCard(
                    _notifications.take(10).toList(), 'No notifications yet.'),
              ],
            ),
    );
  }
}
