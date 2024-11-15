import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machine_basil/controller/MenuController.dart';

class CustomAppBar extends StatefulWidget {
  final Function onReconnect;
  final bool isConnected;
  final double screenHeight;
  final double screenWidth;

  CustomAppBar({
    super.key,
    required this.onReconnect,
    required this.isConnected,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final MenuControllers menuController = Get.find();
  bool _isGrowing = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _isGrowing = !_isGrowing;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _openMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 60.0, bottom: 30),
            child: Container(
              width: widget.screenWidth * 0.6,
              height: widget.screenHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: widget.screenHeight * 0.02),
                child: Column(
                  children: [
                    SizedBox(
                      height: widget.screenHeight * 0.1,
                      child: Padding(
                        padding: EdgeInsets.only(top: 2, bottom: 2),
                        child: Image.asset(
                          'assets/basilFinal.png',
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                    SizedBox(height: widget.screenHeight * 0.04),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _menuItem(context, Icons.home, 'Home', '/home'),
                        _menuItem(
                            context, Icons.opacity, 'Refill', '/replenishment'),
                        _menuItem(context, Icons.restaurant_menu,
                            'Local Recipes', '/localRecipes'),
                        _menuItem(
                            context, Icons.build, 'Utilities', '/utilities'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  Widget _menuItem(
      BuildContext context, IconData icon, String title, String route) {
    return GestureDetector(
      onTap: () {
        menuController.updateRoute(route);
        Navigator.of(context).pop();
        Get.toNamed(route);
      },
      child: Obx(() {
        bool isSelected = menuController.selectedRoute.value == route;
        return Container(
          padding: EdgeInsets.symmetric(
              vertical: widget.screenHeight * 0.015,
              horizontal: widget.screenWidth * 0.017),
          margin: EdgeInsets.symmetric(
              horizontal: widget.screenWidth * 0.05,
              vertical: widget.screenHeight * 0.005),
          decoration: isSelected
              ? BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(60),
                )
              : null,
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.black),
              SizedBox(width: widget.screenWidth * 0.05),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: widget.screenHeight * 0.03,
          left: widget.screenWidth * 0.05,
          right: widget.screenWidth * 0.05),
      child: Container(
        height: widget.screenHeight * 0.07,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(widget.screenHeight * 0.05),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66BCBCBC),
              offset: Offset(0, 10),
              blurRadius: 40,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.menu, size: 16),
              onPressed: () => _openMenu(context),
            ),
            Expanded(
              child: Center(
                child: Container(
                  height: widget.screenHeight * 0.07,
                  width: widget.screenWidth * 0.35,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/basilLogo.png'),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: widget.screenHeight * 0.01),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, size: 16),
                    onPressed: () => widget.onReconnect(),
                    color: widget.isConnected ? Colors.green : Colors.red,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      right: widget.screenWidth * 0.02,
                      top: widget.screenHeight * 0.01,
                      bottom: widget.screenHeight * 0.01),
                  child: Stack(
                    children: [
                      Container(
                        height: widget.screenHeight * 0.07,
                        width: widget.screenHeight * 0.07,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE7E7E7),
                            width: 2,
                          ),
                          image: const DecorationImage(
                            image: AssetImage('assets/appbarIcon.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 5,
                        top: 3,
                        child: AnimatedScale(
                          scale: _isGrowing ? 1 : 0.5, // Adjust as needed
                          duration: Duration(milliseconds: 500),
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
