import 'package:flutter/material.dart';
import '../models/recipe_model.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late int _baseServings;
  late int _currentServings;

  @override
  void initState() {
    super.initState();
    // Extract the number from the string (e.g., "4 servings" -> 4)
    // Defaults to 1 if no number is found.
    _baseServings = int.tryParse(widget.recipe.servings.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    _currentServings = _baseServings;
  }

  // ====================================================================
  // MATH LOGIC: Scales the ingredients dynamically
  // ====================================================================
  Map<String, List<String>> _getScaledIngredients() {
    if (_currentServings == _baseServings) return widget.recipe.ingredients;

    double multiplier = _currentServings / _baseServings;
    Map<String, List<String>> scaledMap = {};

    widget.recipe.ingredients.forEach((key, list) {
      scaledMap[key] = list.map((ingredient) {
        // Looks for a number (e.g., "100") or fraction (e.g., "1/2") at the start of the string
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
          // Format the number so it doesn't show "2.0", just "2"
          String newStringValue = newValue == newValue.roundToDouble() 
              ? newValue.toInt().toString() 
              : newValue.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
          
          return ingredient.replaceFirst(numStr, newStringValue);
        }
        return ingredient; // Returns original if no number found (e.g., "Pinch of salt")
      }).toList();
    });

    return scaledMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B5A2B), // Deep wood brown
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
            onPressed: () {
              setState(() {
                widget.recipe.isFavourite = !widget.recipe.isFavourite;
              });
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8DC), // Parchment
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
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                        child: Image.asset(
                          widget.recipe.imageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDC484), // Lighter wood
                          border: Border.all(color: const Color(0xFF5D4037), width: 3),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: Transform.scale(
                            scale: 1.2, // Adjust this number to change the zoom level
                            child: Image.asset(
                              widget.recipe.iconImage,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.none, // Keeps the pixel art clean and crisp
                              errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.fastfood, color: Colors.white),
                            ),
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
                      Text(
                        widget.recipe.title,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
                      ),
                      const SizedBox(height: 8),
                      
                      // Metadata Row
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 18, color: Color(0xFF5D4037)),
                          const SizedBox(width: 4),
                          Text(widget.recipe.time, style: const TextStyle(fontWeight: FontWeight.bold)),
                          
                          const SizedBox(width: 16),
                          
                          // --- INTERACTIVE SERVING SIZE ---
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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                            ),
                          ),
                          
                          _buildChunkyButton('+', () {
                            setState(() => _currentServings++);
                          }),
                          // --------------------------------

                          const Spacer(),
                          
                          if (widget.recipe.isVegetarian)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                border: Border.all(color: const Color(0xFF1B5E20), width: 2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('VEG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                        ],
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(color: Color(0xFF5D4037), thickness: 2),
                      ),
                      
                      Text(
                        '"${widget.recipe.description}"',
                        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Color(0xFF4E342E)),
                      ),
                    ],
                  ),
                ),

                // ==========================================
                // INGREDIENTS (Using scaled math!)
                // ==========================================
                _buildSectionHeader('Ingredients'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: _buildSectionContent(
                    data: _getScaledIngredients(), // Passes the dynamically calculated map
                    isComplicated: widget.recipe.isComplicated,
                  ),
                ),

                const SizedBox(height: 16),

                // ==========================================
                // INSTRUCTIONS
                // ==========================================
                _buildSectionHeader('Instructions'),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 24.0),
                  child: _buildSectionContent(
                    data: widget.recipe.method, // Methods don't scale
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
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4037), fontSize: 18, height: 1.1)
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
        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFF5D4037)),
      ),
    );
  }

  // --- Helper: Builds Dropdowns or Simple Lists ---
 Widget _buildSectionContent({required Map<String, List<String>> data, required bool isComplicated, bool isNumbered = false}) {
    if (isComplicated) {
      return Column(
        children: data.entries.map((entry) {
          return Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent), 
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              iconColor: const Color(0xFF5D4037),
              collapsedIconColor: const Color(0xFF5D4037),
              title: Row(
                children: [
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF8B5A2B))),
    
                ],
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
        children: data.values.first.asMap().entries.map((item) {
          return _buildListItem(item.value, item.key, isNumbered);
        }).toList(),
      );
    }
  }

  // --- Helper: Renders individual text rows ---
// --- Completely Fixed & Cleaned Linkable List Item ---
  Widget _buildListItem(String text, int index, bool isNumbered) {
    final Recipe? linkedRecipe = widget.recipe.subRecipes
        .where((r) => text.toLowerCase().contains(r.title.toLowerCase()))
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Keeps bullet, text, and button vertically centered together
        children: [
          // 1. Bullet point or numbering prefix
          Text(
            isNumbered ? '${index + 1}. ' : '• ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4037), fontSize: 16),
          ),
          
          // 2. The ingredient or instruction text string
          // Flexible allows text to occupy natural width and safely wraps down if it's long
          Flexible(
            child: Text(
              text, 
              style: const TextStyle(fontSize: 16, color: Color(0xFF5D4037), height: 1.4),
            ),
          ),
          
          // 3. Inline Game-Style Link Button (Kept safely inside the Row children array!)
          if (linkedRecipe != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(recipe: linkedRecipe),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDC484), // Retro wood slot finish
                  border: Border.all(color: const Color(0xFF5D4037), width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(1, 1))],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '>', 
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
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