import 'package:flutter/material.dart';
import '../models/recipe_model.dart';

// ============================================================================
// INGREDIENTS SECTION
// ============================================================================

class IngredientsSection extends StatelessWidget {
  final List<String> ingredients;

  const IngredientsSection({
    Key? key,
    required this.ingredients,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredients',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
        const Divider(thickness: 1, color: Colors.grey),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < ingredients.length; i++) ...[
              Text(
                '• ${ingredients[i]}',
                style: const TextStyle(height: 1.8),
              ),
              if (i < ingredients.length - 1)
                const SizedBox(height: 8),
            ],
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// METHOD SECTION
// ============================================================================

class MethodSection extends StatelessWidget {
  final List<String> method;

  const MethodSection({
    Key? key,
    required this.method,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Method',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
          ),
        ),
        const Divider(thickness: 1, color: Colors.grey),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < method.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}. ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      method[i],
                      style: const TextStyle(height: 1.8),
                    ),
                  ),
                ],
              ),
              if (i < method.length - 1)
                const SizedBox(height: 12),
            ],
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// RECIPE HEADER CARD
// ============================================================================

class RecipeHeaderCard extends StatelessWidget {
  final String title;
  final String servings;
  final String time;
  final String description;

  const RecipeHeaderCard({
    Key? key,
    required this.title,
    required this.servings,
    required this.time,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(servings),
            const SizedBox(width: 20),
            const Icon(Icons.timer_outlined, size: 16),
            Text(' $time'),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}