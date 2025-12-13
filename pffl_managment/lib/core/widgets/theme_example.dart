import 'package:flutter/material.dart';
import 'package:pffl_managment/core/constants/app_text_styles.dart';

class ThemeExample extends StatelessWidget {
  const ThemeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme & Text Styles Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display styles
            const Text('Display Styles', style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            const Text('Display Large', style: AppTextStyles.displayLarge),
            const SizedBox(height: 8),
            const Text('Display Medium', style: AppTextStyles.displayMedium),
            const SizedBox(height: 8),
            const Text('Display Small', style: AppTextStyles.displaySmall),
            const SizedBox(height: 24),

            // Headline styles
            const Text('Headline Styles', style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            const Text('Headline Large', style: AppTextStyles.headlineLarge),
            const SizedBox(height: 8),
            const Text('Headline Medium', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            const Text('Headline Small', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 24),

            // Title styles
            const Text('Title Styles', style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            const Text('Title Large', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            const Text('Title Medium', style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
             Text('Title Small', style: AppTextStyles.titleSmall),
            const SizedBox(height: 24),

            // Body styles
            const Text('Body Styles', style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            const Text(
              'Body Large - This is a sample of body large text style. It is used for primary body content.',
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Body Medium - This is a sample of body medium text style. It is used for secondary body content.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Body Small - This is a sample of body small text style. It is used for tertiary body content.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),

            // Label styles
            const Text('Label Styles', style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            const Text('Label Large', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            const Text('Label Medium', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            const Text('Label Small', style: AppTextStyles.labelSmall),
            const SizedBox(height: 24),

            // Button styles
            const Text('Button Styles', style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text(
                'Elevated Button',
                style: AppTextStyles.buttonLarge,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Text Button',
                style: AppTextStyles.buttonMedium,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              child: const Text(
                'Outlined Button',
                style: AppTextStyles.buttonMedium,
              ),
            ),
            const SizedBox(height: 24),

            // Other styles
            const Text('Other Styles', style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            const Text(
              'Caption - This is a caption text style.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 8),
            const Text('OVERLINE TEXT', style: AppTextStyles.overline),
          ],
        ),
      ),
    );
  }
}
