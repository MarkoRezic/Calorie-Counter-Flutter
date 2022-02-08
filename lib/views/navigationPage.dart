import 'package:calorie_counter/custom_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  SharedPreferences? prefs;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _getPreferences();
  }

  void _getPreferences() async {
    SharedPreferences.getInstance().then((value) {
      setState(() {
        prefs = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("CalorieCounter"),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: FaIcon(FontAwesomeIcons.server)),
          IconButton(onPressed: () {}, icon: FaIcon(FontAwesomeIcons.chartPie)),
          IconButton(
              onPressed: () {},
              icon: FaIcon(FontAwesomeIcons.solidCalendarAlt)),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF888888),
              Color(0xFF666666),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          unselectedItemColor: inactiveIndicator,
          selectedItemColor: mainColorLight,
          items: [
            BottomNavigationBarItem(
              label: "Početna",
              icon: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FaIcon(FontAwesomeIcons.home),
              ),
              activeIcon: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FaIcon(FontAwesomeIcons.home),
              ),
            ),
            BottomNavigationBarItem(
              label: "Napredak",
              icon: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FaIcon(FontAwesomeIcons.chartLine),
              ),
              activeIcon: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FaIcon(FontAwesomeIcons.chartLine),
              ),
            ),
            BottomNavigationBarItem(
              label: "Postavke",
              icon: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FaIcon(FontAwesomeIcons.cog),
              ),
              activeIcon: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: FaIcon(FontAwesomeIcons.cog),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(prefs != null ? prefs!.getString("token").toString() : ""),
          ],
        ),
      ),
    );
  }
}
