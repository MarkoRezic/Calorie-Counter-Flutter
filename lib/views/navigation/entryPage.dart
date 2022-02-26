import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EntryPage extends StatefulWidget {
  final dynamic mealType;
  final dynamic product;

  const EntryPage({
    Key? key,
    required this.mealType,
    required this.product,
  }) : super(key: key);

  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  bool _loading = false;
  final TextEditingController _amountController = TextEditingController();
  double _amount = 1.0;

  @override
  void initState() {
    super.initState();
    _amountController.text = "1.0";
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _parseAmount(String? value) {
    try {
      _amountController.text = _amountController.text.replaceAll(",", ".");
      _amountController.selection = TextSelection.fromPosition(
          TextPosition(offset: _amountController.text.length));
      if (_amountController.text != ".") {
        double testAmount = num.parse(_amountController.text).toDouble();
        setState(() {
          _amount = testAmount;
        });
      } else {
        setState(() {
          _amount = 0.0;
        });
      }
    } on Exception catch (_) {
      setState(() {
        _amount = 0;
        _amountController.clear();
      });
    }
  }

  String _removeUnnecessaryDecimals(String input) {
    return input.endsWith(".00")
        ? input.substring(0, input.length - 3)
        : (input.contains(".") && input.endsWith("0"))
            ? input.substring(0, input.length - 1)
            : input;
  }

  void _addEntry() {
    if (_amount == 0) {
      return Navigator.pop(context);
    }
    if (!mounted) return;
    setState(() {
      _loading = true;
      FocusScope.of(context).unfocus();
    });
    Dio dio = Dio();
    dynamic user = CacheManager.getData("user");
    DateTime date =
        DateTime.now().add(Duration(days: CacheManager.getData("dayOffset")));
    String dateString = date.year.toString() +
        "-" +
        date.month.toString() +
        "-" +
        date.day.toString();
    try {
      dio.post(
        "http://10.0.2.2:3000/diary_entries",
        data: {
          "user_id": user["user_id"],
          "product_id": widget.product["product_id"],
          "meal_type_id": widget.mealType["meal_type_id"],
          "amount": _amount,
          "datetime": dateString,
        },
      ).then((response) {
        //print(response);
        if (mounted) {
          return Navigator.pop(context, {
            "error": 0,
            "message": "Dodan proizvod " + widget.product["name"],
          });
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

  static const macroList = [
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
    {
      "key": "proteins",
      "title": "Proteini",
      "color": proteinColor,
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Dodaj Unos"),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const FaIcon(FontAwesomeIcons.times)),
          IconButton(
              onPressed: () {
                _addEntry();
              },
              icon: const FaIcon(FontAwesomeIcons.check)),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.4)),
                  ], color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Text(
                            widget.product["name"].toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.4)),
                  ], color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          "Količina",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: inputFillColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextFormField(
                            controller: _amountController,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            onEditingComplete: () => _parseAmount,
                            onChanged: _parseAmount,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp("(^[0-9]{0,3}[.,]?[0-9]{0,2}\$)")),
                            ],
                            keyboardType: const TextInputType.numberWithOptions(
                                signed: false, decimal: true),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  num.parse(value) == 0) {
                                return 'Molimo unesite količinu.';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: 'količina',
                              border: InputBorder.none,
                              isDense: false,
                              isCollapsed: false,
                              contentPadding: EdgeInsets.all(15),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _removeUnnecessaryDecimals(
                                      (widget.product["default_amount"] *
                                              _amount)
                                          .toStringAsFixed(2)) +
                                  widget.product["measure_abbreviation"]
                                      .toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "(" +
                                  widget.product["default_amount"].toString() +
                                  widget.product["measure_abbreviation"]
                                      .toString() +
                                  " porcija)",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.4)),
                  ], color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...List.generate(
                        macroList.length,
                        (index) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              children: [
                                Text(
                                  (widget.product[macroList[index]["key"]] *
                                              _amount)
                                          .toStringAsFixed(1) +
                                      "g",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: macroList[index]["color"] as Color,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  macroList[index]["title"].toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              Text(
                                ((widget.product["serving_calories"] * _amount)
                                        .round())
                                    .toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              const Text(
                                "Kalorije",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ListView(
                      shrinkWrap: true,
                      children: List.generate(microList.length, (index) {
                        dynamic micro = microList[index];
                        return Container(
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
                                micro["title"],
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                (widget.product[micro["key"]] * _amount)
                                        .toStringAsFixed(1) +
                                    " " +
                                    micro["measure"].toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
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
