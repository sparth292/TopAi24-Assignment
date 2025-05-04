import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'delete_data_page.dart';
import 'logout_page.dart';

class HomeScreen extends StatefulWidget {
  final firebase_auth.User user;
  final VoidCallback onLogout;
  final VoidCallback onDelete;

  const HomeScreen({super.key, required this.user, required this.onLogout, required this.onDelete});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  int? _age;
  final _notesController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // _loadUserData(); // Removed auto-loading at start as per user request
  }

  Future<void> _loadUserData() async {
    setState(() => _loading = true);
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('email', widget.user.email ?? '')
          .maybeSingle();
      if (response != null) {
        _addressController.text = response['address'] ?? '';
        _phoneController.text = response['phone_number'] ?? '';
        _age = response['age'];
        _notesController.text = response['notes'] ?? '';
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'email': widget.user.email,
      'address': _addressController.text,
      'phone_number': _phoneController.text,
      'age': _age,
      'notes': _notesController.text,
    };
    print('Saving to Supabase: $data');
    try {
      final response = await Supabase.instance.client.from('users').upsert(data);
      print('Supabase response: $response');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data saved!')));
    } catch (e) {
      print('Supabase error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Supabase error: $e')));
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.user.photoURL ?? ''),
                    radius: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.user.displayName ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(widget.user.email ?? '', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.blue),
              title: const Text('Delete Data', style: TextStyle(color: Colors.blue)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DeleteDataPage(email: widget.user.email ?? '', onDeleteConfirmed: widget.onDelete),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.blue),
              title: const Text('Logout', style: TextStyle(color: Colors.blue)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LogoutPage(onLogoutConfirmed: widget.onLogout),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.user.photoURL ?? ''),
                      radius: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(widget.user.displayName ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    Text(widget.user.email ?? '', style: const TextStyle(fontSize: 16, color: Colors.blue)),
                    const Divider(height: 32, color: Colors.blue),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address', labelStyle: TextStyle(color: Colors.blue)),
                      validator: (v) => v == null || v.isEmpty ? 'Address required' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number', labelStyle: TextStyle(color: Colors.blue)),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.isEmpty ? 'Phone required' : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<int>(
                      value: _age,
                      decoration: const InputDecoration(labelText: 'Age', labelStyle: TextStyle(color: Colors.blue)),
                      items: List.generate(83, (i) => i + 18)
                          .map((age) => DropdownMenuItem(value: age, child: Text(age.toString(), style: const TextStyle(color: Colors.blue))))
                          .toList(),
                      onChanged: (v) => setState(() => _age = v),
                      validator: (v) => v == null ? 'Select age' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes', labelStyle: TextStyle(color: Colors.blue)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
