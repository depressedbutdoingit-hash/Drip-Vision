import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaPickerService {
  final _picker = ImagePicker();

  Future<bool> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  Future<File?> pickFromCamera() async {
    if (!await _requestPermission(ImageSource.camera)) return null;
    final picked = await _picker.pickImage(source: ImageSource.camera, maxWidth: 2048);
    return picked != null ? File(picked.path) : null;
  }

  Future<File?> pickFromGallery() async {
    if (!await _requestPermission(ImageSource.gallery)) return null;
    final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 2048);
    return picked != null ? File(picked.path) : null;
  }

  Future<List<File>> pickMultipleFromGallery() async {
    if (!await _requestPermission(ImageSource.gallery)) return [];
    final picked = await _picker.pickMultiImage(maxWidth: 2048);
    return picked.map((x) => File(x.path)).toList();
  }

  Future<File?> pickVideoFromGallery() async {
    final status = await Permission.videos.request();
    if (!status.isGranted) return null;
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    return picked != null ? File(picked.path) : null;
  }
}
