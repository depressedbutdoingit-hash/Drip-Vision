import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Phone media intake — gallery + camera for stills and video.
/// Edit Bay and Character Lab both use this so continuity starts from real footage.
class MediaPickerService {
  final _picker = ImagePicker();

  Future<bool> _photosOk() async {
    final status = await Permission.photos.request();
    return status.isGranted || status.isLimited;
  }

  Future<bool> _videosOk() async {
    final status = await Permission.videos.request();
    if (status.isGranted) return true;
    // Some Android builds fold video under photos
    return _photosOk();
  }

  Future<bool> _cameraOk() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> _micOk() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<File?> pickImageFromCamera() async {
    if (!await _cameraOk()) return null;
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 2048,
      imageQuality: 92,
    );
    return picked != null ? File(picked.path) : null;
  }

  Future<File?> pickImageFromGallery() async {
    if (!await _photosOk()) return null;
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 92,
    );
    return picked != null ? File(picked.path) : null;
  }

  /// Backward-compatible aliases
  Future<File?> pickFromCamera() => pickImageFromCamera();
  Future<File?> pickFromGallery() => pickImageFromGallery();

  Future<List<File>> pickMultipleFromGallery() async {
    if (!await _photosOk()) return [];
    final picked = await _picker.pickMultiImage(maxWidth: 2048, imageQuality: 92);
    return picked.map((x) => File(x.path)).toList();
  }

  Future<File?> pickVideoFromGallery() async {
    if (!await _videosOk()) return null;
    final picked = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 10),
    );
    return picked != null ? File(picked.path) : null;
  }

  /// Record video on device — for continuity capture on set / phone.
  Future<File?> pickVideoFromCamera() async {
    if (!await _cameraOk()) return null;
    await _micOk(); // best-effort audio
    final picked = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 3),
    );
    return picked != null ? File(picked.path) : null;
  }
}
