import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:pffl_managment/core/services/admin_service.dart';
import 'package:pffl_managment/core/services/auth_service.dart';

class SponsorScreenProvider extends ChangeNotifier {
  final List<Map<String, String>?> _uploadedImages = [null, null, null];
  final List<TextEditingController> _urlControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final List<String?> _validationErrors = [null, null, null];
  bool _isSaving = false;

  List<Map<String, String>?> get uploadedImages => _uploadedImages;
  List<TextEditingController> get urlControllers => _urlControllers;
  List<String?> get validationErrors => _validationErrors;
  bool get isSaving => _isSaving;

  // Get preview image for a slot
  Map<String, String>? getPreviewImage(int slotNumber) {
    if (slotNumber < 1 || slotNumber > 3) return null;
    final index = slotNumber - 1;

    // Priority: uploaded file > URL > null
    if (_uploadedImages[index] != null) {
      return _uploadedImages[index];
    }

    final url = _urlControllers[index].text.trim();
    if (url.isNotEmpty && _isValidUrl(url)) {
      return {'type': 'network', 'path': url};
    }

    return null;
  }

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Future<void> pickImage(int slotNumber) async {
    if (slotNumber < 1 || slotNumber > 3) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);

        // Check file size (max 10MB to match other image uploads)
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          _validationErrors[slotNumber - 1] = 'Image must be less than 10MB';
          notifyListeners();
          return;
        }

        _uploadedImages[slotNumber - 1] = {'type': 'file', 'path': filePath};
        _validationErrors[slotNumber - 1] = null;

        // Clear URL if file is uploaded
        _urlControllers[slotNumber - 1].clear();

        notifyListeners();
      }
    } catch (e) {
      _validationErrors[slotNumber - 1] = 'Failed to pick image: $e';
      notifyListeners();
    }
  }

  void validateUrl(int slotNumber) {
    if (slotNumber < 1 || slotNumber > 3) return;
    final index = slotNumber - 1;
    final url = _urlControllers[index].text.trim();

    if (url.isEmpty) {
      _validationErrors[index] = null;
    } else if (!_isValidUrl(url)) {
      _validationErrors[index] = 'Invalid URL format';
    } else {
      _validationErrors[index] = null;
    }
    notifyListeners();
  }

  void clearSlot(int slotNumber) {
    if (slotNumber < 1 || slotNumber > 3) return;
    final index = slotNumber - 1;

    _uploadedImages[index] = null;
    _urlControllers[index].clear();
    _validationErrors[index] = null;
    notifyListeners();
  }

  List<Map<String, String>> getImagesForSave() {
    final List<Map<String, String>> images = [];

    for (int i = 0; i < 3; i++) {
      // Priority: uploaded file > URL > default
      if (_uploadedImages[i] != null) {
        images.add(_uploadedImages[i]!);
      } else {
        final url = _urlControllers[i].text.trim();
        if (url.isNotEmpty && _isValidUrl(url)) {
          images.add({'type': 'network', 'path': url});
        } else {
          // Use default image
          images.add({
            'type': 'asset',
            'path': 'assets/images/sponser/sponser${i + 1}.png',
          });
        }
      }
    }

    return images;
  }

  Future<bool> saveSponsors() async {
    // Validate all URLs
    for (int i = 0; i < 3; i++) {
      validateUrl(i + 1);
    }

    // Check if there are any validation errors
    if (_validationErrors.any((error) => error != null)) {
      return false;
    }

    _isSaving = true;
    notifyListeners();

    try {
      // Upload sponsor images to backend
      final uploadedUrls = <String>[];

      for (int i = 0; i < 3; i++) {
        if (_uploadedImages[i] != null && _uploadedImages[i]!['type'] == 'file') {
          try {
            final filePath = _uploadedImages[i]!['path']!;
            final imageFile = File(filePath);

            if (await imageFile.exists()) {
              final uploadedUrl = await AdminService.uploadImage(imageFile);
              if (uploadedUrl != null) {
                uploadedUrls.add(uploadedUrl);
              } else {
                // Use default image if upload fails
                uploadedUrls.add('assets/images/sponser/sponser${i + 1}.png');
              }
            }
          } catch (e) {
            // Use default image if upload fails
            uploadedUrls.add('assets/images/sponser/sponser${i + 1}.png');
          }
        } else if (_urlControllers[i].text.trim().isNotEmpty) {
          // Use URL if provided
          uploadedUrls.add(_urlControllers[i].text.trim());
        } else {
          // Use default image
          uploadedUrls.add('assets/images/sponser/sponser${i + 1}.png');
        }
      }

      // Save uploaded URLs to backend
      try {
        final dio = await AuthService.getWorkingDio();
        final sponsorData = {
          'sponsorImages': uploadedUrls,
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final response = await dio.post('/admin/sponsors', data: sponsorData);

        if (response.statusCode == 200 || response.statusCode == 201) {
        } else {
          throw Exception('Failed to save sponsor images');
        }
      } catch (e) {
        // Don't fail the entire operation for this
      }
      for (int i = 0; i < uploadedUrls.length; i++) {
      }

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    for (var controller in _urlControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

