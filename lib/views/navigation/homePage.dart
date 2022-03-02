import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:calorie_counter/views/navigation/searchPage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'editPage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic _user = CacheManager.getData("user");
  final int _dailyCalories = CacheManager.getData("dailyCalories") ?? 0;
  int _dayOffset = 0;
  List<dynamic> _mealTypeList = [];
  List<dynamic>? _diaryEntries;
  Map<String, List<dynamic>> _mealEntriesMap = {};

  @override
  void initState() {
    super.initState();
    if (CacheManager.getData("dayOffset") != null) {
      if (!mounted) return;
      setState(() {
        _dayOffset = CacheManager.getData("dayOffset");
      });
    } else {
      CacheManager.cacheData("dayOffset", _dayOffset);
    }
    _getMealTypes();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (CacheManager.getData("dayOffset") != _dayOffset) {
      if (!mounted) return;
      setState(() {
        _dayOffset = CacheManager.getData("dayOffset") ?? 0;
        _diaryEntries = null;
        _mealEntriesMap = {};
        _getDiaryEntries();
      });
    }
  }

  void _getMealTypes() {
    if (CacheManager.getData("mealTypeList") != null) {
      if (!mounted) return;
      setState(() {
        _mealTypeList = CacheManager.getData("mealTypeList");
        _getDiaryEntries();
      });
    } else {
      Dio dio = Dio(
        BaseOptions(
          baseUrl: dotenv.get('API_BASE_URL'),
        ),
      );
      dio.get("attributes/meal_types").then((response) {
        //print(response);
        if (!mounted) return;
        setState(() {
          _mealTypeList = response.data;
          CacheManager.cacheData("mealTypeList", _mealTypeList);
          _getDiaryEntries();
        });
      });
    }
  }

  void _getDiaryEntries() {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL'),
      ),
    );
    final date = DateTime.now().add(Duration(days: _dayOffset));
    dio.get("diary_entries/user/" + _user["user_id"].toString() + "/date/" + date.year.toString() + "-" + date.month.toString() + "-" + date.day.toString()).then((response) {
      if (!mounted) return;
      setState(() {
        _diaryEntries = response.data;
        CacheManager.cacheData("diaryEntries", _diaryEntries);
        _mapMealEntries();
      });
    });
  }

  void _mapMealEntries() {
    Map<String, List<dynamic>> newMealEntriesMap = {};
    for (int i = 0; i < _mealTypeList.length; i++) {
      newMealEntriesMap[_mealTypeList[i]["name"]] = (_diaryEntries ?? []).where((de) => de["meal_type"] == _mealTypeList[i]["name"]).toList();
    }
    if (!mounted) return;
    setState(() {
      _mealEntriesMap = newMealEntriesMap;
    });
  }

  static const List<String> dayNames = [
    "Ponedjeljak",
    "Utorak",
    "Srijeda",
    "Četvrtak",
    "Petak",
    "Subota",
    "Nedjelja",
  ];

  String _getDateText() {
    if (_dayOffset == 0) {
      return "Danas";
    } else if (_dayOffset == -1) {
      return "Jučer";
    } else if (_dayOffset == 1) {
      return "Sutra";
    } else {
      final date = DateTime.now().add(Duration(days: _dayOffset));
      return dayNames[date.weekday - 1] + ", " + date.day.toString().padLeft(2, '0') + "." + date.month.toString().padLeft(2, '0') + "." + date.year.toString() + ".";
    }
  }

  int _getTotalMealCalories(int indexMeal) {
    double sum = 0;
    for (int indexEntry = 0; indexEntry < (_mealEntriesMap[_mealTypeList[indexMeal]["name"]] ?? []).length; indexEntry++) {
      sum += _mealEntriesMap[_mealTypeList[indexMeal]["name"]]![indexEntry]["amount"] * _mealEntriesMap[_mealTypeList[indexMeal]["name"]]![indexEntry]["serving_calories"];
    }
    return sum.round();
  }

  int _getTotalDayCalories() {
    int totalSum = 0;
    for (int indexMeal = 0; indexMeal < _mealTypeList.length; indexMeal++) {
      totalSum += _getTotalMealCalories(indexMeal);
    }
    return totalSum;
  }

  String _removeUnnecessaryDecimals(String input) {
    return input.endsWith(".00")
        ? input.substring(0, input.length - 3)
        : (input.contains(".") && input.endsWith("0"))
            ? input.substring(0, input.length - 1)
            : input;
  }

  void _popEditCallback(value) {
    if (value != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            value["message"],
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: value["error"] == 0
              ? mainColor.withOpacity(0.8)
              : value["error"] == 1
                  ? errorColor.withOpacity(0.8)
                  : null,
        ),
      );
      _getDiaryEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(offset: const Offset(0, 2), blurRadius: 4, color: Colors.black.withOpacity(0.4)),
          ], color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Material(
                child: IconButton(
                  onPressed: () {
                    if (!mounted) return;
                    setState(() {
                      _dayOffset--;
                      CacheManager.cacheData("dayOffset", _dayOffset);
                      _diaryEntries = null;
                      _mealEntriesMap = {};
                      _getDiaryEntries();
                    });
                  },
                  icon: const FaIcon(FontAwesomeIcons.chevronLeft),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: Material(
                    child: InkWell(
                      child: Center(child: Text(_getDateText())),
                      onTap: () {
                        if (!mounted) return;
                        setState(() {
                          _dayOffset = 0;
                          CacheManager.cacheData("dayOffset", _dayOffset);
                          _diaryEntries = null;
                          _mealEntriesMap = {};
                          _getDiaryEntries();
                        });
                      },
                    ),
                  ),
                ),
              ),
              Material(
                child: IconButton(
                  onPressed: () {
                    if (!mounted) return;
                    setState(() {
                      _dayOffset++;
                      CacheManager.cacheData("dayOffset", _dayOffset);
                      _diaryEntries = null;
                      _mealEntriesMap = {};
                      _getDiaryEntries();
                    });
                  },
                  icon: const FaIcon(FontAwesomeIcons.chevronRight),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(offset: const Offset(0, 2), blurRadius: 4, color: Colors.black.withOpacity(0.4)),
          ], color: Colors.white),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: const [
                        Text("Pregled kalorija"),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _dailyCalories.toString(),
                                style: const TextStyle(fontSize: 20),
                              ),
                              const Text(
                                "Cilj",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "-",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                " ",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getTotalDayCalories().toString(),
                                style: const TextStyle(fontSize: 20),
                              ),
                              const Text(
                                "Unos",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "=",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                " ",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                (_dailyCalories - _getTotalDayCalories()).toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: (_dailyCalories - _getTotalDayCalories()) > 0 ? mainColorLight : fatColor,
                                ),
                              ),
                              const Text(
                                "Preostalo",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _mealTypeList.length == 0
            ? const Expanded(
                child: Center(child: RepaintBoundary(child: CircularProgressIndicator())),
              )
            : Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 11),
                    children: List.generate(
                      _mealTypeList.length * 2,
                      (indexMeal) => indexMeal % 2 == 0
                          ? Container(
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(offset: const Offset(0, 2), blurRadius: 4, color: Colors.black.withOpacity(0.4)),
                              ], color: Colors.white),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(15),
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
                                        Text(
                                          _mealTypeList[indexMeal ~/ 2]["name"],
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _getTotalMealCalories(indexMeal ~/ 2).toString(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...List.generate((_mealEntriesMap[_mealTypeList[indexMeal ~/ 2]["name"]] ?? []).length, (indexEntry) {
                                    dynamic currentEntry = _mealEntriesMap[_mealTypeList[indexMeal ~/ 2]["name"]]![indexEntry];
                                    return Material(
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (BuildContext context) => EditPage(
                                                diaryEntry: currentEntry,
                                              ),
                                            ),
                                          ).then((value) => _popEditCallback(value));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(15),
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
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    currentEntry["product_name"],
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  Text(
                                                    _removeUnnecessaryDecimals((currentEntry["serving_size"] * currentEntry["amount"]).toStringAsFixed(2)) + currentEntry["measure_abbreviation"].toString(),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                (currentEntry["serving_calories"] * currentEntry["amount"]).round().toString(),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black.withOpacity(0.25),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: _diaryEntries == null
                                        ? const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: RepaintBoundary(
                                                child: CircularProgressIndicator(),
                                              ),
                                            ),
                                          )
                                        : Row(
                                            children: [
                                              Expanded(
                                                child: Material(
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (BuildContext context) => SearchPage(
                                                            mealType: _mealTypeList[indexMeal ~/ 2],
                                                          ),
                                                        ),
                                                      ).then((value) => _getDiaryEntries());
                                                    },
                                                    child: const Padding(
                                                      padding: EdgeInsets.all(15),
                                                      child: Text(
                                                        "DODAJ HRANU",
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                          color: mainColorLight,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(height: 15),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
