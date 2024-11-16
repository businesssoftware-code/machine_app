import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _stationStagesKey = 'stationStages';

  // ValueNotifier to observe changes in station stages
  ValueNotifier<Map<String, String>> stationStagesNotifier =
      ValueNotifier<Map<String, String>>({
    'station1': 'vacant',
    'station2': 'vacant',
    'station1DrinkName': 'vacant',
    'station2DrinkName': 'vacant',
  });

  PreferencesService() {
    _loadStationStages();
  }

  Future<void> _loadStationStages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStages = prefs.getString(_stationStagesKey);
    if (savedStages != null) {
      stationStagesNotifier.value =
          Map<String, String>.from(jsonDecode(savedStages));
    }
  }

  Future<void> _saveStationStages(Map<String, String> stationStages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stationStagesKey, jsonEncode(stationStages));
  }

  void updateStationStage(String station, String stage) {
    stationStagesNotifier.value = {
      ...stationStagesNotifier.value,
      station: stage,
    };
    _saveStationStages(stationStagesNotifier.value);
  }
}
