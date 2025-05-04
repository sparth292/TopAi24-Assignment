import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteDataPage extends StatefulWidget {
  final String email;
  final VoidCallback onDeleteConfirmed;
  const DeleteDataPage({super.key, required this.email, required this.onDeleteConfirmed});

  @override
  State<DeleteDataPage> createState() => _DeleteDataPageState();
}

class _DeleteDataPageState extends State<DeleteDataPage> {
  String? notes;
  String? createdAt;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

 List<Map<String, dynamic>> userRows = [];

Future<void> _fetchUserData() async {
  setState(() { _loading = true; _error = null; });
  try {
    final response = await Supabase.instance.client
    .from('users')
    .select('email, notes, createdAt')
    .eq('email', widget.email);

    if (response != null && response is List) {
      setState(() {
        userRows = List<Map<String, dynamic>>.from(response);
      });
    } else {
      setState(() {
        userRows = [];
      });
    }
  } catch (e) {
    setState(() { _error = 'Failed to fetch data: $e'; });
  } finally {
    setState(() { _loading = false; });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Data'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: _loading
            ? const CircularProgressIndicator(color: Colors.blue)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_forever, color: Colors.blue, size: 60),
                  const SizedBox(height: 16),
                  Text('Email: ${widget.email}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  // Show all cards for all user rows
                  if (userRows.isNotEmpty)
                    ...userRows.map((row) => Card(
                      color: Colors.blue.withOpacity(0.08),
                      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notes: ${row['notes']}', style: const TextStyle(color: Colors.blue)),
                            const SizedBox(height: 8),
                            Text('Created At: ${row['createdAt']}', style: const TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ),
                    )),
                  if (userRows.isEmpty && _error == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No data right now.',
                        style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Are you sure you want to delete all your data? This action cannot be undone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      widget.onDeleteConfirmed();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete Data'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
      ),
    );
  }
}
