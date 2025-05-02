import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/svg_service.dart';

class AvatarSelector extends StatefulWidget {
  final String? initialAvatarPath;
  final void Function(String?) onAvatarSelected;
  final double size;
  final bool editable;

  const AvatarSelector({
    super.key,
    this.initialAvatarPath,
    required this.onAvatarSelected,
    this.size = 150,
    this.editable = true,
  });

  @override
  State<AvatarSelector> createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  String? _avatarPath;
  final _picker = ImagePicker();
  final _svgService = SvgService();
  List<String> _availableSvgs = [];

  @override
  void initState() {
    super.initState();
    _avatarPath = widget.initialAvatarPath;
    _loadSelectableSvgs();
  }

  Future<void> _loadSelectableSvgs() async {
    final svgs = await _svgService.getSelectableSvgs();
    if (mounted) {
      setState(() {
        _availableSvgs = svgs;
      });
    }
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

  void _showSvgSelector() {
    if (_availableSvgs.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Icon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _availableSvgs.length,
                  itemBuilder: (context, index) {
                    final svgPath = _availableSvgs[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _avatarPath = svgPath;
                        });
                        widget.onAvatarSelected(svgPath);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _avatarPath == svgPath
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SvgPicture.asset(
                            'assets/svg/selectable/$svgPath',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (_avatarPath == null) {
      return _buildDefaultAvatar();
    }

    // Check if the path is an absolute path or contains the app's documents directory
    if (_avatarPath!.startsWith('/') || _avatarPath!.contains('app_flutter')) {
      try {
        // Try to load as an image file
        return Image.file(
          File(_avatarPath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        );
      } catch (e) {
        return _buildDefaultAvatar();
      }
    } else {
      // Handle SVG icons
      final isSelectableSvg = _availableSvgs.contains(_avatarPath!);
      final svgPath = isSelectableSvg 
          ? 'assets/svg/selectable/${_avatarPath!}'
          : 'assets/svg/${_avatarPath!.isNotEmpty ? _avatarPath! : 'unknown-face.svg'}';
      
      return SvgPicture.asset(
        svgPath,
        fit: BoxFit.cover,
        placeholderBuilder: (context) => _buildDefaultAvatar(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.editable ? _pickImage : null,
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
              child: _buildAvatarImage(),
            ),
          ),
        ),
        if (widget.editable) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
              if (_availableSvgs.isNotEmpty)
                TextButton.icon(
                  onPressed: _showSvgSelector,
                  icon: const Icon(Icons.image),
                  label: const Text('Icons'),
                ),
            ],
          ),
        ],
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