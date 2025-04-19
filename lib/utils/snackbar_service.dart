import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SnackBarService {
  static void showInsufficientPowerMessage(BuildContext context, {String? spellName, int? requiredPower}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          spellName != null 
            ? 'Insufficient power to cast $spellName (requires $requiredPower power)'
            : 'Insufficient power to cast this spell',
          style: TextStyle(color: AppTheme.accentColor),
        ),
        backgroundColor: Colors.orange[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  static void showSpellCastMessage(BuildContext context, String spellName, int cost) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          spellName == 'Power restored'
            ? 'Power restored to maximum ($cost power)'
            : 'Used $spellName ($cost power)',
        ),
        backgroundColor: AppTheme.greenColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }
} 