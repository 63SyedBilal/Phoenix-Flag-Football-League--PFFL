import 'package:url_launcher/url_launcher.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:flutter/foundation.dart';

class UrlLauncherService {
  /// Launches the privacy policy URL in the default browser
  static Future<void> launchPrivacyPolicy() async {
    final Uri url = Uri.parse(AppConfig.privacyPolicyUrl);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching $url: $e');
    }
  }

  /// Launches a custom URL
  static Future<void> launchCustomUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching $url: $e');
    }
  }
}
