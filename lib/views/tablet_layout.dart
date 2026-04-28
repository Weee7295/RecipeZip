import 'package:flutter/material.dart';
//import '../widgets/recipe_sections.dart';
import '../widgets/recipe_sections_updated.dart';
import '../models/recipe_model.dart';
import '../helpers/device_helper.dart';

class TabletLayout extends StatelessWidget {
  final Recipe recipe;
 
  const TabletLayout({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    final padding = getPadding(context);

    return Row(
      children: [
        // ========================================================================
        // LEFT: Large image
        // ========================================================================
        Expanded(
          flex: 1,
          child: Image.asset(
            'assets/images/pinkcake.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
          ),
        ),

        // ========================================================================
        // RIGHT: Content
        // ========================================================================
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Header
                  RecipeHeaderCard(
                    title: recipe.title,
                    servings: recipe.servings,
                    time: recipe.time,
                    description: recipe.description,
                  ),
                  SizedBox(height: getGapBetweenSections(context)),

                  // Ingredients Section
                  IngredientsSection(ingredients: recipe.ingredients),
                  SizedBox(height: getGapBetweenSections(context)),

                  // Method Section
                  MethodSection(method: recipe.method),
                  SizedBox(height: getGapBetweenSections(context)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}