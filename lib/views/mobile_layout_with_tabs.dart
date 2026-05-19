import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import 'recipe_detail_screen.dart'; 
import 'profile_screen.dart'; 
import 'dart:io';

class MobileLayoutWithTabs extends StatefulWidget {
  final List<Recipe> recipes;
  final int currentIndex;
  final Function(int) onRecipeChanged;
  final bool isVegetarianOnly;             
  final Function(bool) onVegetarianToggle;

  const MobileLayoutWithTabs({
    super.key,
    required this.recipes,
    required this.currentIndex,
    required this.onRecipeChanged,
    required this.isVegetarianOnly,         
    required this.onVegetarianToggle
  });

  @override
  State<MobileLayoutWithTabs> createState() => _MobileLayoutWithTabsState();
}

class _MobileLayoutWithTabsState extends State<MobileLayoutWithTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = true; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper to handle both hardcoded assets AND local phone photos
  Widget _buildRecipeImage(String imagePath, {double? width, double? height}) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, width: width, height: height, fit: BoxFit.cover);
    } else {
      return Image.file(File(imagePath), width: width, height: height, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8DC),
      appBar: AppBar(
        title: const Text(
          'Queen of Sauce',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Courier'),
        ),
        backgroundColor: const Color(0xFF5D4037),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen(
                      isVegetarianOnly: widget.isVegetarianOnly,
                      onVegetarianToggle: widget.onVegetarianToggle,
                )),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: Colors.white,
          indicatorWeight: 4.0,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Spring'),
            Tab(text: 'Summer'),
            Tab(text: 'Fall'),
            Tab(text: 'Winter'),
          ],
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.grid_view,
                    color: _isGridView ? const Color(0xFF5D4037) : Colors.grey,
                  ),
                  onPressed: () => setState(() => _isGridView = true),
                ),
                IconButton(
                  icon: Icon(
                    Icons.view_list,
                    color: !_isGridView ? const Color(0xFF5D4037) : Colors.grey,
                  ),
                  onPressed: () => setState(() => _isGridView = false),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecipeDashboard('Spring'),
                _buildRecipeDashboard('Summer'),
                _buildRecipeDashboard('Fall'),
                _buildRecipeDashboard('Winter'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeDashboard(String season) {
    final recipesToShow = widget.recipes.where((recipe) => recipe.season == season).toList();

    if (recipesToShow.isEmpty) {
      return const Center(
        child: Text(
          'No recipes discovered for this season yet.',
          style: TextStyle(fontSize: 16, color: Color(0xFF5D4037), fontStyle: FontStyle.italic),
        ),
      );
    }

    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8,
        ),
        itemCount: recipesToShow.length,
        itemBuilder: (context, index) => _buildRecipeCard(recipesToShow[index]),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recipesToShow.length,
        itemBuilder: (context, index) => _buildRecipeListItem(recipesToShow[index]),
      );
    }
  }

  // --- Updated Grid Card with Favorite Box on the same line as the VEG label ---
  Widget _buildRecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () => _openRecipeDetails(recipe),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF5D4037), width: 3),
          boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Image Section with top-line overlays (VEG and Favorite Box)
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Uses your helper to expand the image perfectly into the box!
                  SizedBox.expand(
                    child: _buildRecipeImage(recipe.imageAsset),
                  ),
                  
                  // VEG Label on the Top-Left
                  if (recipe.isVegetarian)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          border: Border.all(color: const Color(0xFF1B5E20), width: 2),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [BoxShadow(color: Colors.black45, offset: Offset(1, 1))],
                        ),
                        child: const Text(
                          'VEG',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  // Boxed Favorite Button moved up to the Top-Right (Same horizontal line!)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _buildBoxedFavoriteButton(recipe),
                  ),
                ],
              ),
            ),
            
            // 2. Bottom Info Row (Title and Duration only)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      recipe.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '🕒 ${recipe.time}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildRecipeListItem(Recipe recipe) {
    return GestureDetector(
      onTap: () => _openRecipeDetails(recipe),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF5D4037), width: 3),
          boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2))],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF5D4037), width: 1),
            ),
            // Uses your helper to safely load the 50x50 thumbnail!
            child: _buildRecipeImage(recipe.imageAsset, width: 50, height: 50),
          ),
          // Using Flexible lets the badge tuck right up against the text
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible( // <--- Changed from Expanded to Flexible!
                child: Text(
                  recipe.title, 
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (recipe.isVegetarian) ...[
                const SizedBox(width: 6), // Tightened gap
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    border: Border.all(color: const Color(0xFF1B5E20), width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'VEG', 
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '🕒 ${recipe.time} • ${recipe.servings}', 
              style: const TextStyle(fontSize: 12),
            ),
          ),
          trailing: _buildBoxedFavoriteButton(recipe),
        ),
      ),
    );
  }

  // --- The Magic Navigation Sync ---
  Future<void> _openRecipeDetails(Recipe recipe) async {
    // 1. Wait for the user to view the detail screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipe: recipe, recipeDocId: recipe.id),
      ),
    );
    // 2. When they click 'Back', refresh the Dashboard to show any new hearts!
    setState(() {});
  }

  // --- Shared Stardew-style Boxed Favorite Button ---
    Widget _buildBoxedFavoriteButton(Recipe recipe) {
    return GestureDetector(
      onTap: () async {
        final newValue = !recipe.isFavourite;
        setState(() {
          recipe.isFavourite = newValue;
        });
        // Write to Firestore so profile screen stays in sync
        await FirebaseFirestore.instance
            .collection('recipes')
            .doc(recipe.id)
            .update({'isFavourite': newValue});
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF5D4037), width: 2),
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(1, 1),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            recipe.isFavourite ? Icons.favorite : Icons.favorite_border,
            size: 18,
            color: recipe.isFavourite ? Colors.redAccent : const Color(0xFF5D4037),
          ),
        ),
      ),
    );
  }
}
