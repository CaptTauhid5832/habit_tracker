import 'package:shared_preferences/shared_preferences.dart';

// ---------------- USER ACTIONS ----------------

// Save one user action (e.g. "Completed habit: Drink water")
Future<void> saveUserAction(String action) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> actions = prefs.getStringList('userActions') ?? [];
  actions.add(action);
  await prefs.setStringList('userActions', actions);
}

// Retrieve all saved user actions
Future<List<String>> getUserActions() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('userActions') ?? [];
}

// ---------------- NOTIFICATIONS ----------------

// Save one notification (e.g. "Reminder: Go for a walk")
Future<void> saveNotification(String notification) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> notifications = prefs.getStringList('notifications') ?? [];
  notifications.add(notification);
  await prefs.setStringList('notifications', notifications);
}

// Retrieve all saved notifications
Future<List<String>> getNotifications() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('notifications') ?? [];
}
