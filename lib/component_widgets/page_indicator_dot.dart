import 'package:calorie_counter/custom_colors.dart';
import 'package:flutter/material.dart';

class IndicatorDot extends StatelessWidget {
  final bool active;

  const IndicatorDot({Key? key, this.active = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(
        active ? 4 : 5,
      ),
      width: active ? 12 : 10,
      height: active ? 12 : 10,
      decoration: BoxDecoration(
        color: active ? Colors.white : inactiveIndicator,
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    );
  }
}
