import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/background_controller.dart';
import '../models/background.dart';

/// Widget for editing character backgrounds
class BackgroundEditor extends ConsumerWidget {
  final void Function(Background)? onSave;

  const BackgroundEditor({super.key, this.onSave});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(backgroundEditorProvider);
    final controller = ref.read(backgroundEditorProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Template Selection
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Background Template',
                    helperText: 'Select a pre-written background or create your own',
                  ),
                  value: state.selectedTemplateId,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Custom Background'),
                    ),
                    ...state.availableTemplates.map(
                      (template) => DropdownMenuItem(
                        value: template.id,
                        child: Text(template.name),
                      ),
                    ),
                  ],
                  onChanged: (String? value) {
                    if (value == null) {
                      controller.createCustomBackground(
                        name: '',
                        description: '',
                        placeOfBirth: '',
                        parents: '',
                        siblings: '',
                      );
                      if (onSave != null) {
                        onSave!(controller.saveBackground()!);
                      }
                    } else {
                      controller.selectTemplate(value);
                      // Automatically save when template is selected
                      if (onSave != null) {
                        onSave!(controller.saveBackground()!);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Background Fields
                if (state.currentBackground != null) ...[
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      helperText: 'The name of your background',
                    ),
                    initialValue: state.currentBackground!.name,
                    onChanged: (value) {
                      controller.updateBackground(name: value);
                      if (onSave != null) {
                        onSave!(controller.saveBackground()!);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      helperText: 'Describe your character\'s background',
                      alignLabelWithHint: true,
                    ),
                    initialValue: state.currentBackground!.description,
                    onChanged: (value) {
                      controller.updateBackground(description: value);
                      if (onSave != null) {
                        onSave!(controller.saveBackground()!);
                      }
                    },
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Place of Birth',
                      helperText: 'Where your character was born',
                    ),
                    initialValue: state.currentBackground!.placeOfBirth,
                    onChanged: (value) {
                      controller.updateBackground(placeOfBirth: value);
                      if (onSave != null) {
                        onSave!(controller.saveBackground()!);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Parents',
                      helperText: 'Information about your character\'s parents',
                    ),
                    initialValue: state.currentBackground!.parents,
                    onChanged: (value) {
                      controller.updateBackground(parents: value);
                      if (onSave != null) {
                        onSave!(controller.saveBackground()!);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Siblings',
                      helperText: 'Information about your character\'s siblings',
                    ),
                    initialValue: state.currentBackground!.siblings,
                    onChanged: (value) {
                      controller.updateBackground(siblings: value);
                      if (onSave != null) {
                        onSave!(controller.saveBackground()!);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
} 