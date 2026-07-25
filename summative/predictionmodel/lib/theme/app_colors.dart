import 'package:flutter/material.dart';

/// Design tokens that don't map cleanly onto Material's built-in
/// ColorScheme roles — pulled from the approved UI concept
/// (summative/predictionmodel/design/ui_concept.html) so the real app and
/// the mockup stay visually consistent. Each of the three form sections
/// gets its own accent (teal / gold / forest) so the scroll reads as
/// energetic and color-coded rather than one flat tone throughout.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color teal;
  final Color tealSoft;
  final Color tealContrast;
  final Color gold;
  final Color goldSoft;
  final Color forest;
  final Color forestSoft;
  final Color coral;
  final Color coralSoft;
  final Color muted;
  final Color line;
  final Color cardSurface;

  const AppColors({
    required this.teal,
    required this.tealSoft,
    required this.tealContrast,
    required this.gold,
    required this.goldSoft,
    required this.forest,
    required this.forestSoft,
    required this.coral,
    required this.coralSoft,
    required this.muted,
    required this.line,
    required this.cardSurface,
  });

  static const light = AppColors(
    teal: Color(0xFF0C8F6E),
    tealSoft: Color(0xFFDCF2E9),
    tealContrast: Color(0xFFFFFFFF),
    gold: Color(0xFFB4740A),
    goldSoft: Color(0xFFFBEAD1),
    forest: Color(0xFF3E8E39),
    forestSoft: Color(0xFFE5F3E1),
    coral: Color(0xFFE14F3C),
    coralSoft: Color(0xFFFBE4E0),
    muted: Color(0xFF6B625A),
    line: Color(0x1F1B1B1B),
    cardSurface: Color(0xFFF6F1EC),
  );

  static const dark = AppColors(
    teal: Color(0xFF34D399),
    tealSoft: Color(0xFF123528),
    tealContrast: Color(0xFF07231A),
    gold: Color(0xFFF0B429),
    goldSoft: Color(0xFF3A2A0C),
    forest: Color(0xFF7BC96F),
    forestSoft: Color(0xFF1E2F19),
    coral: Color(0xFFFF7A62),
    coralSoft: Color(0xFF3A2019),
    muted: Color(0xFFA89C8F),
    line: Color(0x24F3EDE6),
    cardSurface: Color(0xFF201A16),
  );

  @override
  AppColors copyWith({
    Color? teal,
    Color? tealSoft,
    Color? tealContrast,
    Color? gold,
    Color? goldSoft,
    Color? forest,
    Color? forestSoft,
    Color? coral,
    Color? coralSoft,
    Color? muted,
    Color? line,
    Color? cardSurface,
  }) {
    return AppColors(
      teal: teal ?? this.teal,
      tealSoft: tealSoft ?? this.tealSoft,
      tealContrast: tealContrast ?? this.tealContrast,
      gold: gold ?? this.gold,
      goldSoft: goldSoft ?? this.goldSoft,
      forest: forest ?? this.forest,
      forestSoft: forestSoft ?? this.forestSoft,
      coral: coral ?? this.coral,
      coralSoft: coralSoft ?? this.coralSoft,
      muted: muted ?? this.muted,
      line: line ?? this.line,
      cardSurface: cardSurface ?? this.cardSurface,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      teal: Color.lerp(teal, other.teal, t)!,
      tealSoft: Color.lerp(tealSoft, other.tealSoft, t)!,
      tealContrast: Color.lerp(tealContrast, other.tealContrast, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldSoft: Color.lerp(goldSoft, other.goldSoft, t)!,
      forest: Color.lerp(forest, other.forest, t)!,
      forestSoft: Color.lerp(forestSoft, other.forestSoft, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      coralSoft: Color.lerp(coralSoft, other.coralSoft, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
    );
  }
}
