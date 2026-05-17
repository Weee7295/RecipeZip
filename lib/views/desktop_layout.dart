import 'package:flutter/material.dart';
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
            Expanded(
              flex: 1,
              child: Image.asset(
                recipe.imageAsset, // Updated to use actual recipe image
                fit: BoxFit.cover,
                height: double.infinity,
              ),
            ),

            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      // Added isComplicated parameter
                      IngredientsSection(
                        ingredients: recipe.ingredients,
                        isComplicated: recipe.isComplicated,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      // Added isComplicated parameter
                      MethodSection(
                        method: recipe.method,
                        isComplicated: recipe.isComplicated,
                      ),
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