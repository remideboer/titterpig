import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class AvatarSelector extends StatefulWidget {
  final String? initialAvatarPath;
  final void Function(String?) onAvatarSelected;
  final double size;

  const AvatarSelector({
    super.key,
    this.initialAvatarPath,
    required this.onAvatarSelected,
    this.size = 150,
  });

  @override
  State<AvatarSelector> createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  String? _avatarPath;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _avatarPath = widget.initialAvatarPath;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512, // Reasonable size for avatars
        maxHeight: 512,
      );

      if (image == null) return;

      // Validate file extension
      final extension = path.extension(image.path).toLowerCase();
      if (!['.png', '.jpg', '.jpeg', '.svg'].contains(extension)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid file format. Please use PNG, JPG, JPEG, or SVG.'),
            ),
          );
        }
        return;
      }

      // Copy image to app's documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'avatar_${const Uuid().v4()}$extension';
      final savedImage = await File(image.path).copy('${appDir.path}/$fileName');

      setState(() {
        _avatarPath = savedImage.path;
      });
      widget.onAvatarSelected(_avatarPath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _avatarPath != null
                  ? Image.file(
                      File(_avatarPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to select avatar',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: widget.size * 0.6,
      color: Theme.of(context).colorScheme.primary,
    );
  }
} 