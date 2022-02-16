import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:calorie_counter/views/navigation/homePage.dart';
import 'package:calorie_counter/views/navigation/settingsPage.dart';
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
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _getPreferences();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(homeInterceptor);
    super.dispose();
  }

  void _getPreferences() async {
    SharedPreferences.getInstance().then((value) {
      setState(() {
        prefs = value;
      });
    });
  }

  void _selectNavItem(int selectedIndex) {
    if (selectedIndex == currentPage)
      return;
    else if (selectedIndex != 0 && currentPage == 0) {
      BackButtonInterceptor.add(
        homeInterceptor,
        zIndex: 1,
        ifNotYetIntercepted: true,
      );
    } else if (selectedIndex == 0) {
      BackButtonInterceptor.remove(homeInterceptor);
    }
    setState(() {
      currentPage = selectedIndex;
    });
  }

  bool homeInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    BackButtonInterceptor.remove(homeInterceptor);
    setState(() {
      currentPage = 0;
    });
    return true;
  }

  static const List<String> pageTitles = [
    "CalorieCounter",
    "Napredak",
    "Postavke",
    "Odabir Datuma",
    "Nutritivne Vrijednosti",
    "Administracija"
  ];

  Widget _getPageWidget() {
    switch (currentPage) {
      case 0:
        return HomePage();
      case 2:
        return SettingsPage();
      default:
        return Container();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now()
            .add(Duration(days: CacheManager.getData("dayOffset") ?? 0)),
        firstDate: DateTime(2021),
        lastDate: DateTime(2023));
    if (picked != null) {
      setState(() {
        CacheManager.cacheData(
            "dayOffset",
            -DateTime.now().difference(picked).inDays +
                (DateTime.now().isBefore(picked) ? 1 : 0));
        currentPage = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(pageTitles[currentPage]),
        leading: currentPage == 0
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => _selectNavItem(0),
              ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: false,
        actions: currentPage == 0
            ? [
                IconButton(
                    onPressed: () {}, icon: FaIcon(FontAwesomeIcons.server)),
                IconButton(
                    onPressed: () {}, icon: FaIcon(FontAwesomeIcons.chartPie)),
                IconButton(
                    onPressed: () => _selectDate(context),
                    icon: FaIcon(FontAwesomeIcons.solidCalendarAlt)),
              ]
            : [],
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
          onTap: _selectNavItem,
          currentIndex: currentPage,
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
        child: _getPageWidget(),
      ),
    );
  }
}
