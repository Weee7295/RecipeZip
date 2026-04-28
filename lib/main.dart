import 'package:flutter/material.dart';
import 'package:recipe_layout/auth_gate.dart';
import 'models/recipe_model.dart';
import 'views/mobile_layout_with_tabs.dart';
import 'views/tablet_layout.dart';
import 'views/desktop_layout.dart';
import 'firebase_options.dart';  
import 'package:firebase_core/firebase_core.dart';  

void main() async{
    // Add from here...
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // To here.
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AuthGate(clientId: '709918116887-r25furm4fc5gbk7r5juhdtq7ir7od0gn.apps.googleusercontent.com'),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Current selected recipe index
  int _currentRecipeIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Get current recipe
    final currentRecipe = allRecipes[_currentRecipeIndex];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          // Route to different layouts based on screen size
          if (width < 600) {
            return MobileLayoutWithTabs(
              recipes: allRecipes,
              currentIndex: _currentRecipeIndex,
              onRecipeChanged: (index) {
                setState(() {
                  _currentRecipeIndex = index;
                });
              },
            );
          } else if (width < 1200) {
            return TabletLayout(recipe: currentRecipe);
          } else {
            return DesktopLayout(recipe: currentRecipe);
          }
        },
      ),
    );
  }
}