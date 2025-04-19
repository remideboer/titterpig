import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/background.dart';
import '../repositories/background_template_repository.dart';

/// State for the background editor
class BackgroundEditorState {
  final Background? currentBackground;
  final String? selectedTemplateId;
  final bool isEditing;
  final List<Background> availableTemplates;

  const BackgroundEditorState({
    this.currentBackground,
    this.selectedTemplateId,
    this.isEditing = false,
    this.availableTemplates = const [],
  });

  BackgroundEditorState copyWith({
    Background? currentBackground,
    String? selectedTemplateId,
    bool? isEditing,
    List<Background>? availableTemplates,
  }) {
    return BackgroundEditorState(
      currentBackground: currentBackground ?? this.currentBackground,
      selectedTemplateId: selectedTemplateId ?? this.selectedTemplateId,
      isEditing: isEditing ?? this.isEditing,
      availableTemplates: availableTemplates ?? this.availableTemplates,
    );
  }
}

/// Provider for the background editor state
final backgroundEditorProvider = StateNotifierProvider<BackgroundEditorController, BackgroundEditorState>(
  (ref) => BackgroundEditorController(ref.watch(backgroundTemplateRepositoryProvider)),
);

/// Controller for managing background selection and editing
class BackgroundEditorController extends StateNotifier<BackgroundEditorState> {
  final BackgroundTemplateRepository _templateRepository;

  BackgroundEditorController(this._templateRepository)
      : super(BackgroundEditorState(
          availableTemplates: _templateRepository.getAllTemplates(),
        ));

  /// Select a template background
  void selectTemplate(String templateId) {
    final template = _templateRepository.getTemplateById(templateId);
    if (template == null) return;

    state = state.copyWith(
      currentBackground: Background.fromTemplate(template: template),
      selectedTemplateId: templateId,
      isEditing: false,
    );
  }

  /// Start editing the current background
  void startEditing() {
    if (state.currentBackground == null) return;

    final background = state.currentBackground!;
    if (!background.isCustomized && state.selectedTemplateId != null) {
      // Convert to customized version if editing a template
      state = state.copyWith(
        currentBackground: background.toCustomized(),
        isEditing: true,
      );
    } else {
      state = state.copyWith(isEditing: true);
    }
  }

  /// Update the current background
  void updateBackground({
    String? name,
    String? description,
    String? placeOfBirth,
    String? parents,
    String? siblings,
  }) {
    if (state.currentBackground == null || !state.isEditing) return;

    state = state.copyWith(
      currentBackground: state.currentBackground!.copyWith(
        name: name ?? state.currentBackground!.name,
        description: description ?? state.currentBackground!.description,
        placeOfBirth: placeOfBirth ?? state.currentBackground!.placeOfBirth,
        parents: parents ?? state.currentBackground!.parents,
        siblings: siblings ?? state.currentBackground!.siblings,
      ),
    );
  }

  /// Create a new custom background
  void createCustomBackground({
    required String name,
    required String description,
    required String placeOfBirth,
    required String parents,
    required String siblings,
  }) {
    state = state.copyWith(
      currentBackground: Background.custom(
        name: name,
        description: description,
        placeOfBirth: placeOfBirth,
        parents: parents,
        siblings: siblings,
      ),
      selectedTemplateId: null,
      isEditing: true,
    );
  }

  /// Save the current background
  Background? saveBackground() {
    final background = state.currentBackground;
    if (background == null) return null;

    state = state.copyWith(isEditing: false);
    return background;
  }

  /// Cancel editing
  void cancelEditing() {
    if (!state.isEditing) return;

    if (state.selectedTemplateId != null) {
      // Revert to template
      selectTemplate(state.selectedTemplateId!);
    } else {
      state = state.copyWith(isEditing: false);
    }
  }
} 