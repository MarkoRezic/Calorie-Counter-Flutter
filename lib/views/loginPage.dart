import 'package:calorie_counter/component_widgets/light_green_button.dart';
import 'package:calorie_counter/component_widgets/transparent_outlined_button.dart';
import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/views/basicInfoPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColorDark,
      body: SafeArea(
        child: Column(
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
                                  const BasicInfoPage(),
                            ),
                          );
                        },
                      ),
                      LightGreenButton(
                        text: 'ODRŽAVAJ KILAŽU',
                        onTap: () {},
                      ),
                      LightGreenButton(
                        text: 'IZGRADI MIŠIĆE',
                        onTap: () {},
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
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                insetPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 140,
                                ),
                                backgroundColor: mainColorFaded,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 30,
                                  ),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: usernameController,
                                        decoration: InputDecoration(
                                          hintText: "username",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
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
      ),
    );
  }
}
