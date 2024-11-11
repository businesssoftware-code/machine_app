import 'package:flutter/material.dart';

class NoBackPage extends StatelessWidget {
  final Widget child;

  const NoBackPage({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disables back button
      child: child,
    );
  }
}
