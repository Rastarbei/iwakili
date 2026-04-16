import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw; // Now resolved by 'flutter pub add pdf'
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:printing/printing.dart';

class DocumentAutomationPage extends StatefulWidget {
  const DocumentAutomationPage({super.key});

  @override
  State<DocumentAutomationPage> createState() => _DocumentAutomationPageState();
}

class _DocumentAutomationPageState extends State<DocumentAutomationPage> {
  final supabase = Supabase.instance.client;
  String? selectedMatter;
  String selectedDocType = 'Notice of Motion';
  bool _isProcessing = false;

  final List<String> _docTypes = [
    'Notice of Motion',
    'Affidavit',
    'Plaint',
    'Chamber Summons',
    'Letter of Demand'
  ];

  Future<Uint8List> _generateLegalDocument() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, text: 'REPUBLIC OF KENYA'),
            pw.Header(level: 1, text: 'IN THE HIGH COURT OF KENYA'),
            pw.SizedBox(height: 20),
            pw.Text('MATTER: $selectedMatter'),
            pw.Text('DOCUMENT: $selectedDocType'),
            pw.Divider(),
            pw.SizedBox(height: 40),
            pw.Text('TAKE NOTICE that this document has been electronically filed via i-Wakili.'),
            pw.SizedBox(height: 100),
            pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('__________________________')),
            pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Advocate for the Applicant')),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  Future<void> _fileDocument() async {
    if (selectedMatter == null) return;

    setState(() => _isProcessing = true);
    try {
      final pdfBytes = await _generateLegalDocument();
      final userId = supabase.auth.currentUser!.id;
      final fileName = '${selectedDocType.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final path = '$userId/$fileName';

      await supabase.storage.from('lfmsdocuments').uploadBinary(
        path,
        pdfBytes,
        fileOptions: const FileOptions(contentType: 'application/pdf'),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Document Filed & Saved Successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Filing Failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔥 Fixed: Changed 'app_bar' to 'appBar'
      appBar: AppBar(
        title: const Text("Automated Filing"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Matter'),
              items: ['Matter 001/2024', 'Matter 005/2023'].map((m) =>
                  DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => selectedMatter = val),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedDocType,
              decoration: const InputDecoration(labelText: 'Document Type'),
              items: _docTypes.map((type) =>
                  DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (val) => setState(() => selectedDocType = val!),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _fileDocument,
                icon: const Icon(Icons.gavel),
                label: Text(_isProcessing ? "Processing..." : "Generate & File Document"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}