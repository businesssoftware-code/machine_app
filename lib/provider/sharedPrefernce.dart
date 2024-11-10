import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Key for storing station stages
  static const String _stationStagesKey = 'stationStages';

  // Save station stages to SharedPreferences
  Future<void> saveStationStages(Map<String, String> stationStages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stationStagesKey, jsonEncode(stationStages));
  }

  // Load station stages from SharedPreferences
  Future<Map<String, String>> loadStationStages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStages = prefs.getString(_stationStagesKey);
    if (savedStages != null) {
      return Map<String, String>.from(jsonDecode(savedStages));
    }
    return {
      'station1': 'vacant',
      'station2': 'vacant',
    }; // Default values if none exist
  }
}
