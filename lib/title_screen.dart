import 'package:flutter/material.dart';
import 'package:recipe_layout/auth_gate.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-screen Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/titleMobile.png',
              fit: BoxFit.cover, // Ensures the image covers the whole screen
            ),
          ),
          
          // 2. Optional: A slight dark gradient overlay so the white text pops more
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),

          // 3. The Content (Title and Button)
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 6),
                
                  
                  const Spacer(flex: 1),
                  
                  // The Enter Button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the AuthGate when pressed
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => const AuthGate(
                            clientId: '709918116887-r25furm4fc5gbk7r5juhdtq7ir7od0gn.apps.googleusercontent.com'
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 142, 63, 41), 
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      // Chunky, square borders to match the pixel-art vibe
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0), 
                        side: const BorderSide(
                          color: Color(0xFF5D4037), // Dark wood brown border
                          width: 4,
                        ),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      'ENTER',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}