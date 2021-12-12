import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../custom_colors.dart';

class TransparentOutlinedButton extends StatelessWidget {
  final String text;
  final double? width;
  final Function onTap;
  final double? height;
  final bool hasShadow;
  final bool smallText;

  const TransparentOutlinedButton({
    Key? key,
    required this.text,
    this.width = double.infinity,
    required this.onTap,
    this.height = 50,
    this.hasShadow = true,
    this.smallText = false,
  }) : super(key: key);

  const TransparentOutlinedButton.small({
    Key? key,
    required this.text,
    this.width,
    required this.onTap,
    this.height = 50,
    this.hasShadow = false,
    this.smallText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(smallText ? 8 : 14),
        border: Border.all(
          color: mainColor,
          width: 2,
        ),
        boxShadow: hasShadow
            ? [
          const BoxShadow(
            color: mainColor,
            offset: Offset(3, 3),
            blurRadius: 3,
          ),
        ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(smallText ? 6 : 12),
        child: RepaintBoundary(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.white.withOpacity(0.5),
              onTap: () {
                onTap();
              },
              child: Container(
                height: height,
                width: width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(smallText ? 6 : 12),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: height != null ? 0 : 10,
                  horizontal: width != null ? 0 : 20,
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: smallText ? 16 : 18,
                    fontWeight: smallText ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
