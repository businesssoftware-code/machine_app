import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:machine_basil/controller/MenuController.dart';
import 'package:machine_basil/provider/sharedPrefernce.dart';
import 'package:machine_basil/utils/drinkHelper.dart';
import 'package:machine_basil/views/Home/home.dart';
import 'package:machine_basil/widgets/CustomAppbar.dart';
import 'package:machine_basil/widgets/MachineOperation.dart';
import 'package:machine_basil/widgets/UtilitiesCardCompressed.dart';
import 'package:machine_basil/widgets/UtilitiesCardLarge.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class UtilitiesScreen extends StatefulWidget {
  const UtilitiesScreen({super.key});

  @override
  State<UtilitiesScreen> createState() => _UtilitiesScreenState();
}

class _UtilitiesScreenState extends State<UtilitiesScreen> {
  late WebSocketChannel _channel;
  late MenuControllers menuController; // Define menuController
  late PreferencesService _preferencesService;
  bool _isConnected = false;
  bool isLoading = false;
  Map<String, String> stationStages = {
    'station1': 'vacant',
    'station2': 'vacant',
  };

  final String _webSocketUrl = 'ws://192.168.0.65:3003';

  @override
  void initState() {
    super.initState();
    menuController = Get.put(MenuControllers());
    _preferencesService = PreferencesService();
    _connectWebSocket();
  }

  void _updateStationStage(String station, String stage) {
    // Update the station stage and save to SharedPreferences
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
        _showSnackBar2(
            decodedEvent['data']['message'], Colors.black, Colors.white);
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

  Future<void> _sendApiRequest(String url) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        _showSnackBar('Request successful!', Colors.black, Colors.white);
      } else {
        _showSnackBar('Request failed with status: ${response.statusCode}',
            Colors.black, Colors.white);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.black, Colors.white);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color bgColor, Color textColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSnackBar2(String message, Color bgColor, Color textColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: textColor),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ],
        ),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 120),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
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
                            text: 'Utilities',
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Set text color to white
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          UtilitiesCardSmall(
                            title: 'Blender Cleaning',
                            imageUrl: 'assets/blender.png',
                            onStartPressed: () {
                              _sendApiRequest(
                                  'http://192.168.0.65:3001/blender_clean');
                            },
                          ),
                          UtilitiesCardSmall(
                            title: 'Homing',
                            imageUrl: 'assets/homing.png',
                            onStartPressed: () {
                              _sendApiRequest(
                                  'http://192.168.0.65:3001/homing');
                            },
                          ),
                        ],
                      ),
                      
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        children: [
                          MachineOperationCard(
                            title: 'Daily Priming',
                            imageUrl: 'assets/machine.png',
                            button2Label: 'Start',
                            onButton2Pressed: () {
                              _sendApiRequest(
                                  'http://192.168.0.65:3001/dailyPriming');
                            },
                          ),
                          MachineOperationCard(
                            title: 'Machine',
                            imageUrl: 'assets/machine.png',
                            button1Label: 'Active',
                            button2Label: 'Inactive',
                            onButton1Pressed: () {
                              _sendApiRequest(
                                  'http://192.168.0.65:3001/machineStatus?status=active');
                            },
                            onButton2Pressed: () {
                              _sendApiRequest(
                                  'http://192.168.0.65:3001/machineStatus?status=inactive');
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.01),
                      PrimingCard(
                        title: 'Priming',
                        imageUrl: 'assets/priming.png',
                        onStartPressed: [
                          () => _sendApiRequest(
                              'http://192.168.0.65:3001/liquids?liqNum=1&liqAction=start'),
                          () => _sendApiRequest(
                              'http://192.168.0.65:3001/liquids?liqNum=2&liqAction=start'),
                          () => _sendApiRequest(
                              'http://192.168.0.65:3001/liquids?liqNum=3&liqAction=start'),
                          () => _sendApiRequest(
                              'http://192.168.0.65:3001/liquids?liqNum=4&liqAction=start'),
                        ],
                        onStopPressed: [
                          () => _sendApiRequest(
                              'http://192.168.0.65:3001/liquids?liqNum=1&liqAction=stop'),
                          () => _sendApiRequest(
                              'http://192.168.0.65:3001/liquids?liqNum=2&liqAction=stop'),
                          () => _sendApiRequest(
                              'http://192.168.0.65:3001/liquids?liqNum=3&liqAction=stop'),
                          () => _sendApiRequest(
                              'http://192.168.0.65:3001/liquids?liqNum=4&liqAction=stop'),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Center(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color:
                      Colors.black.withOpacity(0.6), // Glass effect background
                  alignment: Alignment.center,
                  child: const SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      color: Colors.white, // White loader
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
