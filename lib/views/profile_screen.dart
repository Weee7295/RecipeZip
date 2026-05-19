import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recipe_model.dart'; // Make sure this path is correct for your app
import 'recipe_detail_screen.dart'; 

// ========================================================================
// PROFILE / SETTINGS SCREEN
// ========================================================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Local state for the Vegetarian toggle
  bool _isVegetarianOnly = false;

  @override
  Widget build(BuildContext context) {
    // 1. Get the current user to display their email/name
    final User? currentUser = FirebaseAuth.instance.currentUser;
    
    // 2. Filter our global recipe list to only show ones where isFavourite is true
    final List<Recipe> favoriteRecipes = allRecipes.where((r) => r.isFavourite).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5A2B),
        foregroundColor: Colors.white,
        title: const Text('My Kitchen Settings', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Courier')),
        elevation: 4,
      ),
      // SingleChildScrollView prevents overflow errors on smaller screens
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            // --- SECTION 1: PROFILE PICTURE & INFO ---
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDC484),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF5D4037), width: 4),
                  boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2))],
                ),
                child: const Icon(Icons.person, size: 80, color: Color(0xFF5D4037)),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                currentUser?.email ?? 'Guest Farmer',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
              ),
            ),
            const SizedBox(height: 30),

            // --- SECTION 2: APP SETTINGS (VEG TOGGLE) ---
            const Text(
              'Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5A2B)),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF5D4037), width: 3),
                boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(2, 2))],
              ),
              child: SwitchListTile(
                title: const Text('Vegetarian Recipes Only', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
                subtitle: const Text('Hide dishes containing meat.', style: TextStyle(fontSize: 12)),
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF4CAF50),
                inactiveThumbColor: const Color(0xFF5D4037),
                inactiveTrackColor: const Color(0xFFEDC484),
                value: _isVegetarianOnly,
                onChanged: (bool value) {
                  setState(() {
                    _isVegetarianOnly = value;
                  });
                  // NOTE: To make this filter the dashboard, you will eventually 
                  // need to lift this state up or use a state manager like Provider!
                },
              ),
            ),
            const SizedBox(height: 30),

            // --- SECTION 3: FAVORITE RECIPES LIST ---
            const Text(
              'My Cookbook (Favorites)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5A2B)),
            ),
            const SizedBox(height: 10),
            
            // If the user hasn't favorited anything, show a friendly message
            if (favoriteRecipes.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  border: Border.all(color: Colors.grey, width: 2, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    "You haven't added any recipes to your favorites yet.\n\nTap the heart icon on a recipe card to save it here!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF5D4037)),
                  ),
                ),
              )
            else
              // Build a neat list of all their favorited items
              ListView.builder(
                shrinkWrap: true, // Crucial when putting a ListView inside a ScrollView
                physics: const NeverScrollableScrollPhysics(), 
                itemCount: favoriteRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = favoriteRecipes[index];
                  return GestureDetector(
                    onTap: () async {
                      // Navigate to the detail screen, and refresh when returning
                      // just in case they unfavorited it while looking at it!
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)),
                      );
                      setState(() {}); 
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFF5D4037), width: 2),
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          recipe.iconImage, 
                          width: 40, 
                          height: 40,
                          errorBuilder: (c, e, s) => const Icon(Icons.fastfood, color: Color(0xFF5D4037)),
                        ),
                        title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(recipe.season, style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.favorite, color: Colors.redAccent),
                      ),
                    ),
                  );
                },
              ),
              
            const SizedBox(height: 40),

            // --- SECTION 4: SAFE LOG OUT ---
            FilledButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(color: Color(0xFF5D4037), width: 3),
                ),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}