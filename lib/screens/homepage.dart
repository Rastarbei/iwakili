import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:i_wakili/screens/matters.dart';
import 'package:i_wakili/tasks.dart';
import 'package:i_wakili/screens/contacts.dart';
import 'package:i_wakili/screens/uploaddocs.dart';
import 'package:i_wakili/screens/document_automation.dart'; // 🔥 Import your new filing page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final supabase = Supabase.instance.client;

  final List<Widget> _pages = [
    const CalendarPage(),
    const MattersPage(),
    const TasksPage(),
    const ContactsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _addNewTaskDirectly(String name, String desc, String matter, String assigned) async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please sign in to add tasks")),
        );
        return;
      }

      await supabase.from('tasks').insert({
        'name': name,
        'description': desc,
        'matter': matter,
        'assigned_to': assigned,
        'user_id': userId,
        'is_completed': false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task created successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showQuickTaskDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final matterController = TextEditingController();
    final assignedController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Task Name')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: matterController, decoration: const InputDecoration(labelText: 'Related Matter')),
              TextField(controller: assignedController, decoration: const InputDecoration(labelText: 'Assign To')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _addNewTaskDirectly(
                  nameController.text,
                  descController.text,
                  matterController.text,
                  assignedController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('i-Wakili'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          // 🔥 NEW: Automated Filing Button
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            tooltip: 'Automated Filing',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DocumentAutomationPage()),
              );
            },
          ),
          // Document Upload Button
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'View & Upload Documents',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadDocsPage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickTaskDialog(context),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.gavel), label: 'Matters'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Contacts'),
        ],
      ),
    );
  }
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Column(
      children: [
        TableCalendar(
          focusedDay: DateTime.now(),
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
          ),
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.list_alt, color: Colors.purple),
              SizedBox(width: 8),
              Text("Today's Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('tasks').stream(primaryKey: ['id']).order('created_at'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = snapshot.data ?? [];

              if (tasks.isEmpty) {
                return const Center(child: Text("No tasks found for today."));
              }

              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      title: Text(
                        task['name'] ?? 'Untitled',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: task['is_completed'] == true ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(task['description'] ?? 'No description'),
                      trailing: task['is_completed'] == true
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.pending_actions, color: Colors.orange),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}