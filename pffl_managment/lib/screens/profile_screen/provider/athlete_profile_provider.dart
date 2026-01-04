import 'package:flutter/material.dart';
import 'package:pffl_managment/screens/profile_screen/provider/base_profile_provider.dart';

abstract class AthleteProfileProvider extends BaseProfileProvider {
  final positionController = TextEditingController();
  final jerseyNumberController = TextEditingController();
  final emergencyContactNameController = TextEditingController();
  final emergencyPhoneController = TextEditingController();

  AthleteProfileProvider(super.prefsProvider);

  @override
  void dispose() {
    positionController.dispose();
    jerseyNumberController.dispose();
    emergencyContactNameController.dispose();
    emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  void initialize() {
    super.initialize();
    positionController.text = prefsProvider.position ?? '';
    jerseyNumberController.text = prefsProvider.jerseyNumber ?? '';
    emergencyContactNameController.text =
        prefsProvider.emergencyContactName ?? '';
    emergencyPhoneController.text = prefsProvider.emergencyPhone ?? '';
    notifyListeners();
  }

  @override
  Map<String, dynamic> getProfileData(String? finalImageUrl) {
    final data = super.getProfileData(finalImageUrl);
    data.addAll({
      'position': positionController.text.trim(),
      'jerseyNumber':
          int.tryParse(jerseyNumberController.text.trim()) ??
          jerseyNumberController.text.trim(),
      'emergencyContactName': emergencyContactNameController.text.trim(),
      'emergencyPhone': emergencyPhoneController.text.trim(),
    });
    return data;
  }

  @override
  Future<void> updateLocalOnly(Map<String, dynamic> data) async {
    await super.updateLocalOnly(data);
    if (data.containsKey('position'))
      await prefsProvider.setPosition(data['position']);
    if (data.containsKey('jerseyNumber')) {
      await prefsProvider.setJerseyNumber(data['jerseyNumber'].toString());
    }
    if (data.containsKey('emergencyContactName')) {
      await prefsProvider.setEmergencyContactName(data['emergencyContactName']);
    }
    if (data.containsKey('emergencyPhone')) {
      await prefsProvider.setEmergencyPhone(data['emergencyPhone']);
    }

    positionController.text = prefsProvider.position ?? '';
    jerseyNumberController.text = prefsProvider.jerseyNumber ?? '';
    emergencyContactNameController.text =
        prefsProvider.emergencyContactName ?? '';
    emergencyPhoneController.text = prefsProvider.emergencyPhone ?? '';
  }
}
