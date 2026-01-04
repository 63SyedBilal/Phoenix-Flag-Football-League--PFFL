import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pffl_managment/core/widgets/dotted_border_widget.dart'; // Import your DottedBorderWidget

class LeagueDetailHeader extends StatelessWidget {
  final String leagueName;
  final String subtitle;
  final VoidCallback onBackPressed;
  final String? logoUrl;

  const LeagueDetailHeader({
    super.key,
    required this.leagueName,
    required this.subtitle,
    required this.onBackPressed,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 45,
                height: 45,
                child: (logoUrl != null && logoUrl!.isNotEmpty)
                    ? DottedBorderWidget(
                        shape: DottedBorderShape.circle,
                        strokeWidth: 1,
                        dashWidth: 2,
                        dashSpace: 2,
                        color: const Color(0xFF000000).withValues(alpha: 0.5),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: logoUrl!,
                              width: 39,
                              height: 39,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: const Color(0xFFE5E7EB),
                                child: const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFFE5E7EB),
                                child: const Center(
                                  child: Icon(
                                    Icons.sports,
                                    size: 20,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : DottedBorderWidget(
                        shape: DottedBorderShape.circle,
                        strokeWidth: 1,
                        dashWidth: 2,
                        dashSpace: 2,
                        color: const Color(0xFF000000).withValues(alpha: 0.5),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE5E7EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.sports,
                              size: 20,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leagueName,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(255, 99, 113, 143),
            ),
          ),
        ],
      ),
    );
  }
}
