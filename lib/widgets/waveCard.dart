import 'package:flutter/material.dart';
import 'package:machine_basil/controller/ValueNotifier.dart';

class WaveCard extends StatelessWidget {
  final String name;
  final String url;

  const WaveCard({
    super.key,
    required this.name,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, int>>(
      valueListenable: quantityNotifier,
      builder: (context, quantities, child) {
        final quantity = quantities[name] ?? 0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$quantity ml',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: quantity < 401 ? Colors.red : Colors.white,
                ),
              ),     
              SizedBox(
                  width: 160,
                  height: 160,
                  child: Image.asset(
                  url,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
