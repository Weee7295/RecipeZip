import 'package:flutter/material.dart';
import '../widgets/recipe_sections.dart';

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 320,
        minHeight: 600,
      ),
      child: Stack(
        children: [
          // ========================================================================
          // BACKGROUND: Full-screen image
          // ========================================================================
          Row(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/images/pinkcake.jpg',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ),
              ),
            ],
          ),
      
          // ========================================================================
          // FOREGROUND: Title card positioned on top
          // ========================================================================
          Positioned(
            top: 100,   // Distance from top
            left: 20,  // Distance from left
            right: 20, // Distance from right
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const RecipeHeaderCard(
                title: 'Strawberry cupcake',
                servings: '2 servings',
                time: '15 minutes',
                description:
                    'Nunc nulla velit, feugiat vitae ex quis, lobortis porta leo. '
                    'Donec dictum lectus in ex accumsan sodales. '
                    'Pellentesque habitant morbi tristique.',
              ),
            ),
          ),
      
          // ========================================================================
          // BOTTOM CONTENT: Scrollable ingredients and method
          // ========================================================================
          Positioned(
            top: 350,
            left: 20,
            right: 20,
            bottom: 20,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const IngredientsSection(),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const MethodSection(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}