import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


// ========================================================================
// PROFILE / SETTINGS SCREEN
// ========================================================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5A2B),
        foregroundColor: Colors.white,
        title: const Text('My Kitchen Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 100, color: Color(0xFF5D4037)),
            const SizedBox(height: 20),
            
            // Placeholder for your Vegetarian Toggle
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF5D4037), width: 3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Vegetarian Recipes Only', style: TextStyle(fontWeight: FontWeight.bold)),
                  Switch(
                    value: false, // You can link this to state later
                    onChanged: (val) {},
                    activeColor: const Color(0xFF4CAF50),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Safe Log Out Logic
            FilledButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(color: Color(0xFF5D4037), width: 3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}