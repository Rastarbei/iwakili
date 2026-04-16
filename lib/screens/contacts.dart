import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  int selectedTabIndex = 0; // 0 for All, 1 for People, 2 for Companies
  final supabase = Supabase.instance.client;

  // Stream to fetch contacts based on the selected tab
  Stream<List<Map<String, dynamic>>> _getContactsStream() {
    var query = supabase.from('contacts').stream(primaryKey: ['id']);

    // Filtering logic (Note: Supabase stream filtering is limited,
    // for complex filters use a FutureBuilder or logic within the StreamBuilder)
    return query.order('created_at', ascending: false);
  }

  Future<void> _saveContact({
    required String name,
    required String phone,
    required String email,
    required String address,
    required String type, // 'person' or 'company'
  }) async {
    try {
      await supabase.from('contacts').insert({
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'type': type,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving contact: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                _buildTab('All', 0),
                _buildTab('People', 1),
                _buildTab('Companies', 2),
              ],
            ),
          ),

          // Search & Filters (UI only for now)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Filter by keyword',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Data Display
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getContactsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allContacts = snapshot.data ?? [];

                // Filter data locally based on tab
                final filteredContacts = allContacts.where((contact) {
                  if (selectedTabIndex == 1) return contact['type'] == 'person';
                  if (selectedTabIndex == 2) return contact['type'] == 'company';
                  return true;
                }).toList();

                if (filteredContacts.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return ListTile(
                      leading: Icon(
                        contact['type'] == 'person' ? Icons.person : Icons.business,
                        color: Colors.blue,
                      ),
                      title: Text(contact['name'] ?? 'No Name'),
                      subtitle: Text(contact['email'] ?? ''),
                      trailing: Text(contact['phone'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _showContactDialog(context, 'person'),
                  child: const Text('New Person'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showContactDialog(context, 'company'),
                  child: const Text('New Company'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No contacts found.', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selectedTabIndex == index ? Colors.blue : Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            label,
            style: TextStyle(color: selectedTabIndex == index ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context, String type) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == 'person' ? 'New Person' : 'New Company'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: type == 'person' ? 'Full Name' : 'Company Name')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _saveContact(
                name: nameController.text,
                phone: phoneController.text,
                email: emailController.text,
                address: addressController.text,
                type: type,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}