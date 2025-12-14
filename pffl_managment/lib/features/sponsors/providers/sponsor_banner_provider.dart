import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SponsorBannerProvider extends ChangeNotifier {
  int _currentPage = 0;
  Timer? _timer;
  bool _isAutoPlaying = false;
  bool _isLoading = true;

  int get currentPage => _currentPage;
  bool get isAutoPlaying => _isAutoPlaying;
  bool get isLoading => _isLoading;

  // Default sponsor images (fallback)
  static const List<String> _defaultImages = [
    'assets/images/sponser/sponser1.png',
    'assets/images/sponser/sponser2.png',
    'assets/images/sponser/sponser3.png',
  ];

  // Mutable sponsor images list
  List<Map<String, String>> _sponsorImages = [];

  List<Map<String, String>> get sponsorImages => _sponsorImages;

  // Get image paths for display
  List<String> get imagePaths =>
      _sponsorImages.map((img) => img['path']!).toList();

  SponsorBannerProvider() {
    _initializeImages();
  }

  Future<void> _initializeImages() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadSavedImages();
    } catch (e) {
      debugPrint('Error loading saved images: $e');
      _resetToDefaults();
    }

    _isLoading = false;
    notifyListeners();

    // Start auto play after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startAutoPlay();
    });
  }

  Future<void> _loadSavedImages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('sponsor_images');

    if (savedData != null && savedData.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(savedData);
        _sponsorImages = decoded
            .map((item) => Map<String, String>.from(item))
            .toList();
        debugPrint('Loaded ${_sponsorImages.length} saved sponsor images');
      } catch (e) {
        debugPrint('Error decoding saved images: $e');
        _resetToDefaults();
      }
    } else {
      _resetToDefaults();
    }
  }

  void _resetToDefaults() {
    _sponsorImages = _defaultImages
        .map((path) => {'type': 'asset', 'path': path})
        .toList();
    debugPrint('Reset to ${_sponsorImages.length} default images');
  }

  Future<void> updateSponsorImages(List<Map<String, String>> newImages) async {
    if (newImages.isEmpty) {
      debugPrint('Cannot update with empty images, keeping current');
      return;
    }

    // Stop timer before updating
    final wasPlaying = _isAutoPlaying;
    if (wasPlaying) {
      stopAutoPlay();
    }

    _sponsorImages = newImages;
    _currentPage = 0; // Reset to first image

    // Save to SharedPreferences
    await _saveImages();

    notifyListeners();

    // Restart timer if it was playing
    if (wasPlaying) {
      startAutoPlay();
    }

    debugPrint('Updated sponsor images: ${_sponsorImages.length} images');
  }

  Future<void> _saveImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(_sponsorImages);
      await prefs.setString('sponsor_images', jsonData);
      debugPrint('Saved sponsor images to SharedPreferences');
    } catch (e) {
      debugPrint('Error saving images: $e');
    }
  }

  Future<void> resetToDefaults() async {
    final wasPlaying = _isAutoPlaying;
    if (wasPlaying) {
      stopAutoPlay();
    }

    _resetToDefaults();
    await _saveImages();
    _currentPage = 0;

    notifyListeners();

    if (wasPlaying) {
      startAutoPlay();
    }

    debugPrint('Reset to default images');
  }

  void startAutoPlay() {
    // Prevent multiple timers
    if (_isAutoPlaying) {
      debugPrint('Auto play already started, skipping');
      return;
    }

    if (_sponsorImages.isEmpty) {
      debugPrint('No images to play');
      return;
    }

    _isAutoPlaying = true;
    _timer?.cancel();

    debugPrint('Starting auto play timer with ${_sponsorImages.length} images');
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_sponsorImages.isNotEmpty) {
        int nextPage = (_currentPage + 1) % _sponsorImages.length;
        _currentPage = nextPage;
        notifyListeners();
      }
    });
  }

  void stopAutoPlay() {
    debugPrint('Stopping auto play timer');
    _isAutoPlaying = false;
    _timer?.cancel();
  }

  @override
  void dispose() {
    debugPrint('Disposing SponsorBannerProvider');
    _isAutoPlaying = false;
    _timer?.cancel();
    super.dispose();
  }
}
