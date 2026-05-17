import 'package:flutter/material.dart';

// ============================================================================
// INGREDIENTS SECTION
// ============================================================================

class IngredientsSection extends StatelessWidget {
  final Map<String, List<String>> ingredients;
  final bool isComplicated;

  const IngredientsSection({
    super.key,
    required this.ingredients,
    required this.isComplicated,
  });

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
        _buildContent(ingredients, false),
      ],
    );
  }

  // Shared builder logic for lists or dropdowns
  Widget _buildContent(Map<String, List<String>> data, bool isNumbered) {
    if (data.isEmpty) return const SizedBox.shrink();

    if (isComplicated) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          return Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              children: entry.value.asMap().entries.map((item) {
                return _buildListItem(item.value, item.key, isNumbered);
              }).toList(),
            ),
          );
        }).toList(),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.values.first.asMap().entries.map((item) {
          return _buildListItem(item.value, item.key, isNumbered);
        }).toList(),
      );
    }
  }

  Widget _buildListItem(String text, int index, bool isNumbered) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isNumbered ? '${index + 1}. ' : '• ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// METHOD SECTION
// ============================================================================

class MethodSection extends StatelessWidget {
  final Map<String, List<String>> method;
  final bool isComplicated;

  const MethodSection({
    super.key,
    required this.method,
    required this.isComplicated,
  });

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
        // We reuse the same logic from IngredientsSection to build the content
        IngredientsSection(ingredients: method, isComplicated: isComplicated)._buildContent(method, true),
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
    super.key,
    required this.title,
    required this.servings,
    required this.time,
    required this.description,
  });

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