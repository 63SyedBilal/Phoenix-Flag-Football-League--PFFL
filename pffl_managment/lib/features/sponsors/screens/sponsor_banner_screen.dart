import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/features/sponsors/providers/sponsor_banner_provider.dart';

class SponsorBannerScreen extends StatelessWidget {
  const SponsorBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Column(
        children: [
          Expanded(
            child: Consumer<SponsorBannerProvider>(
              builder: (context, provider, child) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      provider.sponsorImages[provider.currentPage],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Failed to load image: ${provider.sponsorImages[provider.currentPage]}, Error: $error');
                        return Container(
                          color:
                              Colors.primaries[provider.currentPage %
                                  Colors.primaries.length],
                          child: Center(
                            child: Text(
                              'Sponsor ${provider.currentPage + 1}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          // Indicator dots
          Consumer<SponsorBannerProvider>(
            builder: (context, provider, child) {
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}