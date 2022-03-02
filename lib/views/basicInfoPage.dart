import 'package:calorie_counter/component_widgets/light_green_button.dart';
import 'package:calorie_counter/component_widgets/page_indicator_row.dart';
import 'package:calorie_counter/component_widgets/transparent_outlined_button.dart';
import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/utils/bmr_model.dart';
import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'navigationPage.dart';

class BasicInfoPage extends StatefulWidget {
  final int goalType;
  const BasicInfoPage({Key? key, required this.goalType}) : super(key: key);

  @override
  _BasicInfoPageState createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  static const pageCount = 4;
  int selectedPage = 0;
  final PageController pageController = PageController();
  List<Widget> pageList = [];
  List<dynamic> weeklyGoalsList = [];
  int selectedWeeklyGoalIndex = 0;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repasswordController = TextEditingController();
  bool showPassword = false;
  bool showRepassword = false;
  bool loading = false;
  String errorUsername = "";
  bool showErrorUsername = false;
  String errorPassword = "";
  bool showErrorPassword = false;
  String errorRepassword = "";
  bool showErrorRepassword = false;
  final formKey1 = GlobalKey<FormState>();

  List<dynamic> genderList = [];
  int selectedGenderIndex = 0;
  TextEditingController heightController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  String errorHeight = "";
  bool showErrorHeight = false;
  String errorAge = "";
  bool showErrorAge = false;
  String errorGender = "";
  bool showErrorGender = false;
  final formKey2 = GlobalKey<FormState>();

  TextEditingController weightController = TextEditingController();
  TextEditingController goalWeightController = TextEditingController();
  String errorWeight = "";
  bool showErrorWeight = false;
  String errorGoalWeight = "";
  bool showErrorGoalWeight = false;
  final formKey3 = GlobalKey<FormState>();

  List<dynamic> activityLevelList = [];
  int selectedActivityLevelIndex = 0;
  String errorActivityLevel = "";
  bool showErrorActivityLevel = false;
  final formKey4 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getWeeklyGoals();
    _getGenders();
    _getActivityLevels();
  }

  void _getWeeklyGoals() async {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL'),
      ),
    );
    dio.get("attributes/weekly_goals/" + widget.goalType.toString()).then((response) {
      setState(() {
        weeklyGoalsList = widget.goalType == 1 ? response.data.reversed.toList() : response.data;
      });
    });
  }

  void _getGenders() async {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL'),
      ),
    );
    dio.get("attributes/genders").then((response) {
      setState(() {
        genderList = response.data;
      });
    });
  }

  void _getActivityLevels() async {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL'),
      ),
    );
    dio.get("attributes/activity_levels").then((response) {
      setState(() {
        activityLevelList = response.data;
      });
    });
  }

  Future<bool> _isUsernameTaken() async {
    setState(() {
      loading = true;
    });
    Dio dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL'),
      ),
    );
    await dio.post(
      "users/check",
      data: {
        "username": usernameController.text,
      },
    ).then((response) {
      setState(() {
        if (response.data["error"] == 0) {
          showErrorUsername = false;
          errorUsername = "";
        } else {
          showErrorUsername = true;
          errorUsername = response.data["message"];
        }
        loading = false;
      });
    });
    return showErrorUsername;
  }

  bool _isInvalidGoal() {
    setState(() {
      if (widget.goalType == 1) {
        setState(() {
          showErrorGoalWeight = num.parse(goalWeightController.text) < num.parse(weightController.text) ? false : true;
          errorGoalWeight = showErrorGoalWeight ? "ciljana težina mora biti manja od trenutne" : "";
        });
      } else if (widget.goalType == 3) {
        setState(() {
          showErrorGoalWeight = num.parse(goalWeightController.text) > num.parse(weightController.text) ? false : true;
          errorGoalWeight = showErrorGoalWeight ? "ciljana težina mora biti veća od trenutne" : "";
        });
      }
    });
    return showErrorGoalWeight;
  }

  void _register() async {
    setState(() {
      loading = true;
    });
    Dio dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL'),
      ),
    );
    await dio.post(
      "users/register",
      data: {
        "username": usernameController.text,
        "password": passwordController.text,
        "height": num.parse(heightController.text.replaceAll(",", ".")),
        "weight": num.parse(weightController.text.replaceAll(",", ".")),
        "goal_weight": widget.goalType == 2 ? num.parse(weightController.text.replaceAll(",", ".")) : num.parse(goalWeightController.text.replaceAll(",", ".")),
        "age": num.parse(ageController.text),
        "gender_id": genderList[selectedGenderIndex]["gender_id"],
        "weekly_goal_id": weeklyGoalsList[selectedWeeklyGoalIndex]["weekly_goal_id"],
        "activity_level_id": activityLevelList[selectedActivityLevelIndex]["activity_level_id"],
      },
    ).then((response) async {
      await dio.post(
        "users/login",
        data: {
          "username": usernameController.text,
          "password": passwordController.text,
        },
      ).then((response) async {
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => NavigationPage(),
            ),
          );
        } else {
          setState(() {
            loading = false;
          });
        }
      });
    });
  }

  void _handleSelect(index) {
    if (selectedPage == index) return;
    setState(() {
      pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.ease);
    });
  }

  void _handlePrevious() {
    if (loading) return;
    if (selectedPage == 0) return Navigator.pop(context);
    setState(() {
      pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.ease);
    });
  }

  void _handleNext() async {
    if (loading) return;
    if (selectedPage == 0) {
      bool isUsernameTaken = await _isUsernameTaken();
      if ((!formKey1.currentState!.validate() || isUsernameTaken)) {
        return;
      }
    } else if (selectedPage == 1) {
      if (!formKey2.currentState!.validate()) {
        return;
      }
    } else if (selectedPage == 2) {
      bool invalidGoal = _isInvalidGoal();
      if (!formKey3.currentState!.validate() || invalidGoal) {
        return;
      }
    } else if (selectedPage == 3) {
      _register();
      return;
    }
    setState(() {
      pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    pageList = [
      ///USERNAME, PASSWORD, GOAL PACE

      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Form(
            key: formKey1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameController,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Molimo unesite korisničko ime.';
                    } else if (value.length < 3) {
                      return 'Korisničko ime mora imati barem 3 slova.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    labelText: "korisničko ime",
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    hintText: "username",
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                    ),
                    errorText: errorUsername.isEmpty ? null : errorUsername,
                    errorStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: errorColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Molimo unesite šifru.';
                    } else if (value.length < 8) {
                      return 'Šifra mora imati barem 8 znakova.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    suffixIcon: IconButton(
                      color: Colors.white.withOpacity(0.6),
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
                      color: Colors.white.withOpacity(0.6),
                    ),
                    errorStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: errorColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: repasswordController,
                  obscureText: !showRepassword,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Molimo ponovite šifru.';
                    } else if (value != passwordController.text) {
                      return 'Šifre se ne podudaraju.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    suffixIcon: IconButton(
                      color: Colors.white.withOpacity(0.6),
                      icon: Icon(showRepassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          showRepassword = !showRepassword;
                        });
                      },
                    ),
                    labelText: "ponovite šifru",
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    errorStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: errorColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                widget.goalType != 2
                    ? (weeklyGoalsList.isNotEmpty
                        ? DropdownButtonFormField(
                            isExpanded: true,
                            dropdownColor: mainColorFill,
                            iconEnabledColor: Colors.white,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.15),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              labelText: "odaberite brzinu napretka",
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            items: List.generate(
                              weeklyGoalsList.length,
                              (index) => DropdownMenuItem<dynamic>(
                                child: Text(
                                  weeklyGoalsList[index]["description"],
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                value: weeklyGoalsList[index],
                              ),
                            ),
                            value: weeklyGoalsList[selectedWeeklyGoalIndex],
                            selectedItemBuilder: (BuildContext context) {
                              return weeklyGoalsList.map<Widget>((dynamic item) {
                                return Text(
                                  item["description"],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                );
                              }).toList();
                            },
                            onChanged: (dynamic newValue) {
                              setState(() {
                                selectedWeeklyGoalIndex = weeklyGoalsList.indexOf(newValue);
                              });
                            })
                        : const CircularProgressIndicator())
                    : Container(),
                const SizedBox(
                  height: 20,
                ),
                loading ? const CircularProgressIndicator() : Container(),
              ],
            ),
          ),
        ),
      ),

      ///HEIGHT, AGE, GENDER

      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Form(
            key: formKey2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: heightController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("(^[0-9]{1,3}[.,]?[0-9]{0,2}\$)")),
                  ],
                  keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Molimo unesite visinu.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    labelText: "visina (cm)",
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    errorText: errorHeight.isEmpty ? null : errorHeight,
                    errorStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: errorColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: ageController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp("(^[1-9][0-9]{0,2}\$)"))],
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Molimo unesite dob.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    labelText: "dob (god)",
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    errorText: errorAge.isEmpty ? null : errorAge,
                    errorStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: errorColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                genderList.isNotEmpty
                    ? DropdownButtonFormField(
                        dropdownColor: mainColorFill,
                        iconEnabledColor: Colors.white,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.15),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          labelText: "odaberite spol",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        items: List.generate(
                          genderList.length,
                          (index) => DropdownMenuItem<dynamic>(
                            child: Text(
                              genderList[index]["name"],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            value: genderList[index],
                          ),
                        ),
                        value: genderList[selectedGenderIndex],
                        onChanged: (dynamic newValue) {
                          setState(() {
                            selectedGenderIndex = genderList.indexOf(newValue ?? {});
                          });
                        })
                    : const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),

      ///WEIGHT, GOAL WEIGHT

      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Form(
            key: formKey3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: weightController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("(^[0-9]{1,3}[.,]?[0-9]{0,2}\$)")),
                  ],
                  keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Molimo unesite težinu.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    labelText: "težina (kg)",
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    errorText: errorWeight.isEmpty ? null : errorWeight,
                    errorStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: errorColor,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                widget.goalType != 2
                    ? TextFormField(
                        controller: goalWeightController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("(^[0-9]{1,3}[.,]?[0-9]{0,2}\$)")),
                        ],
                        keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Molimo unesite ciljanu težinu.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.15),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          labelText: "ciljana težina (kg)",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          errorText: errorGoalWeight.isEmpty ? null : errorGoalWeight,
                          errorStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: errorColor,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),

      ///ACTIVITY LEVEL

      Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Form(
            key: formKey4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                activityLevelList.isNotEmpty
                    ? DropdownButtonFormField(
                        isExpanded: true,
                        dropdownColor: mainColorFill,
                        iconEnabledColor: Colors.white,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.15),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          labelText: "odaberite razinu aktivnosti",
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        items: List.generate(
                          activityLevelList.length,
                          (index) => DropdownMenuItem<dynamic>(
                            child: Text(
                              activityLevelList[index]["description"],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            value: activityLevelList[index],
                          ),
                        ),
                        selectedItemBuilder: (BuildContext context) {
                          return activityLevelList.map<Widget>((dynamic item) {
                            return Text(
                              item["description"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            );
                          }).toList();
                        },
                        value: activityLevelList[selectedActivityLevelIndex],
                        onChanged: (dynamic newValue) {
                          setState(() {
                            selectedActivityLevelIndex = activityLevelList.indexOf(newValue ?? {});
                          });
                        })
                    : const CircularProgressIndicator(),
                const SizedBox(
                  height: 20,
                ),
                loading ? const CircularProgressIndicator() : Container(),
              ],
            ),
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: mainColorDark,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 40,
                    ),
                    child: Text(
                      'Unesite Vaše informacije kako bi izračunali Vaš dnevni kalorijski cilj',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: PageView.builder(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (int page) {
                    setState(() {
                      selectedPage = page;
                    });
                  },
                  itemCount: pageCount,
                  itemBuilder: (context, index) => pageList[index]),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TransparentOutlinedButton.small(
                    text: 'Nazad',
                    onTap: _handlePrevious,
                    width: 85,
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: IndicatorRow(
                      onSelect: _handleSelect,
                      length: 4,
                      activeIndex: selectedPage,
                    ),
                  ),
                  LightGreenButton.small(
                    text: 'Dalje',
                    onTap: _handleNext,
                    width: 85,
                    height: 40,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
