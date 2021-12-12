import 'package:calorie_counter/component_widgets/page_indicator_dot.dart';
import 'package:flutter/material.dart';

import '../custom_colors.dart';

class IndicatorRow extends StatelessWidget {
  final int length;
  final int activeIndex;
  final Function onSelect;

  const IndicatorRow(
      {Key? key, this.length = 0, this.activeIndex = 0, required this.onSelect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        length,
        (index) => GestureDetector(
          onTap: () => onSelect(index),
          child: IndicatorDot(
            active: index == activeIndex,
          ),
        ),
      ),
    );
  }
}
