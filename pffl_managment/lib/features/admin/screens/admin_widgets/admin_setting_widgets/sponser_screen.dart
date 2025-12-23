import 'package:flutter/material.dart';
import 'package:pffl_managment/core/widgets/arrow_back_button.dart';
import 'package:pffl_managment/features/admin/shared/providers/sponsor_screen_provider.dart';
import 'package:pffl_managment/features/sponsors/providers/sponsor_banner_provider.dart';
import 'package:provider/provider.dart';
import 'package:pffl_managment/core/widgets/custom_text_field.dart';
import 'dart:io';

class SponserScreen extends StatelessWidget {
  const SponserScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(leading: ArrowBackButton()),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Sponsors',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serotiva',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage ads that appear across the mobile app.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2E2E2E),
                        ),
                      ),
                      const SizedBox(height: 18),
                      AdSlotSection(slotNumber: 1),
                      const SizedBox(height: 18),
                      AdSlotSection(slotNumber: 2),
                      const SizedBox(height: 18),
                      AdSlotSection(slotNumber: 3),
                      const SizedBox(height: 18),
                      Consumer<SponsorScreenProvider>(
                        builder: (context, provider, child) {
                          return SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: provider.isSaving
                                  ? null
                                  : () async {
                                      final success = await provider
                                          .saveSponsors();

                                      if (success) {
                                        // Get images and update SponsorBannerProvider
                                        final images = provider
                                            .getImagesForSave();
                                        if (context.mounted) {
                                          await context
                                              .read<SponsorBannerProvider>()
                                              .updateSponsorImages(images);

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Sponsors saved and updated successfully!',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please fix validation errors',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F173E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(200),
                                ),
                                elevation: 0,
                                disabledBackgroundColor: const Color(
                                  0xFF0F173E,
                                ).withValues(alpha: 0.5),
                              ),
                              child: provider.isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Save',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.black, width: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdSlotSection extends StatelessWidget {
  final int slotNumber;

  const AdSlotSection({Key? key, required this.slotNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SponsorScreenProvider>(
      builder: (context, provider, child) {
        final previewImage = provider.getPreviewImage(slotNumber);
        final error = provider.validationErrors[slotNumber - 1];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ad Slot ${slotNumber.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thumbnail preview',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                ThumbnailUploadWidget(
                  slotNumber: slotNumber,
                  previewImage: previewImage,
                  onUpload: () => provider.pickImage(slotNumber),
                  onClear: previewImage != null
                      ? () => provider.clearSlot(slotNumber)
                      : null,
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    error,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),

            // Redirect URL
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Redirect URL',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                CustomTextField(
                  controller: provider.urlControllers[slotNumber - 1],
                  hintText: 'Enter Url',
                  onChanged: (_) => provider.validateUrl(slotNumber),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class ThumbnailUploadWidget extends StatelessWidget {
  final int slotNumber;
  final Map<String, String>? previewImage;
  final VoidCallback onUpload;
  final VoidCallback? onClear;

  const ThumbnailUploadWidget({
    Key? key,
    required this.slotNumber,
    this.previewImage,
    required this.onUpload,
    this.onClear,
  }) : super(key: key);

  Widget _buildPreview() {
    if (previewImage == null) return const SizedBox.shrink();

    final type = previewImage!['type'] ?? 'asset';
    final path = previewImage!['path'] ?? '';

    Widget imageWidget;

    switch (type) {
      case 'file':
        imageWidget = Image.file(
          File(path),
          width: 380,
          height: 110,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red);
          },
        );
        break;
      case 'network':
        imageWidget = Image.network(
          path,
          width: 380,
          height: 110,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red);
          },
        );
        break;
      default:
        return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: previewImage != null
          ? Stack(
              children: [
                Positioned.fill(child: _buildPreview()),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      if (onClear != null)
                        IconButton(
                          onPressed: onClear,
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.6,
                            ),
                            padding: const EdgeInsets.all(4),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )
          : DashedBorderPainter(
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: onUpload,
                  icon: const Icon(
                    Icons.upload_outlined,
                    size: 12,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Upload',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF010101),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
    );
  }
}

class DashedBorderPainter extends StatelessWidget {
  final Widget child;

  const DashedBorderPainter({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DashedBorderPainter(), child: child);
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    final path = Path();

    // Top border
    double startX = 0;
    while (startX < size.width) {
      path.moveTo(startX, 0);
      path.lineTo(startX + dashWidth, 0);
      startX += dashWidth + dashSpace;
    }

    // Right border
    double startY = 0;
    while (startY < size.height) {
      path.moveTo(size.width, startY);
      path.lineTo(size.width, startY + dashWidth);
      startY += dashWidth + dashSpace;
    }

    // Bottom border
    startX = size.width;
    while (startX > 0) {
      path.moveTo(startX, size.height);
      path.lineTo(startX - dashWidth, size.height);
      startX -= dashWidth + dashSpace;
    }

    // Left border
    startY = size.height;
    while (startY > 0) {
      path.moveTo(0, startY);
      path.lineTo(0, startY - dashWidth);
      startY -= dashWidth + dashSpace;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
