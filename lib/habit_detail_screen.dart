import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shows the full details of one habit.
class HabitDetailScreen extends StatefulWidget {
  final String habitName;
  final String colorHex;
  final bool isCompleted;

  const HabitDetailScreen({
    super.key,
    required this.habitName,
    required this.colorHex,
    required this.isCompleted,
  });

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late bool _isCompleted;
  bool _hasReminder = false;
  List<String> _reminderTimes = [];

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.isCompleted;
    _loadReminderInfo();
  }

  Future<void> _loadReminderInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final habits = prefs.getStringList('notificationHabits') ?? [];
    final times = prefs.getStringList('notificationTimes') ?? [];
    setState(() {
      _hasReminder = habits.contains(widget.habitName);
      _reminderTimes = times;
    });
  }

  Color _colorFromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    try {
      return Color(int.parse('0x$hex'));
    } catch (_) {
      return Colors.blue;
    }
  }

  Future<void> _toggleCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final todo = Map<String, String>.from(
        jsonDecode(prefs.getString('selectedHabitsMap') ?? '{}'));
    final done = Map<String, String>.from(
        jsonDecode(prefs.getString('completedHabitsMap') ?? '{}'));

    if (_isCompleted) {
      final color = done.remove(widget.habitName) ?? widget.colorHex;
      todo[widget.habitName] = color;
    } else {
      final color = todo.remove(widget.habitName) ?? widget.colorHex;
      done[widget.habitName] = color;
    }

    await prefs.setString('selectedHabitsMap', jsonEncode(todo));
    await prefs.setString('completedHabitsMap', jsonEncode(done));
    setState(() => _isCompleted = !_isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFromHex(widget.colorHex);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        title: const Text('Habit Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  _isCompleted ? Icons.check_circle : Icons.flag,
                  color: Colors.white,
                  size: 56,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.habitName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _infoTile(Icons.label, 'Habit name', widget.habitName),
          _infoTile(
            _isCompleted ? Icons.check_circle : Icons.pending_actions,
            'Status',
            _isCompleted ? 'Done today' : 'To do',
          ),
          ListTile(
            leading: Icon(Icons.palette, color: Colors.blue.shade700),
            title: const Text('Color'),
            trailing: CircleAvatar(backgroundColor: color, radius: 14),
          ),
          _infoTile(
            Icons.notifications,
            'Reminder',
            _hasReminder
                ? (_reminderTimes.isEmpty
                    ? 'On'
                    : 'On (${_reminderTimes.join(', ')})')
                : 'Off',
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _toggleCompleted,
            icon: Icon(_isCompleted ? Icons.undo : Icons.check),
            label: Text(_isCompleted ? 'Mark as To Do' : 'Mark as Done'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
