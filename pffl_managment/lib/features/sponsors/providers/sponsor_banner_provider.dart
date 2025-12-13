import 'package:flutter/material.dart';
import 'dart:async';

class SponsorBannerProvider extends ChangeNotifier {
  int _currentPage = 0;
  Timer? _timer;
  bool _isAutoPlaying = false;

  int get currentPage => _currentPage;
  bool get isAutoPlaying => _isAutoPlaying;

  // Sponsor images
  final List<String> sponsorImages = [
    'assets/images/sponser/sponser1.png',
    'assets/images/sponser/sponser2.png',
    'assets/images/sponser/sponser3.png',
  ];

  SponsorBannerProvider() {
    // Start auto play when the provider is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startAutoPlay();
    });
  }

  void startAutoPlay() {
    // Prevent multiple timers
    if (_isAutoPlaying) {
      debugPrint('Auto play already started, skipping');
      return;
    }

    _isAutoPlaying = true;
    // Always cancel existing timer
    _timer?.cancel();

    debugPrint('Starting auto play timer with ${sponsorImages.length} images');
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (sponsorImages.isNotEmpty) {
        int nextPage = (_currentPage + 1) % sponsorImages.length;

        debugPrint(
          'Timer tick: Current page $_currentPage, Next page $nextPage, Image: ${sponsorImages[_currentPage]}',
        );

        // Update the current page
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