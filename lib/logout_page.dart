import 'package:flutter/material.dart';

class LogoutPage extends StatelessWidget {
  final VoidCallback onLogoutConfirmed;
  const LogoutPage({super.key, required this.onLogoutConfirmed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logout'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.blue, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to logout?',
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
                onLogoutConfirmed();
                Navigator.of(context).pop();
              },
              child: const Text('Logout'),
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
