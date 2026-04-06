import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF1A1A2E);
  static const Color primaryVariant = Color(0xFF16213E);
  static const Color accent = Color(0xFF0F3460);
  static const Color highlight = Color(0xFFE94560);

  // Background
  static const Color background = Color(0xFF0D0D1A);
  static const Color surface = Color(0xFF1E1E30);
  static const Color surfaceVariant = Color(0xFF252540);
  static const Color cardBg = Color(0xFF1E1E35);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0CC);
  static const Color textHint = Color(0xFF6B6B8A);

  // Status
  static const Color success = Color(0xFF00C896);
  static const Color error = Color(0xFFFF4757);
  static const Color warning = Color(0xFFFFB300);

  // Chat
  static const Color chatBubbleUser = Color(0xFF0F3460);
  static const Color chatBubbleBot = Color(0xFF252540);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE94560), Color(0xFFFF6B6B)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1E35), Color(0xFF252545)],
  );
}
