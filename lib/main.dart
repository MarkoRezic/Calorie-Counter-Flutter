import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/views/loginPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  Map<int, Color> color = {
    50: Color(0xFF128c7e).withOpacity(.1),
    100: Color(0xFF128c7e).withOpacity(.2),
    200: Color(0xFF128c7e).withOpacity(.3),
    300: Color(0xFF128c7e).withOpacity(.4),
    400: Color(0xFF128c7e).withOpacity(.5),
    500: Color(0xFF128c7e).withOpacity(.6),
    600: Color(0xFF128c7e).withOpacity(.7),
    700: Color(0xFF128c7e).withOpacity(.8),
    800: Color(0xFF128c7e).withOpacity(.9),
    900: Color(0xFF128c7e).withOpacity(1),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: MaterialColor(0xFF128c7e, color),
        fontFamily: 'Camber',
      ),
      //home: MyHomePage(title: 'Flutter Demo Home Page'),
      home: LoginPage(),
    );
  }
}
