import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds & Surfaces (Soft Clean Pastel Canvas)
  static const Color background = Color(0xFFF6F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF1F5F9);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFEEF2F6);

  // Brand / Accents (Pastel Infused)
  static const Color primary = Color(0xFF3B82F6); // Soft Royal Blue
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryPastel = Color(0xFFEBF3FF);

  static const Color accent = Color(0xFF0284C7); // Sky Blue Accent
  static const Color accentPastel = Color(0xFFE0F2FE);

  static const Color teal = Color(0xFF0D9488); // Sage Mint
  static const Color tealPastel = Color(0xFFE6F7F5);

  static const Color purple = Color(0xFF7C3AED); // Soft Violet
  static const Color purplePastel = Color(0xFFF3E8FF);

  // Risk Severity Pastel Palette
  static const Color riskLow = Color(0xFF16A34A); // Mint Green
  static const Color riskLowPastel = Color(0xFFEAF8F0);
  static const Color riskLowBorder = Color(0xFF86EFAC);

  static const Color riskModerate = Color(0xFFD97706); // Warm Amber
  static const Color riskModeratePastel = Color(0xFFFEF3C7);
  static const Color riskModerateBorder = Color(0xFFFCD34D);

  static const Color riskHigh = Color(0xFFDC2626); // Soft Crimson
  static const Color riskHighPastel = Color(0xFFFEE2E2);
  static const Color riskHighBorder = Color(0xFFFCA5A5);

  static const Color riskCritical = Color(0xFF991B1B); // Deep Rose / Critical
  static const Color riskCriticalPastel = Color(0xFFFFECEC);
  static const Color riskCriticalBorder = Color(0xFFF87171);

  // Statuses
  static const Color statusPending = Color(0xFFD97706);
  static const Color statusAssigned = Color(0xFF2563EB);
  static const Color statusInProgress = Color(0xFF7C3AED);
  static const Color statusCompleted = Color(0xFF16A34A);
  static const Color statusRejected = Color(0xFF64748B);

  // Text
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Gradients
  static const LinearGradient riskGradient = LinearGradient(
    colors: [riskLow, riskModerate, riskHigh, riskCritical],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const LinearGradient highlightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
  );

  static const LinearGradient pastelBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
  );

  static const LinearGradient pastelRedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
  );
}
