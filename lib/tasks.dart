// TODO Implement this library.
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: TasksPage()));
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});
  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildTaskContent(),
          buildTaskContent(), // Same UI for now
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
        tooltip: 'New Task',
      ),
    );
  }

  Widget buildTaskContent() {
    bool hasTasks = false; // Set this to true when tasks exist

    return hasTasks
        ? ListView(
      children: [
    SingleChildScrollView(
        child: DataTable(
          columns:  [
            DataColumn(label: Text('Action')),
            DataColumn(label: Text('Due date')),
            DataColumn(label: Text('Name and description')),
            DataColumn(label: Text('Matter')),
            DataColumn(label: Text('Assigned by')),
            DataColumn(label: Text('Assigned to')),
          ],
          rows:  [
            DataRow(cells: [
              DataCell(Text('Draft Contract')),
              DataCell(Text('11/25/2024')),
              DataCell(Text('Prepare a draft contract for a business merger.')),
              DataCell(Text('Business Merger')),
              DataCell(Text('John Doe')),
              DataCell(Text('Jane Smith')),
            ]),
            DataRow(cells: [
              DataCell(Text('Court Filing')),
              DataCell(Text('11/28/2024')),
              DataCell(Text('Submit documents for a civil lawsuit.')),
              DataCell(Text('Civil Case #456')),
              DataCell(Text('Lisa Brown')),
              DataCell(Text('Tom Green')),
            ]),
            DataRow(cells: [
              DataCell(Text('Client Meeting')),
              DataCell(Text('11/23/2024')),
              DataCell(Text('Discuss upcoming trial details with client.')),
              DataCell(Text('Criminal Defense')),
              DataCell(Text('Emily Clark')),
              DataCell(Text('Michael Johnson')),
            ]),
            DataRow(cells: [
              DataCell(Text('Review Evidence')),
              DataCell(Text('11/24/2024')),
              DataCell(Text('Analyze discovery materials for the court case.')),
              DataCell(Text('Property Dispute')),
              DataCell(Text('Anna White')),
              DataCell(Text('Sarah Taylor')),
            ]),
            DataRow(cells: [
              DataCell(Text('Prepare Will')),
              DataCell(Text('11/30/2024')),
              DataCell(Text('Draft and finalize a client’s last will and testament.')),
              DataCell(Text('Estate Planning')),
              DataCell(Text('Chris Davis')),
              DataCell(Text('Kevin Martin')),
            ]),
            DataRow(cells: [
              DataCell(Text('Research Case Law')),
              DataCell(Text('11/26/2024')),
              DataCell(Text('Find precedents relevant to an ongoing litigation.')),
              DataCell(Text('Intellectual Property')),
              DataCell(Text('Nina Wilson')),
              DataCell(Text('Oscar Lopez')),
            ]),
          ], // Populate rows dynamically
        ),
    ),
      ],
    )
        : Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 100, color: Colors.blue),
          const SizedBox(height: 20),
          const Text('No tasks found.', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          const Text(
            'Track tasks to better manage your firm’s productivity.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        onPressed: () {
          // Show a dialog with a form
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // Form key to manage form validation
              final _formKey = GlobalKey<FormState>();
              final TextEditingController descriptionController =
              TextEditingController();
              final TextEditingController dueDateController = TextEditingController();

              return AlertDialog(
                title: Text('New Task'),
                content: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Task Description Field
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(labelText: 'Task Description'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the task description';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        // Due Date Field
                        TextFormField(
                          controller: dueDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Due Date',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              dueDateController.text =
                              '${pickedDate.month}/${pickedDate.day}/${pickedDate.year}';
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a due date';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                  ElevatedButton(
                    child: Text('Save'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Handle task saving logic here
                        final taskDescription = descriptionController.text;
                        final dueDate = dueDateController.text;

                        print('Task Saved: $taskDescription, Due: $dueDate');

                        Navigator.of(context).pop(); // Close the dialog after saving
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Text('New Task'),
      ),
        ],
      ),
    );
  }
}
