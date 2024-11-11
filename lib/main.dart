import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:machine_basil/controller/ValueNotifier.dart';
import 'package:machine_basil/views/LocalRecipes/LocalRecipe.dart';
import 'package:machine_basil/views/Refilling/refillingContainer.dart';
import 'package:machine_basil/views/utilities/utilities.dart';

import 'package:machine_basil/views/Home/home.dart';
import 'package:machine_basil/widgets/NoBackPage.dart';
import 'constants/AppPages.dart';
import 'constants/theme.dart';
import 'controller/MenuController.dart';

// Define the WebSocket URL
const String webSocketUrl = 'ws://localhost:8081';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  Get.put(MenuControllers());
  await loadInitialQuantities();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Basil Machine',
      theme: ThemeClass.buildTheme(context),
      initialRoute: AppPages.HomePage,
      getPages: [
        GetPage(
          name: AppPages.HomePage,
          page: () => const NoBackPage(child: HomeScreen()),
        ),
        GetPage(
          name: AppPages.Replenishment,
          page: () => const NoBackPage(child: RefillingLiquid()),
        ),
        GetPage(
          name: AppPages.LocalRecipes,
          page: () => NoBackPage(child: const LocalRecipeScreen()),
        ),
        GetPage(
          name: AppPages.Utilities,
          page: () => NoBackPage(child: const UtilitiesScreen()),
        ),
      ],
    );
  }
}
