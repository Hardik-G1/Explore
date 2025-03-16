import 'package:flutter/material.dart';
import 'dart:ui';

class GlassNavBar extends StatefulWidget {
  const GlassNavBar({super.key});

  @override
  State<GlassNavBar> createState() => _GlassNavBarState();
}

class _GlassNavBarState extends State<GlassNavBar> {
  int _selectedIndex = 1; // Starting with profile selected

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromRGBO(255, 255, 255, 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(255, 255, 255, 0.05),
            blurRadius: 100,
            spreadRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(42, 47, 79, 0.35),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(1, Icons.search),
                _buildNavItem(2, Icons.access_time),
                _buildNavItem(3, Icons.notifications_none),
                _buildNavItem(4, Icons.person_outline),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 28, // Increased icon size
          color: isSelected ? Colors.blue : Colors.grey[400],
        ),
      ),
    );
  }
}
