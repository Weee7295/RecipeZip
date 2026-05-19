// lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF5D4037), width: 4)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap, // Triggers the function passed down from the parent
        backgroundColor: const Color(0xFFDEB887), 
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFF8B5A2B),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add Recipe',
          ),
        ],
      ),
    );
  }
}