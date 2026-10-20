import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_habit_screen.dart';
import 'countries_screen.dart';
import 'habit_detail_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'personal_info_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'stored_data_screen.dart';
import 'user_data_storage.dart';

class HabitTrackerScreen extends StatefulWidget {
  final String username;

  const HabitTrackerScreen({super.key, required this.username});

  @override
  _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  Map<String, String> selectedHabitsMap = {};
  Map<String, String> completedHabitsMap = {};
  String name = '';
  bool showCompleted = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      name = prefs.getString('name') ?? widget.username;
      showCompleted = prefs.getBool('showCompletedHabits') ?? true;
      selectedHabitsMap = Map<String, String>.from(
          jsonDecode(prefs.getString('selectedHabitsMap') ?? '{}'));
      completedHabitsMap = Map<String, String>.from(
          jsonDecode(prefs.getString('completedHabitsMap') ?? '{}'));
    });
  }

  Future<void> _saveHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedHabitsMap', jsonEncode(selectedHabitsMap));
    await prefs.setString('completedHabitsMap', jsonEncode(completedHabitsMap));
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; // Add opacity if not included.
    }
    return Color(int.parse('0x$hexColor'));
  }

  Color _getHabitColor(String habit, Map<String, String> habitsMap) {
    String? colorHex = habitsMap[habit];
    if (colorHex != null) {
      try {
        return _getColorFromHex(colorHex);
      } catch (e) {
        debugPrint('Error parsing color for $habit: $e');
      }
    }
    return Colors.blue; // Default color in case of error.
  }

  /// Opens a screen, then reloads data when the user comes back.
  void _open(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) => _loadUserData());
  }

  void _openDetail(String habit, String colorHex, bool isCompleted) {
    _open(HabitDetailScreen(
      habitName: habit,
      colorHex: colorHex,
      isCompleted: isCompleted,
    ));
  }

  void _signOut(BuildContext context) {
    // Keep the saved account so the user can log back in.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  /// App logo shown in the header.
  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.track_changes, color: Colors.blue.shade700, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            _buildLogo(),
            const SizedBox(width: 10),
            const Text(
              'Habitt',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Settings menu icon
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Settings menu',
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  _open(const SettingsScreen());
                  break;
                case 'profile':
                  _open(const PersonalInfoScreen());
                  break;
                case 'notifications':
                  _open(NotificationsScreen());
                  break;
                case 'countries':
                  _open(const CountriesScreen());
                  break;
                case 'signout':
                  _signOut(context);
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
              PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                ),
              ),
              PopupMenuItem(
                value: 'notifications',
                child: ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Notifications'),
                ),
              ),
              PopupMenuItem(
                value: 'countries',
                child: ListTile(
                  leading: Icon(Icons.public),
                  title: Text('Explore Countries'),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'signout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sign Out'),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 10),
                  Text(
                    name.isNotEmpty ? 'Hi, $name' : 'Menu',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Configure Habits'),
              onTap: () {
                Navigator.pop(context);
                _open(const AddHabitScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Personal Info'),
              onTap: () {
                Navigator.pop(context);
                _open(const PersonalInfoScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                _open(const ReportsScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Explore Countries'),
              onTap: () {
                Navigator.pop(context);
                _open(const CountriesScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Stored Data'),
              onTap: () {
                Navigator.pop(context);
                _open(const StoredDataScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                _open(NotificationsScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                _open(const SettingsScreen());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () => _signOut(context),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                name.isNotEmpty ? 'Welcome, $name 👋' : 'Welcome 👋',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'To Do 📝',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          selectedHabitsMap.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Text(
                      'Use the + button to create some habits!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: selectedHabitsMap.length,
                    itemBuilder: (context, index) {
                      String habit = selectedHabitsMap.keys.elementAt(index);
                      Color habitColor =
                          _getHabitColor(habit, selectedHabitsMap);
                      return Dismissible(
                        key: Key('todo_$habit'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          setState(() {
                            String color = selectedHabitsMap.remove(habit)!;
                            completedHabitsMap[habit] = color;
                          });
                          _saveHabits();
                          saveUserAction('Completed habit: $habit');
                        },
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Swipe to Complete',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.check, color: Colors.white),
                            ],
                          ),
                        ),
                        child: _buildHabitCard(
                            habit, habitColor, selectedHabitsMap[habit]!),
                      );
                    },
                  ),
                ),
          if (showCompleted) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Done ✅🎉',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            completedHabitsMap.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Swipe left on a habit to mark it as done.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: completedHabitsMap.length,
                      itemBuilder: (context, index) {
                        String habit =
                            completedHabitsMap.keys.elementAt(index);
                        Color habitColor =
                            _getHabitColor(habit, completedHabitsMap);
                        return Dismissible(
                          key: Key('done_$habit'),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (direction) {
                            setState(() {
                              String color =
                                  completedHabitsMap.remove(habit)!;
                              selectedHabitsMap[habit] = color;
                            });
                            _saveHabits();
                            saveUserAction('Undid habit: $habit');
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: const Row(
                              children: [
                                Icon(Icons.undo, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'Swipe to Undo',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          child: _buildHabitCard(habit, habitColor,
                              completedHabitsMap[habit]!,
                              isCompleted: true),
                        );
                      },
                    ),
                  ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _open(const AddHabitScreen()),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        tooltip: 'Add Habits',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitCard(String title, Color color, String colorHex,
      {bool isCompleted = false}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: color,
      child: SizedBox(
        height: 60,
        child: ListTile(
          onTap: () => _openDetail(title, colorHex, isCompleted),
          title: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCompleted)
                const Icon(Icons.check_circle, color: Colors.white, size: 26),
              // Navigation icon to the detail screen
              IconButton(
                tooltip: 'View details',
                icon: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 20),
                onPressed: () => _openDetail(title, colorHex, isCompleted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
