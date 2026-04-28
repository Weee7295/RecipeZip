import 'package:flutter/material.dart';
import 'package:recipe_layout/home.dart';
import '../models/recipe_model.dart';
import '../widgets/recipe_sections_updated.dart';

class MobileLayoutWithTabs extends StatefulWidget {
  final List<Recipe> recipes;
  final int currentIndex;
  final Function(int) onRecipeChanged;

  const MobileLayoutWithTabs({
    super.key,
    required this.recipes,
    required this.currentIndex,
    required this.onRecipeChanged,
  });

  @override
  State<MobileLayoutWithTabs> createState() =>
      _MobileLayoutWithTabsState();
}

class _MobileLayoutWithTabsState extends State<MobileLayoutWithTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.recipes.length,
      vsync: this,
      initialIndex: widget.currentIndex,
    );
    _tabController.addListener(() {
      widget.onRecipeChanged(_tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipes[_tabController.index];

    return Scaffold(
      // ========================================================================
      // APP BAR with Tabs
      // ========================================================================
      appBar: AppBar(
        title: const Text('Recipes'),
        backgroundColor: Colors.pink.shade50,
        elevation: 0,
        actions: [
          // This adds the person icon to the top right corner
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // This routes the user to the HomeScreen when clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.pink,
          labelColor: Colors.pink,
          unselectedLabelColor: Colors.grey,
          tabs: widget.recipes
              .map((recipe) => Tab(text: recipe.title))
              .toList(),
        ),
      ),

      // ========================================================================
      // BODY: Recipe content
      // ========================================================================
      body: Stack(
        children: [
          // Background image
          Row(
            children: [
              Expanded(
                child: Image.asset(
                  recipe.imageAsset,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ),
              ),
            ],
          ),

          // Title card positioned on top
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: RecipeHeaderCard(
                title: recipe.title,
                servings: recipe.servings,
                time: recipe.time,
                description: recipe.description,
              ),
            ),
          ),

          // Scrollable content at bottom
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
                    child: IngredientsSection(ingredients: recipe.ingredients),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: MethodSection(method: recipe.method),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}