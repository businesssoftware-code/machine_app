import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machine_basil/provider/sharedPrefernce.dart';
import 'package:machine_basil/utils/drinkHelper.dart';
import 'package:machine_basil/views/Home/home.dart';
import 'package:machine_basil/widgets/CustomAppbar.dart';
import 'package:machine_basil/widgets/locaLRecipeCard.dart';
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
  bool _isConnected = false;
  final List<Map<String, dynamic>> localRecipes = [
    {'name': 'Strawberry Shake', 'url': 'assets/local/strawberry.png'},
    {'name': 'Berrylicious Smoothie', 'url': 'assets/local/Berrilicious.png'},
    {'name': 'Guiltree Avocado Smoothie', 'url': 'assets/local/Avacado.png'},
    {'name': 'Berry Ice Tea', 'url': 'assets/local/BerryIce.png'},
    {'name': 'Choco Brownie Shake', 'url': 'assets/local/Choco.png'},
    {'name': 'Classic Cold Coffee', 'url': 'assets/local/ClassicCold.png'},
    {'name': 'Pineapple Cooler', 'url': 'assets/local/Pineapple.png'},
    {'name': 'Berry Banana Smoothie', 'url': 'assets/local/BerryBanana.png'},
    {'name': 'Peach Iced Tea', 'url': 'assets/local/PeachIceTea.png'},
  ];
  final String _webSocketUrl = 'ws://192.168.0.65:3003';
  Map<String, String> stationStages = {
    'station1': 'vacant',
    'station2': 'vacant',
  };

  final PreferencesService _preferencesService = PreferencesService();
  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  Future<void> _loadStationStages() async {
    stationStages = await _preferencesService.loadStationStages();
    setState(() {});
  }

  void _updateStationStage(String station, String stage) {
    setState(() {
      stationStages[station] = stage;
    });
    _preferencesService.saveStationStages(stationStages);
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
        int koolM = decodedEvent['data']['Kool-M'];
        bool canPrepare = await canPrepareDrink(milk, water, curd, koolM);
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                drinkName: decodedEvent['data']['drinkName'],
                canPrepare: canPrepare,
              ),
            ),
          );
        });
      }

      if (decodedEvent['event'] == 'station1') {
        print(decodedEvent['data']);

        setState(() {
          String currentStage = decodedEvent['data']['stage'];

          _updateStationStage('station1', currentStage);
          if (currentStage == 'Blending') {
            int milk = decodedEvent['data']['Milk'];
            int water = decodedEvent['data']['Water'];
            int curd = decodedEvent['data']['Curd'];
            int koolM = decodedEvent['data']['Kool-M'];
            updateIngredientQuantities(milk, water, curd, koolM);
          }
          if (currentStage == 'Clear') {
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                _updateStationStage('station1', 'vacant');
              });
            });
          }
        });
      }
      if (decodedEvent['event'] == 'station2') {
        setState(() {
          String currentStage = decodedEvent['data']['stage'];
          _updateStationStage('station2', currentStage);
          if (currentStage == 'Blending') {
            int milk = decodedEvent['data']['Milk'];
            int water = decodedEvent['data']['Water'];
            int curd = decodedEvent['data']['Curd'];
            int koolM = decodedEvent['data']['Kool-M'];
            updateIngredientQuantities(milk, water, curd, koolM);
          }
          if (currentStage == 'Clear') {
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                _updateStationStage('station2', 'vacant');
              });
            });
          }
        });
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
              Image.asset(
                'assets/curvedLine.png',
                width: screenWidth * 0.10,
                fit: BoxFit.contain,
              ),
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
