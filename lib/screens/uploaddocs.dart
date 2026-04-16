import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadDocsPage extends StatefulWidget {
  const UploadDocsPage({super.key});

  @override
  State<UploadDocsPage> createState() => _UploadDocsPageState();
}

class _UploadDocsPageState extends State<UploadDocsPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isUploading = false;
  List<FileObject> _files = [];

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  // 🔥 1. Fetch existing files from Supabase Storage
  Future<void> _fetchFiles() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Lists files in the user's specific folder
      final List<FileObject> objects = await supabase.storage
          .from('lfmsdocuments')
          .list(path: userId);

      setState(() {
        _files = objects;
      });
    } catch (e) {
      debugPrint('Error fetching files: $e');
    }
  }

  // 🔥 2. Pick and Upload Logic
  Future<void> _pickAndUpload() async {
    try {
      // Pick the file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
      );

      if (result == null || result.files.single.path == null) return;

      setState(() => _isUploading = true);

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final userId = supabase.auth.currentUser!.id;

      // Path format: userId/filename (matches our RLS policy)
      final path = '$userId/$fileName';

      await supabase.storage.from('lfmsdocuments').upload(
        path,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload Successful!")),
        );
      }

      _fetchFiles(); // Refresh the list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Documents"),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          if (_isUploading) const LinearProgressIndicator(color: Colors.greenAccent),

          Expanded(
            child: _files.isEmpty
                ? const Center(child: Text("No documents uploaded yet."))
                : ListView.builder(
              itemCount: _files.length,
              itemBuilder: (context, index) {
                final file = _files[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.description, color: Colors.purple),
                    title: Text(file.name),
                    subtitle: Text("Size: ${(file.metadata?['size'] / 1024).toStringAsFixed(2)} KB"),
                    trailing: IconButton(
                      icon: const Icon(Icons.download, color: Colors.blue),
                      onPressed: () {
                        // Handle download/view logic here
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickAndUpload,
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload New Document", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}