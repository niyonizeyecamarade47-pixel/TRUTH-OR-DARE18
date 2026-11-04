import 'package:flutter/material.dart';

enum DifficultyLevel { vanilla, playful, wild, extreme, couple }

extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.vanilla:
        return 'Vanilla';
      case DifficultyLevel.playful:
        return 'Playful';
      case DifficultyLevel.wild:
        return 'Wild';
      case DifficultyLevel.extreme:
        return 'Extreme';
      case DifficultyLevel.couple:
        return 'Couples Mode';
    }
  }

  int get levelValue => index + 1;

  Color get color {
    switch (this) {
      case DifficultyLevel.vanilla:
        return const Color(0xFF00FFFF);
      case DifficultyLevel.playful:
        return const Color(0xFF00FF80);
      case DifficultyLevel.wild:
        return const Color(0xFFFF8000);
      case DifficultyLevel.extreme:
        return const Color(0xFFFF0000);
      case DifficultyLevel.couple:
        return const Color(0xFFFF00FF);
    }
  }

  static DifficultyLevel fromString(String value) {
    final normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (normalized == 'wild') return DifficultyLevel.wild;
    if (normalized == 'extreme') return DifficultyLevel.extreme;
    if (normalized == 'couplesmode' || normalized == 'couplemode' || normalized == 'couples') {
      return DifficultyLevel.couple;
    }
    for (final level in DifficultyLevel.values) {
      final name = level.displayName.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
      if (name == normalized) return level;
    }
    return DifficultyLevel.playful;
  }
}
