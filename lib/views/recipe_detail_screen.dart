import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe_layout/views/edit_recipe_screen.dart';
import '../models/recipe_model.dart';
import 'dart:io';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final String recipeDocId;

  const RecipeDetailScreen({super.key, required this.recipe, required this.recipeDocId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late int _baseServings;
  late int _currentServings;

  @override
  void initState() {
    super.initState();
    _baseServings = int.tryParse(widget.recipe.servings.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    _currentServings = _baseServings;
  }

  Map<String, List<String>> _getScaledIngredients() {
    if (_currentServings == _baseServings) return widget.recipe.ingredients;

    double multiplier = _currentServings / _baseServings;
    Map<String, List<String>> scaledMap = {};

    widget.recipe.ingredients.forEach((key, list) {
      scaledMap[key] = list.map((ingredient) {
        final regex = RegExp(r'^\s*(\d+/\d+|\d+(\.\d+)?)');
        final match = regex.firstMatch(ingredient);

        if (match != null) {
          String numStr = match.group(1)!;
          double value;

          if (numStr.contains('/')) {
            var parts = numStr.split('/');
            value = double.parse(parts[0]) / double.parse(parts[1]);
          } else {
            value = double.parse(numStr);
          }

          double newValue = value * multiplier;
          String newStringValue = newValue == newValue.roundToDouble()
              ? newValue.toInt().toString()
              : newValue.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');

          return ingredient.replaceFirst(numStr, newStringValue);
        }
        return ingredient;
      }).toList();
    });

    return scaledMap;
  }

  // --- Helper: Safely loads either assets or local phone photos ---
  Widget _buildRecipeImage(String imagePath, {BoxFit fit = BoxFit.cover, FilterQuality quality = FilterQuality.low}) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: fit,
        filterQuality: quality,
        errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: fit,
        filterQuality: quality,
        errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B5A2B),
      appBar: AppBar(
        title: Text(
          widget.recipe.title,
          style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              widget.recipe.isFavourite ? Icons.favorite : Icons.favorite_border,
              color: widget.recipe.isFavourite ? Colors.redAccent : Colors.white,
            ),
            onPressed: () async {
              final newValue = !widget.recipe.isFavourite;
              setState(() {
                widget.recipe.isFavourite = newValue;
              });
              // Write the change to Firestore so the profile screen sees it
              await FirebaseFirestore.instance
                  .collection('recipes')
                  .doc(widget.recipeDocId)
                  .update({'isFavourite': newValue});
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8DC),
              border: Border.all(color: const Color(0xFF5D4037), width: 4),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Colors.black45, offset: Offset(4, 4), blurRadius: 0),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ==========================================
                // IMAGE & GAME ICON
                // ==========================================
                Stack(
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFF5D4037), width: 4)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                            child: _buildRecipeImage(widget.recipe.imageAsset, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDC484),
                          border: Border.all(color: const Color(0xFF5D4037), width: 3),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Transform.scale(
                            scale: 1.2,
                            child: _buildRecipeImage(widget.recipe.iconImage, fit: BoxFit.contain, quality: FilterQuality.none),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ==========================================
                // HEADER TEXT INFO & DYNAMIC SERVINGS
                // ==========================================
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- TITLE + VEG TAG on the same line ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              widget.recipe.title,
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4E342E)),
                            ),
                          ),
                          if (widget.recipe.isVegetarian) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                border: Border.all(color: const Color(0xFF1B5E20), width: 2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'VEG',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 8),

                      // --- METADATA ROW: time | servings | [spacer] | edit + delete ---
                      Row(
                        children: [
                          // Time
                          const Icon(Icons.access_time, size: 18, color: Color(0xFF5D4037)),
                          const SizedBox(width: 4),
                          Text(widget.recipe.time,
                              style: const TextStyle(fontWeight: FontWeight.bold)),

                          const SizedBox(width: 16),

                          // Servings stepper
                          const Icon(Icons.restaurant, size: 18, color: Color(0xFF5D4037)),
                          const SizedBox(width: 4),
                          _buildChunkyButton('-', () {
                            if (_currentServings > 1) {
                              setState(() => _currentServings--);
                            }
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '$_currentServings',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          _buildChunkyButton('+', () {
                            setState(() => _currentServings++);
                          }),

                          // Push edit & delete to the right
                          const Spacer(),

                          // Edit icon
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditRecipeScreen(
                                    recipe: widget.recipe,
                                    recipeDocId: widget.recipeDocId,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDC484),
                                border: Border.all(
                                    color: const Color(0xFF5D4037), width: 2),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, offset: Offset(1, 1))
                                ],
                              ),
                              child: const Icon(Icons.edit,
                                  size: 16, color: Color(0xFF5D4037)),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Delete icon
                          GestureDetector(
                            onTap: () async {
                              // Show a confirmation dialog first
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: const Color(0xFFFFF8DC),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    side: const BorderSide(color: Color(0xFF5D4037), width: 3),
                                  ),
                                  title: const Text(
                                    'Delete Recipe?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5D4037),
                                    ),
                                  ),
                                  content: Text(
                                    'Are you sure you want to delete "${widget.recipe.title}"? This cannot be undone.',
                                    style: const TextStyle(color: Color(0xFF5D4037)),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text('Cancel',
                                          style: TextStyle(color: Color(0xFF8B5A2B))),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFFE53935),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          side: const BorderSide(color: Color(0xFF5D4037), width: 2),
                                        ),
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && mounted) {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('recipes')
                                      .doc(widget.recipeDocId)
                                      .delete();

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Recipe deleted.')),
                                    );
                                    Navigator.of(context).pop(); // Go back to the list
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to delete: $e')),
                                    );
                                  }
                                }
                              }
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDC484),
                                border: Border.all(
                                    color: const Color(0xFF5D4037), width: 2),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, offset: Offset(1, 1))
                                ],
                              ),
                              child: const Icon(Icons.delete_outline,
                                  size: 16, color: Color(0xFFE53935)),
                            ),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(color: Color(0xFF5D4037), thickness: 2),
                      ),

                      Text(
                        '"${widget.recipe.description}"',
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF4E342E)),
                      ),
                    ],
                  ),
                ),

                // ==========================================
                // INGREDIENTS
                // ==========================================
                _buildSectionHeader('Ingredients'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: _buildSectionContent(
                    data: _getScaledIngredients(),
                    isComplicated: widget.recipe.isComplicated,
                  ),
                ),

                const SizedBox(height: 16),

                // ==========================================
                // INSTRUCTIONS
                // ==========================================
                _buildSectionHeader('Instructions'),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 8.0, bottom: 24.0),
                  child: _buildSectionContent(
                    data: widget.recipe.method,
                    isComplicated: widget.recipe.isComplicated,
                    isNumbered: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper: Stardew Interactive Buttons ---
  Widget _buildChunkyButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFEDC484),
          border: Border.all(color: const Color(0xFF5D4037), width: 2),
          boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(1, 1))],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
                fontSize: 18,
                height: 1.1),
          ),
        ),
      ),
    );
  }

  // --- Helper: Stardew-style section banners ---
  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFEDC484),
        border: Border(
          top: BorderSide(color: Color(0xFF5D4037), width: 3),
          bottom: BorderSide(color: Color(0xFF5D4037), width: 3),
        ),
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Color(0xFF5D4037)),
      ),
    );
  }

  // --- Helper: Builds Dropdowns or Simple Lists safely ---
  Widget _buildSectionContent(
      {required Map<String, List<String>> data,
      required bool isComplicated,
      bool isNumbered = false}) {
        
    // 🛡️ THE FIX: Safety check! If the database map is completely empty, don't crash.
    if (data.isEmpty || data.values.every((list) => list.isEmpty)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(
          'No information available.',
          style: TextStyle(color: Color(0xFF5D4037), fontStyle: FontStyle.italic),
        ),
      );
    }

    if (isComplicated) {
      return Column(
        children: data.entries.map((entry) {
          return Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              iconColor: const Color(0xFF5D4037),
              collapsedIconColor: const Color(0xFF5D4037),
              title: Text(entry.key,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF8B5A2B))),
              children: entry.value.asMap().entries.map((item) {
                return _buildListItem(item.value, item.key, isNumbered);
              }).toList(),
            ),
          );
        }).toList(),
      );
    } else {
      // Because we checked data.isEmpty above, calling .first here is now 100% safe!
      return Column(
        children: data.values.first.asMap().entries.map((item) {
          return _buildListItem(item.value, item.key, isNumbered);
        }).toList(),
      );
    }
  }

  // --- Helper: Renders individual text rows ---
  Widget _buildListItem(String text, int index, bool isNumbered) {
    final Recipe? linkedRecipe = widget.recipe.subRecipes
        .where((r) => text.toLowerCase().contains(r.title.toLowerCase()))
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            isNumbered ? '${index + 1}. ' : '• ',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
                fontSize: 16),
          ),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 16, color: Color(0xFF5D4037), height: 1.4),
            ),
          ),
          if (linkedRecipe != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RecipeDetailScreen(recipe: linkedRecipe, recipeDocId: linkedRecipe.id,),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDC484),
                  border: Border.all(color: const Color(0xFF5D4037), width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, offset: Offset(1, 1))
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '>',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}