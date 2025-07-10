import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF141414);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color accent = Color(0xFFEFB8C8); // New pastel pink
  static const Color accentHover = Color(0xFFE5A5B5); // Darker shade for hover
  static const Color accentSecondary = Color(0xFFFFF2C5);
  static const Color accentTertiary = Color(0xFFE0F1FF);
  static const Color actionPrimary = Color(0xFFFF4D4F);
  static const Color divider = Color(0xFF2A2A2A);
  static const Color buttonText = Color(0xFF1A1A1A); // Dark text for light buttons
}

class AppTypography {
  static final TextStyle _baseStyle = GoogleFonts.inter(
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static final TextStyle heading1 = _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static final TextStyle heading2 = _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
  );

  static final TextStyle heading3 = _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle body1 = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle body2 = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle caption = _baseStyle.copyWith(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.normal,
  );
}

class AppButtonStyle {
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    foregroundColor: AppColors.buttonText,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    textStyle: AppTypography.body1.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ).copyWith(
    overlayColor: WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return AppColors.accentHover;
        }
        if (states.contains(WidgetState.hovered)) {
          return AppColors.accentHover.withOpacity(0.8);
        }
        return null;
      },
    ),
  );

  static final ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textPrimary,
    side: BorderSide(color: AppColors.divider),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    textStyle: AppTypography.body1.copyWith(
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ).copyWith(
    overlayColor: WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.pressed)) {
          return AppColors.surface.withOpacity(0.2);
        }
        if (states.contains(WidgetState.hovered)) {
          return AppColors.surface.withOpacity(0.1);
        }
        return null;
      },
    ),
  );
}

class AppInputDecoration {
  static InputDecoration defaultDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.body1.copyWith(
        color: AppColors.textSecondary,
      ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: _buildBorder(AppColors.divider),
      enabledBorder: _buildBorder(AppColors.divider),
      focusedBorder: _buildBorder(AppColors.accent),
      errorBorder: _buildBorder(AppColors.actionPrimary.withOpacity(0.5)),
      focusedErrorBorder: _buildBorder(AppColors.actionPrimary),
    );
  }

  static OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }
}

class AppDecorations {
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration containerDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration chipDecoration({bool isSelected = false}) {
    return BoxDecoration(
      color: isSelected ? AppColors.accent : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isSelected ? AppColors.accent : AppColors.divider,
        width: 1,
      ),
    );
  }
}
