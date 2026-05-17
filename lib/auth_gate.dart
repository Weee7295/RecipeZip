import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider; 
import 'package:firebase_ui_auth/firebase_ui_auth.dart';                  
import 'package:flutter/material.dart';
import 'package:recipe_layout/main.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'; 


class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(                                     
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(clientId: clientId),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Icon(Icons.lock, size: 100),
                ),
              );
            },
            subtitleBuilder: (context, action) {                     // Add from here...
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to FlutterFire, please sign in!')
                    : const Text('Welcome to Flutterfire, please sign up!'),
              );
            },
            footerBuilder: (context, action) {                       // Add from here...
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {                   // Add from here...
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Icon(Icons.person, size: 80),
                ),
              );                                                     
            }, 
          );
        }

        return const MyApp();
      },
    );                                                               
  }
}