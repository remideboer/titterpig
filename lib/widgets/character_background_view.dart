import 'package:flutter/material.dart';
import '../models/background.dart';
import '../theme/app_theme.dart';

class CharacterBackgroundView extends StatelessWidget {
  final Background? background;
  final VoidCallback onEdit;

  const CharacterBackgroundView({
    super.key,
    required this.background,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (background == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_edu,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No background information available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
              label: const Text('Add Background'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            background!.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Description',
            content: background!.description,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Place of Birth',
            content: background!.placeOfBirth,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Parents',
            content: background!.parents,
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Siblings',
            content: background!.siblings,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.highlightColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(content.isEmpty ? 'Not specified' : content),
        ],
      ),
    );
  }
} 