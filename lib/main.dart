import 'package:flutter/material.dart';
import 'models/recipe_model.dart';
import 'views/mobile_layout_with_tabs.dart';
import 'views/tablet_layout.dart';
import 'views/desktop_layout.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
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