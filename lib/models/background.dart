import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

part 'background.freezed.dart';
part 'background.g.dart';

/// Represents a character's background, which can be either custom or based on a template
@freezed
class Background with _$Background {
  const Background._();

  const factory Background({
    /// Unique identifier for the background
    required String id,
    
    /// Name of the background (e.g., "Noble", "Merchant")
    required String name,
    
    /// Detailed description of the background
    required String description,
    
    /// Character's place of birth
    required String placeOfBirth,
    
    /// Description of character's parents
    required String parents,
    
    /// Description of character's siblings
    required String siblings,
    
    /// ID of the template this background is based on (null if completely custom)
    String? templateId,
    
    /// Whether this background has been customized from its template
    @Default(false) bool isCustomized,
  }) = _Background;

  /// Creates a completely custom background
  factory Background.custom({
    required String name,
    required String description,
    required String placeOfBirth,
    required String parents,
    required String siblings,
  }) {
    return Background(
      id: const Uuid().v4(),
      name: name,
      description: description,
      placeOfBirth: placeOfBirth,
      parents: parents,
      siblings: siblings,
    );
  }

  /// Creates a background from a template
  factory Background.fromTemplate({
    required Background template,
    bool customize = false,
  }) {
    return Background(
      id: const Uuid().v4(),
      name: template.name,
      description: template.description,
      placeOfBirth: template.placeOfBirth,
      parents: template.parents,
      siblings: template.siblings,
      templateId: customize ? template.id : null,
      isCustomized: customize,
    );
  }

  /// Converts the background to a customized version
  Background toCustomized() {
    if (isCustomized) return this;
    return copyWith(
      templateId: id,
      id: const Uuid().v4(),
      isCustomized: true,
    );
  }

  factory Background.fromJson(Map<String, dynamic> json) =>
      _$BackgroundFromJson(json);

  factory Background.empty() => const Background(
    id: '',
    name: '',
    description: '',
    placeOfBirth: '',
    parents: '',
    siblings: '',
  );
} 