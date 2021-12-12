import 'package:flutter/material.dart';

class CalorieRoute<T> extends MaterialPageRoute<T> {
  CalorieRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    return SlideTransition(
        position: animation.drive(
          Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(
            CurveTween(
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        child: child);
  }
}
