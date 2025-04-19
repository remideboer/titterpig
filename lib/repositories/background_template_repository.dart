import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/background.dart';

/// Provider for the background template repository
final backgroundTemplateRepositoryProvider = Provider<BackgroundTemplateRepository>(
  (ref) => BackgroundTemplateRepository(),
);

/// Repository for managing background templates
class BackgroundTemplateRepository {
  /// List of predefined background templates
  final List<Background> _templates = [
    Background(
      id: 'noble',
      name: 'Noble',
      description: 'Born into wealth and privilege, you were raised in a noble house. '
          'Your upbringing has given you a strong sense of entitlement and authority, '
          'but also a deep understanding of leadership and responsibility.',
      placeOfBirth: 'In the family manor',
      parents: 'Noble lord and lady of a prestigious house',
      siblings: 'Two siblings, both groomed for leadership',
    ),
    Background(
      id: 'merchant',
      name: 'Merchant',
      description: 'Raised in a family of traders, you learned the art of negotiation '
          'and commerce from an early age. Your travels with merchant caravans have '
          'given you a broad perspective of the world.',
      placeOfBirth: 'In a bustling trade city',
      parents: 'Successful merchant parents who run a trading company',
      siblings: 'One older sibling who manages the family business',
    ),
    // Add more templates as needed
  ];

  /// Get all available background templates
  List<Background> getAllTemplates() => List.unmodifiable(_templates);

  /// Get a specific template by ID
  Background? getTemplateById(String id) {
    try {
      return _templates.firstWhere((template) => template.id == id);
    } catch (_) {
      return null;
    }
  }
} 