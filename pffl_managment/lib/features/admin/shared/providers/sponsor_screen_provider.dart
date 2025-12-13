import 'package:flutter/material.dart';

class SponsorScreenProvider extends ChangeNotifier {
  final List<String?> _uploadedImages = [null, null, null];
  final List<TextEditingController> _urlControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  
  List<String?> get uploadedImages => _uploadedImages;
  List<TextEditingController> get urlControllers => _urlControllers;
  
  void setUploadedImage(int slotNumber, String imagePath) {
    if (slotNumber >= 1 && slotNumber <= 3) {
      _uploadedImages[slotNumber - 1] = imagePath;
      notifyListeners();
    }
  }
  
  void saveSponsors() {
    // Handle save logic here
    // For now, just notify listeners that save was attempted
    notifyListeners();
  }
  
  @override
  void dispose() {
    for (var controller in _urlControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}