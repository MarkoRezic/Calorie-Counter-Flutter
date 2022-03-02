import 'package:calorie_counter/component_widgets/transparent_outlined_button.dart';
import 'package:calorie_counter/utils/bmr_model.dart';
import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:calorie_counter/views/navigationPage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../custom_colors.dart';

class CustomDialog extends StatefulWidget {
  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showPassword = false;
  String error = "";
  bool showError = false;
  bool loading = false;

  void login() async {
    setState(() {
      loading = true;
    });
    Dio dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL'),
      ),
    );
    dio.post(
      "users/login",
      data: {
        "username": usernameController.text,
        "password": passwordController.text,
      },
    ).then((response) async {
      print(response);
      if (response.data["error"] == 0) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("token", response.data["token"]);
        CacheManager.cacheData("user", response.data["user"]);
        final user = CacheManager.getData("user");
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
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => NavigationPage(),
          ),
        ).then((value) => {});
      } else {
        setState(() {
          loading = false;
          showError = true;
          error = response.data["message"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: mainColorFaded,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "korisničko ime",
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: mainColorDark.withOpacity(0.5),
                ),
                hintText: "username",
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: passwordController,
              obscureText: !showPassword,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                ),
                labelText: "šifra",
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: mainColorDark.withOpacity(0.5),
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            loading
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: CircularProgressIndicator(),
                  )
                : TransparentOutlinedButton(
                    hasShadow: false,
                    textColor: mainColorDark,
                    text: "PRIJAVA",
                    onTap: () {
                      login();
                    },
                  ),
            showError
                ? Text(
                    error,
                    style: TextStyle(color: errorColor),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
