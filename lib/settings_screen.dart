import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notifications_screen.dart';
import 'personal_info_screen.dart';
import 'stored_data_screen.dart';

/// App settings, saved to local storage.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _showCompleted = true;
  bool _confirmBeforeDelete = true;
  String _reminderTime = 'Morning';
  String _email = '';

  final List<String> _reminderOptions = ['Morning', 'Afternoon', 'Evening'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
      _showCompleted = prefs.getBool('showCompletedHabits') ?? true;
      _confirmBeforeDelete = prefs.getBool('confirmBeforeDelete') ?? true;
      final saved = prefs.getString('reminderTime') ?? 'Morning';
      _reminderTime = _reminderOptions.contains(saved) ? saved : 'Morning';
      _email = prefs.getString('email') ?? '';
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _clearCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('completedHabitsMap', '{}');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Completed habits cleared')),
    );
  }

  Future<void> _resetHabits() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all habits?'),
        content: const Text(
            'This removes all your habits. Your account stays signed in.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedHabitsMap', '{}');
    await prefs.setString('completedHabitsMap', '{}');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All habits have been reset')),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _sectionTitle('ACCOUNT'),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(_email.isNotEmpty ? _email : 'Not set'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Personal Info'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PersonalInfoScreen()),
            ),
          ),
          const Divider(),
          _sectionTitle('NOTIFICATIONS'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text('Enable notifications'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveBool('notificationsEnabled', value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Daily reminder time'),
            trailing: DropdownButton<String>(
              value: _reminderTime,
              underline: const SizedBox(),
              items: _reminderOptions
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: _notificationsEnabled
                  ? (value) {
                      if (value == null) return;
                      setState(() => _reminderTime = value);
                      _saveString('reminderTime', value);
                    }
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Notification preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NotificationsScreen()),
            ).then((_) => _loadSettings()),
          ),
          const Divider(),
          _sectionTitle('HABITS'),
          SwitchListTile(
            secondary: const Icon(Icons.done_all),
            title: const Text('Show completed habits'),
            value: _showCompleted,
            onChanged: (value) {
              setState(() => _showCompleted = value);
              _saveBool('showCompletedHabits', value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.warning_amber),
            title: const Text('Confirm before deleting'),
            value: _confirmBeforeDelete,
            onChanged: (value) {
              setState(() => _confirmBeforeDelete = value);
              _saveBool('confirmBeforeDelete', value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: const Text('Clear completed habits'),
            onTap: _clearCompleted,
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt, color: Colors.red),
            title: const Text('Reset all habits',
                style: TextStyle(color: Colors.red)),
            onTap: _resetHabits,
          ),
          const Divider(),
          _sectionTitle('DATA'),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('View stored data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const StoredDataScreen()),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('App version'),
            trailing: Text('1.0.0'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
