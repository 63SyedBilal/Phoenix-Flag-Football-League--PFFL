import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/sponsors/providers/sponsor_banner_provider.dart';
import 'dart:io';

class SponsorBannerScreen extends StatelessWidget {
  const SponsorBannerScreen({super.key});

  Widget _buildImage(Map<String, String> imageData) {
    final type = imageData['type'] ?? 'asset';
    final path = imageData['path'] ?? '';

    switch (type) {
      case 'file':
        return Image.file(
          File(path),
          width: 380,
          height: 110,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Failed to load file image: $path, Error: $error');
            return _buildPlaceholder();
          },
        );
      case 'network':
        return Image.network(
          path,
          width: 380,
          height: 110,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                color: const Color(0xFF0F173E),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Failed to load network image: $path, Error: $error');
            return _buildPlaceholder();
          },
        );
      case 'asset':
      default:
        return Image.asset(
          path,
          width: 380,
          height: 110,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Failed to load asset image: $path, Error: $error');
            return _buildPlaceholder();
          },
        );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 48, color: Color(0xFF9CA3AF)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<SponsorBannerProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Container(
                width: 380,
                height: 110,
                margin: const EdgeInsets.only(bottom: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0F173E)),
                ),
              );
            }

            if (provider.sponsorImages.isEmpty) {
              return Container(
                width: 380,
                height: 110,
                margin: const EdgeInsets.only(bottom: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: _buildPlaceholder(),
              );
            }

            return Container(
              width: 380,
              height: 110,
              margin: const EdgeInsets.only(bottom: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImage(
                  provider.sponsorImages[provider.currentPage],
                ),
              ),
            );
          },
        ),
        // Indicator dots
        Consumer<SponsorBannerProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading || provider.sponsorImages.isEmpty) {
              return const SizedBox.shrink();
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(provider.sponsorImages.length, (
                int index,
              ) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: provider.currentPage == index
                        ? const Color(0xFF0F173E) // Active dot color
                        : Colors.grey, // Inactive dot color
                  ),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
