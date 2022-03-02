import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../custom_colors.dart';

class NutritionPage extends StatefulWidget {
  final List<dynamic> diaryEntries;

  const NutritionPage({Key? key, required this.diaryEntries}) : super(key: key);

  @override
  _NutritionPageState createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final dailyNutrients = CacheManager.getData("dailyNutrients");
  final totalNutrients = {
    "proteins": 0,
    "carbs": 0,
    "fats": 0,
    "sugars": 0,
    "fibers": 0,
    "salt": 0,
    "calcium": 0,
    "iron": 0,
  };
  Map<String, double> goalNutritionSplit = {
    "Protein": 23,
    "Ugljikohidrati": 45,
    "Masti": 32,
  };
  Map<String, double> totalNutritionSplit = {
    "Protein": 0,
    "Ugljikohidrati": 0,
    "Masti": 0,
  };

  @override
  void initState() {
    super.initState();
    _calculateTotalNutrients();
    totalNutritionSplit = {
      "Protein": totalNutrients["proteins"]!.roundToDouble(),
      "Ugljikohidrati": totalNutrients["carbs"]!.roundToDouble(),
      "Masti": totalNutrients["fats"]!.roundToDouble(),
    };
  }

  int _getTotalNutrient(String nutrient) {
    double sum = 0;
    for (var entry in widget.diaryEntries) {
      sum += entry[nutrient];
    }
    return sum.round();
  }

  void _calculateTotalNutrients() {
    totalNutrients.forEach((key, value) {
      totalNutrients[key] = _getTotalNutrient(key);
    });
  }

  static const macroList = [
    {
      "key": "proteins",
      "title": "Proteini",
      "color": proteinColor,
    },
    {
      "key": "carbs",
      "title": "Ugljikohidrati",
      "color": carbColor,
    },
    {
      "key": "fats",
      "title": "Masti",
      "color": fatColor,
    },
  ];
  static const microList = [
    {
      "key": "sugars",
      "title": "Šećeri",
      "measure": "g",
    },
    {
      "key": "fibers",
      "title": "Vlakna",
      "measure": "g",
    },
    {
      "key": "salt",
      "title": "Sol",
      "measure": "mg",
    },
    {
      "key": "calcium",
      "title": "Kalcij",
      "measure": "mg",
    },
    {
      "key": "iron",
      "title": "Željezo",
      "measure": "mg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        padding: EdgeInsets.only(
          bottom: 30,
        ),
        children: [
          Container(
            padding: EdgeInsets.all(
              10,
            ),
            margin: EdgeInsets.only(
              top: 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    dataMap: goalNutritionSplit,
                    animationDuration: Duration(milliseconds: 0),
                    chartLegendSpacing: 10,
                    chartRadius: 100,
                    colorList: [
                      proteinColor.withOpacity(0.6),
                      carbColor.withOpacity(0.6),
                      fatColor.withOpacity(0.6),
                    ],
                    initialAngleInDegree: 270,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 14,
                    centerText: "Cilj",
                    legendOptions: LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.bottom,
                      showLegends: true,
                      legendShape: BoxShape.circle,
                      legendTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    chartValuesOptions: ChartValuesOptions(
                      showChartValueBackground: false,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: false,
                      decimalPlaces: 0,
                    ),
                  ),
                ),
                Expanded(
                  child: PieChart(
                    dataMap: totalNutritionSplit,
                    animationDuration: Duration(milliseconds: 0),
                    chartLegendSpacing: 10,
                    chartRadius: 100,
                    colorList: [
                      proteinColor,
                      carbColor,
                      fatColor,
                    ],
                    initialAngleInDegree: 270,
                    chartType: ChartType.ring,
                    ringStrokeWidth: 14,
                    centerText: "Unos",
                    legendOptions: LegendOptions(
                      showLegendsInRow: false,
                      legendPosition: LegendPosition.bottom,
                      showLegends: true,
                      legendShape: BoxShape.circle,
                      legendTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    chartValuesOptions: ChartValuesOptions(
                      showChartValueBackground: false,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: false,
                      decimalPlaces: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            thickness: 2,
            height: 2,
          ),
          Container(
            constraints: BoxConstraints(
              minHeight: 50,
            ),
            padding: EdgeInsets.all(
              5,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Unos",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Cilj",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Preostalo",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            thickness: 2,
            height: 2,
          ),
          ...List.generate(
            macroList.length * 2,
            (index) => index % 2 == 0
                ? Container(
                    constraints: BoxConstraints(
                      minHeight: 50,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                macroList[index ~/ 2]["title"].toString(),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      totalNutrients[macroList[index ~/ 2]["key"]].toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      dailyNutrients[macroList[index ~/ 2]["key"]].toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      (dailyNutrients[macroList[index ~/ 2]["key"]] - totalNutrients[macroList[index ~/ 2]["key"]]).toString() + "g",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: (dailyNutrients[macroList[index ~/ 2]["key"]] - totalNutrients[macroList[index ~/ 2]["key"]]) >= 0 ? Colors.black : fatColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 5,
                                ),
                                child: LinearProgressIndicator(
                                  value: totalNutrients[macroList[index ~/ 2]["key"]]! < dailyNutrients[macroList[index ~/ 2]["key"]] ? (totalNutrients[macroList[index ~/ 2]["key"]]! / dailyNutrients[macroList[index ~/ 2]["key"]]) : 1,
                                  backgroundColor: Colors.black.withOpacity(0.2),
                                  color: macroList[index ~/ 2]["color"] as Color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const Divider(
                    thickness: 2,
                    height: 2,
                  ),
          ),
          ...List.generate(
            microList.length * 2,
            (index) => index % 2 == 0
                ? Container(
                    constraints: BoxConstraints(
                      minHeight: 50,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                microList[index ~/ 2]["title"].toString(),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      totalNutrients[microList[index ~/ 2]["key"]].toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      dailyNutrients[microList[index ~/ 2]["key"]].toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      (dailyNutrients[microList[index ~/ 2]["key"]] - totalNutrients[microList[index ~/ 2]["key"]]).toString() + microList[index ~/ 2]["measure"].toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: (dailyNutrients[microList[index ~/ 2]["key"]] - totalNutrients[microList[index ~/ 2]["key"]]) >= 0 ? Colors.black : fatColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  top: 5,
                                ),
                                child: LinearProgressIndicator(
                                  value: totalNutrients[microList[index ~/ 2]["key"]]! < dailyNutrients[microList[index ~/ 2]["key"]] ? (totalNutrients[microList[index ~/ 2]["key"]]! / dailyNutrients[microList[index ~/ 2]["key"]]) : 1,
                                  backgroundColor: Colors.black.withOpacity(0.2),
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const Divider(
                    thickness: 2,
                    height: 2,
                  ),
          ),
        ],
      ),
    );
  }
}
