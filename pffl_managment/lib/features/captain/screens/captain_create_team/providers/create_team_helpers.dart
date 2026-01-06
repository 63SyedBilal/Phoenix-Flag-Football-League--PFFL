import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pffl_managment/config/app_config.dart';
import 'package:pffl_managment/core/providers/user_preference_provider.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:pffl_managment/core/services/team_service.dart';

class CreateTeamHelpers {
  static Future<File?> compressLogoIfNeeded(File original) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/team_logo_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        original.absolute.path,
        targetPath,
        quality: 80,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );

      return result != null ? File(result.path) : original;
    } catch (_) {
      return original;
    }
  }

  static Future<void> linkCaptainToTeam(String teamId) async {
    try {
      final dio = await AuthService.getWorkingDio();
      final payload = <String, dynamic>{'teamId': teamId};
      try {
        await dio.patch(AppConfig.profileEndpoint, data: payload);
      } on DioException catch (e) {
        if (e.response?.statusCode == 405) {
          await dio.put(AppConfig.profileEndpoint, data: payload);
        } else {
          rethrow;
        }
      }
    } catch (_) {
      // Best-effort: do not block team creation on profile linking failures.
    }
  }

  static Future<bool> checkTeamCreation(UserPreferenceProvider userPrefs) async {
    try {
      if (userPrefs.hasCreatedTeam) {
        return true;
      }

      final hasTeam = await TeamService.hasTeam();
      if (hasTeam) {
        await userPrefs.setHasCreatedTeam(true);
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}
