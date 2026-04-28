import 'package:flutter/material.dart';
//import '../widgets/recipe_sections.dart';
import '../models/recipe_model.dart';
import '../widgets/recipe_sections_updated.dart';
import '../helpers/device_helper.dart';

class DesktopLayout extends StatelessWidget {
  final Recipe recipe;
 
  const DesktopLayout({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1400),
        child: Row(
          children: [
            // ====================================================================
            // LEFT: Large image
            // ====================================================================
            Expanded(
              flex: 1,
              child: Image.asset(
                'assets/images/pinkcake.jpg',
                fit: BoxFit.cover,
                height: double.infinity,
              ),
            ),

            // ====================================================================
            // CENTER: Title and description
            // ====================================================================
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe header with larger text
                      Text(
                        recipe.title,
                        style: TextStyle(
                          fontSize: getHeadingFontSize(context) + 4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(recipe.servings),
                          const SizedBox(width: 30),
                          const Icon(Icons.timer_outlined, size: 18),
                          Text(' ${recipe.time}'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        recipe.description,
                        style: const TextStyle(fontSize: 16, height: 1.7),
                      ),
                      SizedBox(
                        height: getGapBetweenSections(context),
                      ),

                      // Ingredients Section
                      IngredientsSection(ingredients: recipe.ingredients),
                    ],
                  ),
                ),
              ),
            ),

            // ====================================================================
            // RIGHT: Method section
            // ====================================================================
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40),
                      MethodSection(method: recipe.method),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}