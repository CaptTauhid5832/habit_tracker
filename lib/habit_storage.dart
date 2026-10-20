// lib/habit_storage.dart
// Saves and retrieves habit data using local storage (shared_preferences).
//
// Add the package first:
//   flutter pub add shared_preferences

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HabitStorage {
  static const String _habitsKey = 'habits';

  /// Save the full list of habits.
  /// Each habit is a Map, e.g. {'name': 'Drink water', 'color': 0xFF4CAF50, 'completed': false}
  static Future<void> saveHabits(List<Map<String, dynamic>> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(habits);
    await prefs.setString(_habitsKey, encoded);
  }

  /// Load the saved list of habits. Returns an empty list if nothing is saved yet.
  static Future<List<Map<String, dynamic>>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_habitsKey);
    if (encoded == null) return [];
    final List<dynamic> decoded = jsonDecode(encoded);
    return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  /// Add one habit and save the updated list.
  static Future<void> addHabit(Map<String, dynamic> habit) async {
    final habits = await loadHabits();
    habits.add(habit);
    await saveHabits(habits);
  }

  /// Remove the habit at the given index and save the updated list.
  static Future<void> removeHabit(int index) async {
    final habits = await loadHabits();
    if (index >= 0 && index < habits.length) {
      habits.removeAt(index);
      await saveHabits(habits);
    }
  }

  /// Clear all saved habits.
  static Future<void> clearHabits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_habitsKey);
  }
}

/*
Example usage inside a StatefulWidget's State class:

List<Map<String, dynamic>> _habits = [];

@override
void initState() {
  super.initState();
  _loadHabits();
}

Future<void> _loadHabits() async {
  final saved = await HabitStorage.loadHabits();
  setState(() => _habits = saved);
}

Future<void> _addHabit(String name, Color color) async {
  final habit = {'name': name, 'color': color.value, 'completed': false};
  await HabitStorage.addHabit(habit);
  _loadHabits();
}

// To turn the saved int back into a Color: Color(habit['color'])
*/
