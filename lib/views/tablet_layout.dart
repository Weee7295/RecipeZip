import 'package:flutter/material.dart';
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
        Expanded(
          flex: 1,
          child: Image.asset(
            recipe.imageAsset, // Updated to use the actual recipe image
            fit: BoxFit.cover,
            height: double.infinity,
          ),
        ),

        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RecipeHeaderCard(
                    title: recipe.title,
                    servings: recipe.servings,
                    time: recipe.time,
                    description: recipe.description,
                  ),
                  SizedBox(height: getGapBetweenSections(context)),

                  // Added isComplicated parameter
                  IngredientsSection(
                    ingredients: recipe.ingredients, 
                    isComplicated: recipe.isComplicated,
                  ),
                  SizedBox(height: getGapBetweenSections(context)),

                  // Added isComplicated parameter
                  MethodSection(
                    method: recipe.method, 
                    isComplicated: recipe.isComplicated,
                  ),
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