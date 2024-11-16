import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machine_basil/controller/MenuController.dart';
import 'package:machine_basil/provider/sharedPrefernce.dart';
import 'package:machine_basil/utils/drinkHelper.dart';
import 'package:machine_basil/views/Home/home.dart';
import 'package:machine_basil/widgets/CustomAppbar.dart';
import 'package:machine_basil/widgets/refillCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RefillingLiquid extends StatefulWidget {
  const RefillingLiquid({super.key});

  @override
  State<RefillingLiquid> createState() => _RefillingLiquidState();
}

class _RefillingLiquidState extends State<RefillingLiquid> {
  late WebSocketChannel _channel;
  late MenuControllers menuController; // Define menuController
  late PreferencesService _preferencesService;
  bool _isConnected = false;

  final List<Map<String, dynamic>> refilCardData = [
    {'name': 'Milk', 'quantity': '10000', 'url': 'assets/refil/milkR.png'},
    {'name': 'Water', 'quantity': '10000', 'url': 'assets/refil/waterr.png'},
    {'name': 'Curd', 'quantity': '10000', 'url': 'assets/refil/curdr.png'},
    {'name': 'Kool-M', 'quantity': '10000', 'url': 'assets/refil/koolmR.png'}
  ];
  final String _webSocketUrl = 'ws://192.168.0.65:3003';

  @override
  void initState() {
    super.initState();
    _preferencesService = PreferencesService();
    menuController = Get.put(MenuControllers()); // Initialize menuController
    _connectWebSocket();
  }

  void _updateStationStage(String station, String stage) {
    // Update and save the station stage using PreferencesService
    _preferencesService.updateStationStage(station, stage);
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

      if (decodedEvent['event'] == 'station1') {
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
            _updateStationStage('station1', 'vacant');
          });
        }
      }

      if (decodedEvent['event'] == 'station2') {
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
            _updateStationStage('station2', 'vacant');
          });
        }
      }

      if (decodedEvent['event'] == 'error_logs') {
        _showSnackBar2(decodedEvent['data']['message']);
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
          SizedBox(height: screenHeight * 0.06),
          Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Refilling ',
                    style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.white),
                  ),
                  TextSpan(
                    text: ' Liquid',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .displayLarge!
                        .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' Container',
                    style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 0.0,
                mainAxisSpacing: 4.0,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (BuildContext context, int index) {
                return RefillCard(
                  name: refilCardData[index]['name'],
                  url: refilCardData[index]['url'],
                );
              },
              itemCount: refilCardData.length,
            ),
          ),
        ],
      ),
    );
  }
}
