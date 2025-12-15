import 'package:flutter/material.dart';
import 'package:pffl_managment/features/admin/shared/providers/animated_fab_provider.dart';
import 'package:provider/provider.dart';

class AnimatedFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const AnimatedFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final fabProvider = Provider.of<AnimatedFABProvider>(context);
    
    return GestureDetector(
      onTap: () {
        if (fabProvider.isExtended) {
          onPressed();
        } else {
          fabProvider.toggleExtension();
        }
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF0F173E),
          borderRadius: BorderRadius.circular(16),
        
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 16),
            const Icon(
              Icons.add,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: fabProvider.isExtended
                  ? const Text(
                      'Create Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: fabProvider.isExtended
                  ? const SizedBox(width: 16)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}