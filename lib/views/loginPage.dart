import 'package:calorie_counter/component_widgets/custom_dialog.dart';
import 'package:calorie_counter/component_widgets/light_green_button.dart';
import 'package:calorie_counter/component_widgets/transparent_outlined_button.dart';
import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/utils/bmr_model.dart';
import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:calorie_counter/views/basicInfoPage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'navigationPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showPassword = false;
  SharedPreferences? prefs;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    if (!loaded) _autoLogin();
  }

  void _autoLogin() async {
    await SharedPreferences.getInstance().then((value) {
      setState(() {
        prefs = value;
      });
    });

    if (prefs!.getString('token') != null && mounted) {
      Dio dio = Dio();
      await dio
          .get("http://10.0.2.2:3000/users/token/" + prefs!.getString('token')!)
          .then((response) {
        print(response);
        dynamic user = response.data["user"];
        CacheManager.cacheData("user", user);
        BMRModel bmrModel =
            getAppropriateModel(user["model_id"], user["gender_id"]);
        CacheManager.cacheData(
            "dailyCalories",
            bmrModel.calculate(user["weight"], user["height"], user["age"]) +
                user["weekly_calorie_diff"]);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => NavigationPage(),
          ),
        );
      });
    }
    if (loaded || !mounted) return;
    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: mainColorDark,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/images/apple_icon.png',
                        cacheWidth: 110,
                        cacheHeight: 110,
                        color: mainColor,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'CalorieCounter',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Spacer(),
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LightGreenButton(
                            text: 'IZGUBI KILAŽU',
                            onTap: () {
                              print('tapped');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const BasicInfoPage(
                                    goal_type: 1,
                                  ),
                                ),
                              );
                            },
                          ),
                          LightGreenButton(
                            text: 'ODRŽAVAJ KILAŽU',
                            onTap: () {
                              print('tapped');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const BasicInfoPage(
                                    goal_type: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                          LightGreenButton(
                            text: 'IZGRADI MIŠIĆE',
                            onTap: () {
                              print('tapped');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const BasicInfoPage(
                                    goal_type: 3,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const Spacer(),
                Text(
                  'Imate račun?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                Row(
                  children: [
                    const Spacer(),
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TransparentOutlinedButton(
                            text: 'PRIJAVI SE',
                            hasShadow: false,
                            onTap: () {
                              print('tapped');
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialog();
                                },
                              ).then((value) {
                                print(value);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
            !loaded
                ? Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
