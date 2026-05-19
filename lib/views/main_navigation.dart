import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import 'mobile_layout_with_tabs.dart'; 
import 'add_recipe_screen.dart';       
import '../widgets/bottom_nav_bar.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _isVegetarianOnly = false;

  void _updateIndex(int newIndex) {
    setState(() {
      _currentIndex = newIndex;
    });
  }

  // --- THE MAGIC INTERNET FETCH FUNCTION ---
  Widget _buildLiveRecipeDashboard() {
    return StreamBuilder<QuerySnapshot>(
      // This stream constantly listens to your 'recipes' collection in the cloud
      stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
      builder: (context, snapshot) {
        
        // 1. Show a loading circle while downloading from the internet
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFF8DC),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF8B5A2B))),
          );
        }

        // 2. Handle errors if the internet drops
        if (snapshot.hasError) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFF8DC),
            body: Center(child: Text("Connection to Pelican Town lost.", style: TextStyle(color: Color(0xFF5D4037)))),
          );
        }

        // 3. Convert the downloaded JSON back into Dart Recipe objects
        var cloudRecipes = snapshot.data!.docs.map((doc) {
          return Recipe.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        if (_isVegetarianOnly) {
          cloudRecipes = cloudRecipes.where((r) => r.isVegetarian).toList();
        }

        // 4. Feed the live cloud data into your existing beautiful layout!
        return MobileLayoutWithTabs(
          recipes: cloudRecipes, 
          currentIndex: 0,
          onRecipeChanged: (index) {},
          isVegetarianOnly: _isVegetarianOnly,           // ADD
          onVegetarianToggle: (val) {                    // ADD
            setState(() => _isVegetarianOnly = val);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // We dynamically build the screen list here so it can use the StreamBuilder
    final List<Widget> screens = [
      _buildLiveRecipeDashboard(), // Tab 0: Live Cloud Dashboard
      const AddRecipeScreen(),     // Tab 1: Add Recipe Form
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _updateIndex, 
      ),
    );
  }
}