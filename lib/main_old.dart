/*import 'package:flutter/material.dart';
import 'views/mobile_layout.dart';
import 'views/tablet_layout.dart';
import 'views/desktop_layout.dart';
import 'helpers/device_helper.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

/*
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row (
            children: [
              Expanded (
                child: Center(
                  child : Image.asset(
                    'assets/images/pinkcake.jpg', 
                    fit: BoxFit.cover,
                    height: double.infinity, // Tells it to go as tall as possible
                    width: double.infinity,
                  ), 
                ),
              ),
              const Expanded(
                child: Padding(padding: EdgeInsetsGeometry.fromLTRB(20, 300, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- INGREDIENTS SECTION ---
                    Text(
                      'Ingredients',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                    ),
                    Divider(thickness: 1, color: Colors.grey), // The line under the title
                    SizedBox(height: 10),
                    Text('• 100 ml milk\n• 50 g butter\n• 3 eggs\n• 1 tbs cocoa'),
                    
                    SizedBox(height: 40), // Space between sections

                    // --- METHOD SECTION ---
                    Text(
                      'Method',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
                    ),
                    Divider(thickness: 1, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      '1. Mix the dry ingredients.\n'
                      '2. Add the milk and eggs.\n'
                      '3. Bake at 180°C for 15 mins.',
                      style: TextStyle(height: 1.5),
                    ),
                  ],
                ),
                )
              ),
            ]
          ),

          Positioned(
            top: 60,   // Moves it down from the top
            left: 40,  // Gives it breathing room on the left
            right: 40, // Gives it breathing room on the right
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.pink.shade50), // Semi-transparent white/pink
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Strawberry cupcake',
                    style: TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Text('2 servings'),
                      SizedBox(width: 20),
                      Icon(Icons.timer_outlined, size: 16),
                      Text(' 15 minutes'),
                    ],
                  ),
                  const SizedBox(height: 20), // Space between the row and the paragraph
                  const Text(
                    'Nunc nulla velit, feugiat vitae ex quis, lobortis porta leo. '
                    'Donec dictum lectus in ex accumsan sodales. '
                    'Pellentesque habitant morbi tristique.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5, // Line height for better readability
                    ),
                  ),
                ],
              ),
            ),
          )
        ]
      )
    );
  }
}
*/
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
            minWidth: 320, // Your absolute minimum width
          ),
          child: Builder(
            builder: (context) {
              final width = constraints.maxWidth;
 
              // Route to different layouts based on screen size
              if (width < 600) {
                return const MobileLayout();
              } else if (width < 1200) {
                return const TabletLayout();
              } else {
                return const DesktopLayout();
              }
          } 
          )
          );
        },
      ),
    );
  }
}
*/