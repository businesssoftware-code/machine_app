import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machine_basil/controller/MenuController.dart';
import 'package:machine_basil/provider/sharedPrefernce.dart';
import 'package:machine_basil/utils/drinkHelper.dart';
import 'package:machine_basil/views/Home/home.dart';
import 'package:machine_basil/widgets/CustomAppbar.dart';
import 'package:machine_basil/widgets/localRecipeCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LocalRecipeScreen extends StatefulWidget {
  const LocalRecipeScreen({super.key});

  @override
  State<LocalRecipeScreen> createState() => _LocalRecipeScreenState();
}

class _LocalRecipeScreenState extends State<LocalRecipeScreen> {
  late WebSocketChannel _channel;
  late MenuControllers menuController;
  late PreferencesService _preferencesService;
  bool _isConnected = false;

  final List<Map<String, dynamic>> localRecipes = [
    {'name': 'Strawberry Shake', 'url': 'assets/local/strawberry.png'},
    {'name': 'Berrylicious Smoothie', 'url': 'assets/local/Berrilicious.png'},
    {'name': 'Guiltfree Avocado Smoothie', 'url': 'assets/local/Avacado.png'},
    {'name': 'Berry Ice Tea', 'url': 'assets/local/BerryIce.png'},
    {'name': 'Choco Brownie Shake', 'url': 'assets/local/Choco.png'},
    {'name': 'Classic Cold Coffee', 'url': 'assets/local/ClassicCold.png'},
    {'name': 'Pineapple Cooler', 'url': 'assets/local/Pineapple.png'},
    {'name': 'Berry Banana Smoothie', 'url': 'assets/local/BerryBanana.png'},
    {'name': 'Peach Iced Tea', 'url': 'assets/local/PeachIceTea.png'},
    {'name': 'Choco Protein', 'url': 'assets/local/chocoProtein.png'},
  ];

  final String _webSocketUrl = 'ws://192.168.0.65:3003';
  Map<String, String> stationStages = {
    'station1': 'vacant',
    'station2': 'vacant',
    'station1DrinkName': 'vacant',
    'station2DrinkName': 'vacant',
  };

  @override
  void initState() {
    super.initState();
    menuController = Get.put(MenuControllers()); // Initialize menuController
    _preferencesService = PreferencesService();
    _connectWebSocket();
  }

  void _showSnackBar2(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ],
        ),
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 120),
      ),
    );
  }

  // Updates station stage and saves it in SharedPreferences
  void _updateStationStage(String station, String stage) {
    // Update the stationStages map and notify listeners
    _preferencesService.updateStationStage(station, stage);
  }

  void _connectWebSocket() {
    _channel = IOWebSocketChannel.connect(_webSocketUrl);
    _channel.stream.listen((event) async {
      setState(() {
        _isConnected = true;
      });

      final decodedEvent = jsonDecode(event);
      if (decodedEvent['event'] == 'scanned-sachet') {
        int milk = decodedEvent['data']['Milk'];
        int water = decodedEvent['data']['Water'];
        int curd = decodedEvent['data']['Curd'];
        int koolM = decodedEvent['data']['Cool-M'];
        bool canPrepare = await canPrepareDrink(milk, water, curd, koolM);
        // if (!canPrepare) {
        //   _showSnackBar2("Insufficient ingredients to prepare the drink.");
        // }

        // Use menuController to update route
        menuController.updateRoute('/home');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              drinkName: decodedEvent['data']['drinkName'],
              canPrepare: canPrepare,
            ),
          ),
        );
      }

      if (decodedEvent['event'] == 'error_logs') {
        _showSnackBar2(decodedEvent['data']['message']);
      }
      if (decodedEvent['event'] == 'station1') {
        String currentStage = decodedEvent['data']['stage'];
        String currentDrink = decodedEvent['data']['drinkName'];
        _updateStationStage('station1', currentStage);
        _updateStationStage('station1DrinkName', currentDrink);

        if (currentStage == 'Blending') {
          int milk = decodedEvent['data']['Milk'];
          int water = decodedEvent['data']['Water'];
          int curd = decodedEvent['data']['Curd'];
          int koolM = decodedEvent['data']['Cool-M'];
          updateIngredientQuantities(milk, water, curd, koolM);
        }
        if (currentStage == 'Clear') {
          Future.delayed(const Duration(seconds: 0), () {
            _updateStationStage('station1', 'vacant');
            _updateStationStage('station1DrinkName', 'vacant');
          });
        }
      }

      if (decodedEvent['event'] == 'station2') {
        String currentStage = decodedEvent['data']['stage'];
        String currentDrink = decodedEvent['data']['drinkName'];
        _updateStationStage('station2', currentStage);
        _updateStationStage('station2DrinkName', currentDrink);

        if (currentStage == 'Blending') {
          int milk = decodedEvent['data']['Milk'];
          int water = decodedEvent['data']['Water'];
          int curd = decodedEvent['data']['Curd'];
          int koolM = decodedEvent['data']['Cool-M'];
          updateIngredientQuantities(milk, water, curd, koolM);
        }
        if (currentStage == 'Clear') {
          Future.delayed(const Duration(seconds: 0), () {
            _updateStationStage('station2', 'vacant');
            _updateStationStage('station2DrinkName', 'vacant');
          });
        }
      }
    }, onDone: () {
      setState(() {
        _isConnected = false;
      });
    });
  }

  void _reconnect() {
    _channel.sink.close();
    _connectWebSocket();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.06),
          CustomAppBar(
            onReconnect: _reconnect,
            isConnected: _isConnected,
            screenHeight: screenHeight,
            screenWidth: screenWidth,
          ),
          SizedBox(height: screenHeight * 0.04),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Local',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .displayLarge!
                            .copyWith(fontSize: 20),
                      ),
                      TextSpan(
                        text: ' Recipes',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
                childAspectRatio: 0.75,
              ),
              itemCount: localRecipes.length,
              itemBuilder: (BuildContext context, int index) {
                return LocalRecipeCard(
                  name: localRecipes[index]['name'],
                  imageUrl: localRecipes[index]['url'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
