import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:calorie_counter/views/navigation/searchPage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic user = CacheManager.getData("user");
  int dayOffset = 0;
  List<dynamic> mealTypeList = [];
  List<dynamic>? diaryEntries;
  Map<String, List<dynamic>> mealEntriesMap = {};

  @override
  void initState() {
    super.initState();
    if (CacheManager.getData("dayOffset") != null) {
      setState(() {
        dayOffset = CacheManager.getData("dayOffset");
      });
    } else {
      CacheManager.cacheData("dayOffset", dayOffset);
    }
    _getMealTypes();
    _getDiaryEntries();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (CacheManager.getData("dayOffset") != dayOffset) {
      setState(() {
        dayOffset = CacheManager.getData("dayOffset") ?? 0;
        diaryEntries = null;
        mealEntriesMap = {};
        _getDiaryEntries();
      });
    }
  }

  void _getMealTypes() {
    Dio dio = Dio();
    dio.get("http://10.0.2.2:3000/attributes/meal_types").then((response) {
      //print(response);
      setState(() {
        mealTypeList = response.data;
      });
    });
  }

  void _getDiaryEntries() {
    Dio dio = Dio();
    final date = DateTime.now().add(Duration(days: dayOffset));
    dio
        .get("http://10.0.2.2:3000/diary_entries/user/" +
            user["user_id"].toString() +
            "/date/" +
            date.year.toString() +
            "-" +
            date.month.toString() +
            "-" +
            date.day.toString())
        .then((response) {
      //print(response);
      setState(() {
        diaryEntries = response.data;
        _mapMealEntries();
      });
    });
  }

  void _mapMealEntries() {
    Map<String, List<dynamic>> newMealEntriesMap = {};
    for (int i = 0; i < mealTypeList.length; i++) {
      newMealEntriesMap[mealTypeList[i]["name"]] = (diaryEntries ?? [])
          .where((de) => de["meal_type"] == mealTypeList[i]["name"])
          .toList();
    }
    setState(() {
      mealEntriesMap = newMealEntriesMap;
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
    if (dayOffset == 0)
      return "Danas";
    else if (dayOffset == -1)
      return "Jučer";
    else if (dayOffset == 1)
      return "Sutra";
    else {
      final date = DateTime.now().add(Duration(days: dayOffset));
      return dayNames[date.weekday - 1] +
          ", " +
          date.day.toString().padLeft(2, '0') +
          "." +
          date.month.toString().padLeft(2, '0') +
          "." +
          date.year.toString() +
          ".";
    }
  }

  int _getTotalMealCalories(int indexMeal) {
    double sum = 0;
    //print("TEST" + mealEntriesMap[mealTypeList[indexMeal]["name"]].toString());
    for (int indexEntry = 0;
        indexEntry <
            (mealEntriesMap[mealTypeList[indexMeal]["name"]] ?? []).length;
        indexEntry++) {
      sum += mealEntriesMap[mealTypeList[indexMeal]["name"]]![indexEntry]
              ["amount"] *
          mealEntriesMap[mealTypeList[indexMeal]["name"]]![indexEntry]
              ["serving_calories"];
    }
    print(sum);
    return sum.round();
  }

  int _getTotalDayCalories() {
    int totalSum = 0;
    for (int indexMeal = 0; indexMeal < mealTypeList.length; indexMeal++) {
      totalSum += _getTotalMealCalories(indexMeal);
    }
    return totalSum;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.4)),
          ], color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Material(
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      dayOffset--;
                      CacheManager.cacheData("dayOffset", dayOffset);
                      setState(() {
                        diaryEntries = null;
                        mealEntriesMap = {};
                        _getDiaryEntries();
                      });
                    });
                  },
                  icon: FaIcon(FontAwesomeIcons.chevronLeft),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: Material(
                    child: InkWell(
                      child: Center(child: Text(_getDateText())),
                      onTap: () {
                        setState(() {
                          dayOffset = 0;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Material(
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      dayOffset++;
                      CacheManager.cacheData("dayOffset", dayOffset);
                      setState(() {
                        diaryEntries = null;
                        mealEntriesMap = {};
                        _getDiaryEntries();
                      });
                    });
                  },
                  icon: FaIcon(FontAwesomeIcons.chevronRight),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.4)),
          ], color: Colors.white),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text("Pregled kalorija"),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                CacheManager.getData("dailyCalories")
                                    .toString(),
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
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
                            children: [
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
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
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
                            children: [
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
                                (CacheManager.getData("dailyCalories") -
                                        _getTotalDayCalories())
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: mainColorLight,
                                ),
                              ),
                              Text(
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
        mealTypeList.length == 0
            ? Expanded(
                child: Center(
                    child: RepaintBoundary(child: CircularProgressIndicator())),
              )
            : Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 11),
                    children: List.generate(
                      mealTypeList.length * 2,
                      (indexMeal) => indexMeal % 2 == 0
                          ? Container(
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.4)),
                              ], color: Colors.white),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black.withOpacity(0.25),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          mealTypeList[indexMeal ~/ 2]["name"],
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _getTotalMealCalories(indexMeal ~/ 2)
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...List.generate(
                                      (mealEntriesMap[
                                                  mealTypeList[indexMeal ~/ 2]
                                                      ["name"]] ??
                                              [])
                                          .length, (indexEntry) {
                                    dynamic currentEntry = mealEntriesMap[
                                        mealTypeList[indexMeal ~/ 2]
                                            ["name"]]![indexEntry];
                                    return Material(
                                      child: InkWell(
                                        onTap: () {},
                                        child: Container(
                                          padding: EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.black
                                                    .withOpacity(0.25),
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    currentEntry[
                                                        "product_name"],
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  Text(
                                                    (currentEntry["serving_size"] *
                                                                currentEntry[
                                                                    "amount"])
                                                            .toString() +
                                                        currentEntry[
                                                                "measure_abbreviation"]
                                                            .toString(),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                (currentEntry[
                                                            "serving_calories"] *
                                                        currentEntry["amount"])
                                                    .toString(),
                                                style: TextStyle(
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
                                    child: diaryEntries == null
                                        ? Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: RepaintBoundary(
                                                child:
                                                    CircularProgressIndicator(),
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
                                                          builder: (BuildContext
                                                                  context) =>
                                                              SearchPage(
                                                            mealType:
                                                                mealTypeList[
                                                                    indexMeal ~/
                                                                        2],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(15),
                                                      child: Text(
                                                        "DODAJ HRANU",
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                          : SizedBox(height: 15),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
