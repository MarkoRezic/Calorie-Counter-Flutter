import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProgressPage extends StatefulWidget {
  ProgressPage({Key? key}) : super(key: key);

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  dynamic _user = CacheManager.getData("user");
  final int _dailyCalories = CacheManager.getData("dailyCalories") ?? 0;
  List<ProgressSeries>? _progressData;
  int _periodType = 0;
  List<charts.Series<ProgressSeries, String>> _chartSeries = [];
  int _totalCalories = 0;
  int _totalGoalCalories = 0;

  @override
  void initState() {
    super.initState();
    _getProgressData();
  }

  String _getWeekPeriod(DateTime weekStart) {
    DateTime weekEnd = weekStart.add(Duration(days: 6));
    return weekStart.day.toString().padLeft(2, '0') + '.' + weekStart.month.toString().padLeft(2, '0') + '.-' + weekEnd.day.toString().padLeft(2, '0') + '.' + weekEnd.month.toString().padLeft(2, '0') + '.';
  }

  int _getTotalCalories(List<ProgressSeries> series) {
    int sum = 0;
    for (var element in series) {
      sum += element.calories;
    }
    return sum;
  }

  List<ProgressSeries> _getEmptyProgressData() {
    switch (_periodType) {
      case 0:
        final startDay = DateTime.now().subtract(Duration(days: 6)).weekday - 1;
        final goalSeries = ProgressSeries(
          timestamp: "Cilj",
          calories: CacheManager.getData("dailyCalories"),
          barColor: charts.ColorUtil.fromDartColor(mainColorLight),
        );
        final spacerSeries = ProgressSeries(
          timestamp: "",
          calories: 0,
          barColor: charts.ColorUtil.fromDartColor(Colors.grey),
        );
        return [
          ...List.generate(
              7,
              (index) => ProgressSeries(
                    timestamp: dayNames[(startDay + index) % 7].substring(0, 3),
                    calories: 0,
                    barColor: charts.ColorUtil.fromDartColor(Colors.grey),
                  )),
          spacerSeries,
          goalSeries,
        ];
      case 1:
        DateTime startOfWeek = DateTime.now().subtract(Duration(days: 23));
        startOfWeek = startOfWeek.subtract(Duration(days: startOfWeek.weekday - 1));
        final goalSeries = ProgressSeries(
          timestamp: "Cilj",
          calories: CacheManager.getData("dailyCalories") * 7,
          barColor: charts.ColorUtil.fromDartColor(mainColorLight),
        );
        final spacerSeries = ProgressSeries(
          timestamp: "",
          calories: 0,
          barColor: charts.ColorUtil.fromDartColor(Colors.grey),
        );
        return [
          ...List.generate(
              4,
              (index) => ProgressSeries(
                    timestamp: _getWeekPeriod(startOfWeek.add(Duration(days: 7 * index))),
                    calories: 0,
                    barColor: charts.ColorUtil.fromDartColor(Colors.grey),
                  )),
          spacerSeries,
          goalSeries,
        ];
      case 2:
        final startMonth = DateTime.now().subtract(Duration(days: 365 - 31)).month - 1;
        final goalSeries = ProgressSeries(
          timestamp: "Cilj",
          calories: CacheManager.getData("dailyCalories") * monthMap[DateTime.now().month - 1]["days"],
          barColor: charts.ColorUtil.fromDartColor(mainColorLight),
        );
        final spacerSeries = ProgressSeries(
          timestamp: "",
          calories: 0,
          barColor: charts.ColorUtil.fromDartColor(Colors.grey),
        );
        return [
          ...List.generate(
              12,
              (index) => ProgressSeries(
                    timestamp: monthMap[(startMonth + index) % 7]["short_name"],
                    calories: 0,
                    barColor: charts.ColorUtil.fromDartColor(Colors.grey),
                  )),
          spacerSeries,
          goalSeries,
        ];
      default:
        final startYear = DateTime.now().subtract(Duration(days: 4 * 365 + 1));
        final goalSeries = ProgressSeries(
          timestamp: "Cilj",
          calories: CacheManager.getData("dailyCalories") * (365),
          barColor: charts.ColorUtil.fromDartColor(mainColorLight),
        );
        final spacerSeries = ProgressSeries(
          timestamp: "",
          calories: 0,
          barColor: charts.ColorUtil.fromDartColor(Colors.grey),
        );
        return [
          ...List.generate(
              5,
              (index) => ProgressSeries(
                    timestamp: startYear.add(Duration(days: 365 * index)).year.toString(),
                    calories: 0,
                    barColor: charts.ColorUtil.fromDartColor(Colors.grey),
                  )),
          spacerSeries,
          goalSeries,
        ];
    }
  }

  void _getProgressData() {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL'),
      ),
    );
    dio
        .get("diary_entries/progress/" +
            _user["user_id"].toString() +
            "/period/" +
            (_periodType == 0
                ? "week"
                : _periodType == 1
                    ? "month"
                    : _periodType == 2
                        ? "year"
                        : "all"))
        .then((response) {
      if (!mounted) return;
      print(response.data);
      final emptyProgressData = _getEmptyProgressData();
      setState(() {
        switch (_periodType) {
          case 0:
            _progressData = response.data
                .map<ProgressSeries>((d) => ProgressSeries(
                      timestamp: dayNames[DateTime.parse(d["datetime"]).weekday - 1].substring(0, 3),
                      calories: d["total_calories"],
                      barColor: charts.ColorUtil.fromDartColor(mainColor),
                    ))
                .toList();
            for (var pd in _progressData!) {
              final index = emptyProgressData.indexWhere((element) => element.timestamp == pd.timestamp);
              if (index > 0) {
                emptyProgressData[index] = pd;
              }
            }
            _totalCalories = _getTotalCalories(_progressData!);
            _progressData = emptyProgressData;
            break;
          case 1:
            _progressData = response.data
                .map<ProgressSeries>((d) => ProgressSeries(
                      timestamp: _getWeekPeriod(DateTime.parse(d["week_start"])),
                      calories: d["total_calories"],
                      barColor: charts.ColorUtil.fromDartColor(mainColor),
                    ))
                .toList();
            for (var pd in _progressData!) {
              final index = emptyProgressData.indexWhere((element) => element.timestamp == pd.timestamp);
              if (index > 0) {
                emptyProgressData[index] = pd;
              }
            }
            _totalCalories = _getTotalCalories(_progressData!);
            _progressData = emptyProgressData;
            break;
          case 2:
            _progressData = response.data
                .map<ProgressSeries>((d) => ProgressSeries(
                      timestamp: monthMap[DateTime.parse(d["month_start"]).month - 1]["short_name"],
                      calories: d["total_calories"],
                      barColor: charts.ColorUtil.fromDartColor(mainColor),
                    ))
                .toList();
            for (var pd in _progressData!) {
              final index = emptyProgressData.indexWhere((element) => element.timestamp == pd.timestamp);
              if (index > 0) {
                emptyProgressData[index] = pd;
              }
            }
            _totalCalories = _getTotalCalories(_progressData!);
            _progressData = emptyProgressData;
            break;
          default:
            _progressData = response.data
                .map<ProgressSeries>((d) => ProgressSeries(
                      timestamp: d["year_start"].toString(),
                      calories: d["total_calories"],
                      barColor: charts.ColorUtil.fromDartColor(mainColor),
                    ))
                .toList();
            for (var pd in _progressData!) {
              final index = emptyProgressData.indexWhere((element) => element.timestamp == pd.timestamp);
              if (index > 0) {
                emptyProgressData[index] = pd;
              }
            }
            _totalCalories = _getTotalCalories(_progressData!);
            _progressData = emptyProgressData;
        }
        _totalGoalCalories = _dailyCalories *
            (_periodType == 0
                ? 7
                : _periodType == 1
                    ? monthMap[DateTime.now().month - 1]["days"] as int
                    : _periodType == 2
                        ? 365
                        : (5 * 365 + 1));
        print("Progress data: " + _progressData.toString());
        _chartSeries = [
          charts.Series<ProgressSeries, String>(
            id: "Progress",
            data: _progressData!,
            domainFn: (ProgressSeries series, _) => series.timestamp,
            measureFn: (ProgressSeries series, _) => series.calories,
            colorFn: (ProgressSeries series, _) => series.barColor,
          )
        ];
        print("Chart series: " + _chartSeries.toString());
      });
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

  static const List<Map<String, dynamic>> monthMap = [
    {
      "name": "Siječanj",
      "days": 31,
      "short_name": "Sij",
    },
    {
      "name": "Veljača",
      "days": 28,
      "short_name": "Velj",
    },
    {
      "name": "Ožujak",
      "days": 31,
      "short_name": "Ožu",
    },
    {
      "name": "Travanj",
      "days": 30,
      "short_name": "Trav",
    },
    {
      "name": "Svibanj",
      "days": 31,
      "short_name": "Svi",
    },
    {
      "name": "Lipanj",
      "days": 30,
      "short_name": "Lip",
    },
    {
      "name": "Srpanj",
      "days": 31,
      "short_name": "Srp",
    },
    {
      "name": "Kolovoz",
      "days": 31,
      "short_name": "Kol",
    },
    {
      "name": "Rujan",
      "days": 30,
      "short_name": "Ruj",
    },
    {
      "name": "Listopad",
      "days": 31,
      "short_name": "Lis",
    },
    {
      "name": "Studeni",
      "days": 30,
      "short_name": "Stu",
    },
    {
      "name": "Prosinac",
      "days": 31,
      "short_name": "Pro",
    },
  ];

  String _removeUnnecessaryDecimals(String input) {
    return input.endsWith(".00")
        ? input.substring(0, input.length - 3)
        : (input.contains(".") && input.endsWith("0"))
            ? input.substring(0, input.length - 1)
            : input;
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
                      _periodType = _periodType == 0 ? 3 : (_periodType - 1);
                      _getProgressData();
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
                      child: Center(
                          child: Text(_periodType == 0
                              ? "Tjedan"
                              : _periodType == 1
                                  ? "Mjesec"
                                  : _periodType == 2
                                      ? "Godina"
                                      : "5 Godina")),
                      onTap: () {
                        if (!mounted) return;
                        setState(() {
                          _periodType = 0;
                          _getProgressData();
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
                      _periodType = (_periodType + 1) % 4;
                      _getProgressData();
                    });
                  },
                  icon: const FaIcon(FontAwesomeIcons.chevronRight),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        _progressData == null
            ? const Expanded(
                child: Center(child: RepaintBoundary(child: CircularProgressIndicator())),
              )
            : Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 300,
                      padding: EdgeInsets.all(10),
                      child: charts.BarChart(
                        _chartSeries,
                        animate: true,
                        domainAxis: charts.OrdinalAxisSpec(
                          renderSpec: charts.SmallTickRendererSpec(labelRotation: 60),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(offset: const Offset(0, 2), blurRadius: 4, color: Colors.black.withOpacity(0.4)),
                      ], color: Colors.white),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Uneseno kalorija u " +
                                        (_periodType == 0
                                            ? "tjednu"
                                            : _periodType == 1
                                                ? "mjesecu"
                                                : _periodType == 2
                                                    ? "godini"
                                                    : "5 godina") +
                                        ": " +
                                        _totalCalories.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Od ciljanih: " + _totalGoalCalories.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  " (" + ((_totalCalories / _totalGoalCalories) * 100).toStringAsFixed(2) + "%)",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  (_periodType == 0
                                          ? "Dnevni "
                                          : _periodType == 1
                                              ? "Tjedni "
                                              : _periodType == 2
                                                  ? "Mjesečni "
                                                  : "Godišnji ") +
                                      "cilj: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _periodType == 0
                                      ? _dailyCalories.toString()
                                      : _periodType == 1
                                          ? (_dailyCalories * 7).toString()
                                          : _periodType == 2
                                              ? (_dailyCalories * monthMap[DateTime.now().month - 1]["days"]).toString()
                                              : (_dailyCalories * 365).toString(),
                                  style: TextStyle(
                                    color: mainColorLight,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  " (" +
                                      ((_progressData![_progressData!.length - 3].calories /
                                                  (_periodType == 0
                                                      ? _dailyCalories
                                                      : _periodType == 1
                                                          ? (_dailyCalories * 7)
                                                          : _periodType == 2
                                                              ? (_dailyCalories * monthMap[DateTime.now().month - 1]["days"])
                                                              : (_dailyCalories * 365))) *
                                              100)
                                          .toStringAsFixed(2) +
                                      "%)",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}

/// Progress period data type.
class ProgressSeries {
  final String timestamp;
  final int calories;
  final charts.Color barColor;

  ProgressSeries({
    required this.timestamp,
    required this.calories,
    required this.barColor,
  });
}
