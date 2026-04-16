import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final supabase = Supabase.instance.client;

  // Controllers
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final matterController = TextEditingController();
  final assignedToController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    nameController.dispose();
    descController.dispose();
    matterController.dispose();
    assignedToController.dispose();
    super.dispose();
  }

  Future<void> saveTask() async {
    final user = supabase.auth.currentUser;

    print("Saving task...");

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    try {
      final response = await supabase.from('tasks').insert({
        'name': nameController.text.trim(),
        'description': descController.text.trim(),
        'matter': matterController.text.trim(),
        'assigned_to': assignedToController.text.trim(),
        'user_id': user.id,
        'is_completed': false,
      });

      print("INSERT RESPONSE: $response");

      if (mounted) {
        nameController.clear();
        descController.clear();
        matterController.clear();
        assignedToController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Outstanding'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: Text("Please log in"))
          : TabBarView(
        controller: _tabController,
        children: [
          buildTaskContent(false, user.id),
          buildTaskContent(true, user.id),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildTaskContent(bool isCompleted, String userId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase
          .from('tasks')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId) // 🔥 IMPORTANT FIX
          .eq('is_completed', isCompleted)
          .order('created_at'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: Checkbox(
                  value: task['is_completed'] ?? false,
                  onChanged: (val) async {
                    await supabase
                        .from('tasks')
                        .update({'is_completed': val})
                        .eq('id', task['id']);
                  },
                ),
                title: Text(
                  task['name'] ?? 'No Name',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Matter: ${task['matter'] ?? 'N/A'}\nAssigned to: ${task['assigned_to'] ?? 'N/A'}",
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment, size: 80),
          const SizedBox(height: 10),
          const Text("No tasks yet"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _showAddTaskDialog,
            child: const Text("Create Task"),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Task'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                controller: matterController,
                decoration:
                const InputDecoration(labelText: 'Related Matter'),
              ),
              TextField(
                controller: assignedToController,
                decoration:
                const InputDecoration(labelText: 'Assigned To'),
              ),
              TextField(
                controller: descController,
                decoration:
                const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await saveTask();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}