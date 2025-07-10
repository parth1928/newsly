import 'package:flutter/material.dart';
import '../constants/style_constants.dart';

class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;

  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 64,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: const Color(0xFF242424),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, -1),
              blurRadius: 4,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 2),
              blurRadius: 6,
              spreadRadius: -2,
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_rounded),
            _buildNavItem(1, Icons.feed_rounded),
            _buildNavItem(2, Icons.explore_rounded),
            _buildNavItem(3, Icons.bookmark_rounded),
            _buildNavItem(4, Icons.person_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTabChanged(index),
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Icon with gradient
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: isSelected
                      ? [AppColors.accent, AppColors.accentSecondary]
                      : [Colors.grey.shade400, Colors.grey.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isSelected ? 30 : 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
