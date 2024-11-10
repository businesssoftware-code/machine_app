import 'package:machine_basil/controller/ValueNotifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> canPrepareDrink(int requiredMilk, int requiredWater,
    int requiredCurd, int requiredKoolM) async {
  final prefs = await SharedPreferences.getInstance();

  // Get stored quantities
  final milk = prefs.getInt('Milk') ?? 0;
  final water = prefs.getInt('Water') ?? 0;
  final curd = prefs.getInt('Curd') ?? 0;
  final koolM = prefs.getInt('Kool-M') ?? 0;

  // Check if all required ingredients are available
  return (requiredMilk == 0 || (milk - 400) >= requiredMilk) &&
      (requiredWater == 0 || (water - 400) >= requiredWater) &&
      (requiredCurd == 0 || (curd - 400) >= requiredCurd) &&
      (requiredKoolM == 0 || (koolM - 400) >= requiredKoolM);
}

Future<void> updateIngredientQuantities(
    int reqMilk, int reqWater, int reqCurd, int reqkoolM) async {
  final prefs = await SharedPreferences.getInstance();

  // Subtract required quantities after preparation
  final milk = (prefs.getInt('Milk') ?? 0) - reqMilk;
  final water = (prefs.getInt('Water') ?? 0) - reqWater;
  final curd = (prefs.getInt('Curd') ?? 0) - reqCurd;
  final koolM = (prefs.getInt('Kool-M') ?? 0) - reqkoolM;

  await prefs.setInt('Milk', milk);
  await prefs.setInt('Water', water);
  await prefs.setInt('Curd', curd);
  await prefs.setInt('Kool-M', koolM);

  quantityNotifier.value = {
    'Milk': milk,
    'Water': water,
    'Curd': curd,
    'Kool-M': koolM,
  };

  // // Recheck availability after update
  // canPrepare = await _canPrepareDrink(200, 100, 50, 30);
  // setState(() {}); // Update UI
}
