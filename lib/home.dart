import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(width: 250, child: Icon(Icons.person, size: 80)),
            Text('Welcome!', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: () async {
                // 1. Tell Firebase to log the user out
                await FirebaseAuth.instance.signOut();
                
                // 2. Check if the screen is still active, then pop it away
                if (context.mounted) {
                  Navigator.pop(context); 
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}