import 'package:calorie_counter/component_widgets/custom_dialog.dart';
import 'package:calorie_counter/component_widgets/light_green_button.dart';
import 'package:calorie_counter/component_widgets/transparent_outlined_button.dart';
import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/utils/bmr_model.dart';
import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:calorie_counter/views/basicInfoPage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'navigationPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

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
      Dio dio = Dio(
        BaseOptions(
          baseUrl: dotenv.get('API_BASE_URL'),
        ),
      );
      await dio.get("users/token/" + prefs!.getString('token')!).then((response) {
        if (response.data["error"] == 0) {
          dynamic user = response.data["user"];
          CacheManager.cacheData("user", user);
          BMRModel bmrModel = getAppropriateModel(user["model_id"], user["gender_id"]);
          CacheManager.cacheData("dailyCalories", bmrModel.calculate(user["weight"], user["height"], user["age"]) + user["weekly_calorie_diff"]);
          final dailyCalories = CacheManager.getData("dailyCalories");
          CacheManager.cacheData("dailyNutrients", {
            "proteins": ((dailyCalories * 0.23) / 4).round(),
            "carbs": ((dailyCalories * 0.45) / 4).round(),
            "fats": ((dailyCalories * 0.32) / 9).round(),
            "sugars": user["gender_id"] == 1 ? 36 : 24,
            "fibers": user["gender_id"] == 1 ? 35 : 23,
            "salt": 2300,
            "calcium": user["age"] <= 50 ? 2500 : 2000,
            "iron": user["gender_id"] == 2 && user["age"] <= 50 && user["age"] >= 19 ? 15 : 9,
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => NavigationPage(),
            ),
          );
        } else if (response.data["error"] == 1) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                response.data["message"].toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: errorColor.withOpacity(0.8),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(
                "Došlo je do greške. Molimo pokušajte ponovo.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: errorColor.withOpacity(0.8),
            ),
          );
        }
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => const BasicInfoPage(
                                    goalType: 1,
                                  ),
                                ),
                              );
                            },
                          ),
                          LightGreenButton(
                            text: 'ODRŽAVAJ KILAŽU',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => const BasicInfoPage(
                                    goalType: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                          LightGreenButton(
                            text: 'IZGRADI MIŠIĆE',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => const BasicInfoPage(
                                    goalType: 3,
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
                const Text(
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
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialog();
                                },
                              ).then((value) {});
                            },
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
            !loaded
                ? Container(
                    color: Colors.black.withOpacity(0.6),
                    child: const Center(
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
