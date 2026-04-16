import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MattersPage extends StatefulWidget {
  const MattersPage({super.key});

  @override
  _MattersPageState createState() => _MattersPageState();
}

class _MattersPageState extends State<MattersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final matterController = TextEditingController();
  final clientController = TextEditingController();
  final practiceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    clientController.dispose();
    matterController.dispose();
    practiceController.dispose();
    super.dispose();
  }

  Future<void> saveMatter() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: You must be logged in')),
      );
      return;
    }

    try {
      await supabase.from('matters').insert({
        'client': clientController.text.trim(),
        'matter': matterController.text.trim(),
        'practicearea': practiceController.text.trim(),
        'user_id': user.id,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Matter saved successfully!'), backgroundColor: Colors.green),
        );
        clientController.clear();
        matterController.clear();
        practiceController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matters'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Open'),
            Tab(text: 'Pending'),
            Tab(text: 'Closed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildMattersTable(), // 'All' tab
          const Center(child: Text("Open Matters")),
          const Center(child: Text("Pending Matters")),
          const Center(child: Text("Closed Matters")),
        ],
      ),
    );
  }

  Widget buildMattersTable() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      // 🔥 This listens to Supabase Realtime
      stream: Supabase.instance.client
          .from('matters')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final matters = snapshot.data ?? [];

        // If no data, show the placeholder UI
        if (matters.isEmpty) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.work_outline, size: 100, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No matters found.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Stay organised by keeping every case detail in one place.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              buildBottomActions(),
            ],
          );
        }

        // If data exists, show the list
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: matters.length,
                itemBuilder: (context, index) {
                  final item = matters[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.gavel)),
                      title: Text(item['matter'] ?? 'No Title'),
                      subtitle: Text("Client: ${item['client']} | Area: ${item['practicearea']}"),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              ),
            ),
            buildBottomActions(),
          ],
        );
      },
    );
  }

  Widget buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  final localFormKey = GlobalKey<FormState>();
                  return AlertDialog(
                    title: const Text('New Matter'),
                    content: SingleChildScrollView(
                      child: Form(
                        key: localFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: clientController,
                              decoration: const InputDecoration(labelText: 'Client Name'),
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                            ),
                            TextFormField(
                              controller: practiceController,
                              decoration: const InputDecoration(labelText: 'Practice Area'),
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                            ),
                            TextFormField(
                              controller: matterController,
                              decoration: const InputDecoration(labelText: 'Matter'),
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () async {
                          if (localFormKey.currentState!.validate()) {
                            await saveMatter();
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('New Matter'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {},
            child: const Text('Matters Template'),
          ),
        ],
      ),
    );
  }
}