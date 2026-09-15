import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/media_picker_service.dart';

class MediaPickerButton extends StatelessWidget {
  final void Function(File file) onMediaSelected;
  final void Function(List<File> files)? onMultipleSelected;
  final bool allowMultiple;
  final bool allowCamera;
  final IconData icon;
  final String label;

  const MediaPickerButton({
    super.key,
    required this.onMediaSelected,
    this.onMultipleSelected,
    this.allowMultiple = false,
    this.allowCamera = true,
    this.icon = Icons.add_photo_alternate_outlined,
    this.label = 'Add Media',
  });

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DripTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (allowCamera)
                _PickerTile(
                  icon: Icons.camera_alt_outlined,
                  label: 'Take Photo',
                  onTap: () async {
                    Navigator.pop(ctx);
                    final file = await MediaPickerService().pickFromCamera();
                    if (file != null) onMediaSelected(file);
                  },
                ),
              _PickerTile(
                icon: Icons.photo_library_outlined,
                label: allowMultiple ? 'Select Photos' : 'Photo Library',
                onTap: () async {
                  Navigator.pop(ctx);
                  if (allowMultiple) {
                    final files = await MediaPickerService().pickMultipleFromGallery();
                    if (files.isNotEmpty) {
                      onMultipleSelected?.call(files);
                    }
                  } else {
                    final file = await MediaPickerService().pickFromGallery();
                    if (file != null) onMediaSelected(file);
                  }
                },
              ),
              _PickerTile(
                icon: Icons.videocam_outlined,
                label: 'Choose Video',
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await MediaPickerService().pickVideoFromGallery();
                  if (file != null) onMediaSelected(file);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: DripTheme.surfaceLight.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DripTheme.cosmicTeal.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: DripTheme.cosmicTeal.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: DripTheme.nebulaCyan, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: DripTheme.chrome,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: DripTheme.nebulaCyan),
      title: Text(label, style: const TextStyle(color: DripTheme.chrome)),
      onTap: onTap,
    );
  }
}
