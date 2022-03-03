import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChangeSettingsPage extends StatefulWidget {
  const ChangeSettingsPage({
    Key? key,
  }) : super(key: key);

  @override
  _ChangeSettingsPageState createState() => _ChangeSettingsPageState();
}

class _ChangeSettingsPageState extends State<ChangeSettingsPage> {
  final _user = CacheManager.getData("user");
  bool _loading = true;
  List<dynamic> _models = [];
  List<dynamic> _genders = [];
  List<dynamic> _weeklyGoals = [];
  List<dynamic> _activityLevels = [];
  dynamic _model;
  dynamic _gender;
  dynamic _weeklyGoal;
  dynamic _activityLevel;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _goalWeightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  late final List<TextEditingController> _controllerList;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _heightController.text = _user["height"].toString();
    _weightController.text = _user["weight"].toString();
    _goalWeightController.text = _user["goal_weight"].toString();
    _ageController.text = _user["age"].toString();
    _getDropdownAttributes();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _getDropdownAttributes() async {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL'),
      ),
    );
    final responses = await Future.wait([dio.get("attributes/models"), dio.get("attributes/genders"), dio.get("attributes/weekly_goals"), dio.get("attributes/activity_levels")]);
    if (!mounted) return;
    setState(() {
      _models = responses[0].data;
      _genders = responses[1].data;
      _weeklyGoals = responses[2].data;
      _activityLevels = responses[3].data;
      _model = _models.firstWhere((m) => m["model_id"] == _user["model_id"]);
      _gender = _genders.firstWhere((g) => g["gender_id"] == _user["gender_id"]);
      _weeklyGoal = _weeklyGoals.firstWhere((w) => w["weekly_goal_id"] == _user["weekly_goal_id"]);
      _activityLevel = _activityLevels.firstWhere((a) => a["activity_level_id"] == _user["activity_level_id"]);
      _loading = false;
    });
  }

  void _parseAmount(TextEditingController controller) {
    try {
      controller.text = controller.text.replaceAll(",", ".");
      controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
      if (controller.text != ".") {
        num.parse(controller.text).toDouble();
      }
    } on Exception catch (_) {
      setState(() {
        controller.clear();
      });
    }
  }

  double _getAmount(TextEditingController controller) {
    try {
      if (controller.text != ".") {
        double testAmount = num.parse(controller.text).toDouble();
        return testAmount;
      } else {
        return 0;
      }
    } on Exception catch (_) {
      controller.clear();
      return 0;
    }
  }

  int _getIntAmount(TextEditingController controller) {
    if (controller.text.isEmpty) return 0;
    return int.parse(controller.text);
  }

  void _updateUser() {
    if (formKey.currentState!.validate() == false) return;
    if (!mounted) return;
    setState(() {
      _loading = true;
      FocusScope.of(context).unfocus();
    });
    Dio dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL'),
      ),
    );
    try {
      dio.put(
        "users/settings",
        data: {
          "user_id": _user["user_id"],
          "height": _getAmount(_heightController),
          "weight": _getAmount(_weightController),
          "goal_weight": _weeklyGoal["weekly_goal_id"] == 4 ? _getAmount(_weightController) : _getAmount(_goalWeightController),
          "age": _getIntAmount(_ageController),
          "model_id": _model["model_id"],
          "gender_id": _gender["gender_id"],
          "weekly_goal_id": _weeklyGoal["weekly_goal_id"],
          "activity_level_id": _activityLevel["activity_level_id"],
        },
      ).then((response) {
        //print(response);
        if (mounted) {
          if (response.data["error"] == 0) {
            return Navigator.pop(context, {
              "error": 0,
              "message": "Ažurirani podaci",
            });
          } else {
            return Navigator.pop(context, {
              "error": 1,
              "message": "Došlo je do greške. Molimo pokušajte ponovo.",
            });
          }
        }
      });
    } on Exception catch (_) {
      debugPrint(_.toString());
      return Navigator.pop(context, {
        "error": 1,
        "message": "Došlo je do greške. Molimo pokušajte ponovo.",
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Promjena postavki"),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context, {
                  "error": 1,
                  "message": "Promjene odbačene.",
                });
              },
              icon: const FaIcon(FontAwesomeIcons.times)),
          IconButton(
              onPressed: () {
                _updateUser();
              },
              icon: const FaIcon(FontAwesomeIcons.check)),
        ],
      ),
      body: SafeArea(
        child: (_models.length * _genders.length * _weeklyGoals.length * _activityLevels.length) == 0
            ? const Center(
                child: RepaintBoundary(
                  child: CircularProgressIndicator(),
                ),
              )
            : Stack(
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: ListView(
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(
                                bottom: 200,
                              ),
                              children: [
                                ///Dropdown inputs
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black.withOpacity(0.25),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Kalkulator",
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: inputFillColor,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: DropdownButtonFormField(
                                              dropdownColor: Colors.white,
                                              iconEnabledColor: Colors.black,
                                              isExpanded: true,
                                              decoration: const InputDecoration(
                                                hintText: "odaberite model",
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                ),
                                              ),
                                              items: List.generate(
                                                _models.length,
                                                (index) => DropdownMenuItem<dynamic>(
                                                  child: Text(
                                                    _models[index]["name"].toString(),
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  value: _models[index],
                                                ),
                                              ),
                                              value: _model,
                                              onChanged: (dynamic newValue) {
                                                setState(() {
                                                  _model = newValue;
                                                  formKey.currentState!.validate();
                                                });
                                              }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black.withOpacity(0.25),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Spol",
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: inputFillColor,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: DropdownButtonFormField(
                                              dropdownColor: Colors.white,
                                              iconEnabledColor: Colors.black,
                                              isExpanded: true,
                                              decoration: const InputDecoration(
                                                hintText: "odaberite spol",
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                ),
                                              ),
                                              items: List.generate(
                                                _genders.length,
                                                (index) => DropdownMenuItem<dynamic>(
                                                  child: Text(
                                                    _genders[index]["name"].toString(),
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  value: _genders[index],
                                                ),
                                              ),
                                              value: _gender,
                                              onChanged: (dynamic newValue) {
                                                setState(() {
                                                  _gender = newValue;
                                                  formKey.currentState!.validate();
                                                });
                                              }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black.withOpacity(0.25),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Cilj",
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: inputFillColor,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: DropdownButtonFormField(
                                              dropdownColor: Colors.white,
                                              iconEnabledColor: Colors.black,
                                              isExpanded: true,
                                              decoration: const InputDecoration(
                                                hintText: "odaberite cilj",
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                ),
                                              ),
                                              items: List.generate(
                                                _weeklyGoals.length,
                                                (index) => DropdownMenuItem<dynamic>(
                                                  child: Text(
                                                    _weeklyGoals[index]["description"].toString(),
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  value: _weeklyGoals[index],
                                                ),
                                              ),
                                              value: _weeklyGoal,
                                              onChanged: (dynamic newValue) {
                                                setState(() {
                                                  _weeklyGoal = newValue;
                                                  formKey.currentState!.validate();
                                                });
                                              }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black.withOpacity(0.25),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Aktivnost",
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: inputFillColor,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: DropdownButtonFormField(
                                              dropdownColor: Colors.white,
                                              iconEnabledColor: Colors.black,
                                              isExpanded: true,
                                              decoration: const InputDecoration(
                                                hintText: "odaberite razinu",
                                                hintStyle: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                ),
                                              ),
                                              items: List.generate(
                                                _activityLevels.length,
                                                (index) => DropdownMenuItem<dynamic>(
                                                  child: Text(
                                                    _activityLevels[index]["description"].toString(),
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  value: _activityLevels[index],
                                                ),
                                              ),
                                              value: _activityLevel,
                                              onChanged: (dynamic newValue) {
                                                setState(() {
                                                  _activityLevels = newValue;
                                                  formKey.currentState!.validate();
                                                });
                                              }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                ///Numeric inputs
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black.withOpacity(0.25),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Visina",
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: inputFillColor,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: TextFormField(
                                            controller: _heightController,
                                            textAlign: TextAlign.center,
                                            onEditingComplete: () {
                                              _parseAmount(_heightController);
                                              formKey.currentState!.validate();
                                              FocusScope.of(context).unfocus();
                                            },
                                            onChanged: (value) {
                                              _parseAmount(_heightController);
                                              formKey.currentState!.validate();
                                            },
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Molimo unesite visinu.';
                                              }
                                              return null;
                                            },
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp("(^[0-9]{0,3}[.,]?[0-9]{0,2}\$)")),
                                            ],
                                            keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: errorColor,
                                                  width: 2,
                                                ),
                                              ),
                                              focusedErrorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: errorColor,
                                                  width: 2,
                                                ),
                                              ),
                                              isDense: true,
                                              isCollapsed: false,
                                              contentPadding: EdgeInsets.all(5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black.withOpacity(0.25),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Kilaža",
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: inputFillColor,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: TextFormField(
                                            controller: _weightController,
                                            textAlign: TextAlign.center,
                                            onEditingComplete: () {
                                              _parseAmount(_weightController);
                                              formKey.currentState!.validate();
                                              FocusScope.of(context).unfocus();
                                            },
                                            onChanged: (value) {
                                              _parseAmount(_weightController);
                                              formKey.currentState!.validate();
                                            },
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Molimo unesite težinu.';
                                              }
                                              return null;
                                            },
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp("(^[0-9]{0,3}[.,]?[0-9]{0,2}\$)")),
                                            ],
                                            keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: errorColor,
                                                  width: 2,
                                                ),
                                              ),
                                              focusedErrorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: errorColor,
                                                  width: 2,
                                                ),
                                              ),
                                              isDense: true,
                                              isCollapsed: false,
                                              contentPadding: EdgeInsets.all(5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _weeklyGoal["weekly_goal_id"] != 4
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.black.withOpacity(0.25),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Ciljana kilaža",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                  left: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: inputFillColor,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: TextFormField(
                                                  controller: _goalWeightController,
                                                  textAlign: TextAlign.center,
                                                  onEditingComplete: () {
                                                    _parseAmount(_goalWeightController);
                                                    formKey.currentState!.validate();
                                                    FocusScope.of(context).unfocus();
                                                  },
                                                  onChanged: (value) {
                                                    _parseAmount(_goalWeightController);
                                                    formKey.currentState!.validate();
                                                  },
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Molimo unesite ciljanu kilažu.';
                                                    } else if (_weeklyGoal["weekly_goal_id"] < 4 && _getAmount(_goalWeightController) >= _getAmount(_weightController)) {
                                                      return "Ciljana kilaža mora biti manja od trenutne";
                                                    } else if (_weeklyGoal["weekly_goal_id"] > 4 && _getAmount(_goalWeightController) <= _getAmount(_weightController)) {
                                                      return "Ciljana kilaža mora biti veća od trenutne";
                                                    }
                                                    return null;
                                                  },
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter.allow(RegExp("(^[0-9]{0,3}[.,]?[0-9]{0,2}\$)")),
                                                  ],
                                                  keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                                                  decoration: const InputDecoration(
                                                    border: InputBorder.none,
                                                    errorBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: errorColor,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    focusedErrorBorder: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: errorColor,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    isDense: true,
                                                    isCollapsed: false,
                                                    contentPadding: EdgeInsets.all(5),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black.withOpacity(0.25),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Godine",
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: inputFillColor,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: TextFormField(
                                            controller: _ageController,
                                            textAlign: TextAlign.center,
                                            onEditingComplete: () {
                                              formKey.currentState!.validate();
                                              FocusScope.of(context).unfocus();
                                            },
                                            onChanged: (value) {
                                              formKey.currentState!.validate();
                                            },
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Molimo unesite godine.';
                                              }
                                              return null;
                                            },
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, FilteringTextInputFormatter.allow(RegExp("(^[1-9][0-9]{0,2}\$)"))],
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: errorColor,
                                                  width: 2,
                                                ),
                                              ),
                                              focusedErrorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: errorColor,
                                                  width: 2,
                                                ),
                                              ),
                                              isDense: true,
                                              isCollapsed: false,
                                              contentPadding: EdgeInsets.all(5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _loading
                      ? Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: RepaintBoundary(
                              child: CircularProgressIndicator(),
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
