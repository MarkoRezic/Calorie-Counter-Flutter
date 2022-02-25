import 'package:calorie_counter/custom_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EntryPage extends StatefulWidget {
  dynamic mealType;
  dynamic product;
  bool editing;

  EntryPage({
    required this.mealType,
    required this.product,
    this.editing: false,
  });

  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  bool _loading = false;
  TextEditingController amountController = TextEditingController();
  double _amount = 1.0;

  @override
  void initState() {
    super.initState();
    amountController.text = "1.0";
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void _parseAmount() {
    try {
      double testAmount = num.parse(amountController.text).toDouble();
      setState(() {
        _amount = testAmount;
      });
    } on Exception catch (_) {
      setState(() {
        _amount = 0.0;
        amountController.text = "0.0";
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
        title: Text((widget.editing ? "Uredi" : "Dodaj") + " Unos"),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: FaIcon(FontAwesomeIcons.times)),
          IconButton(onPressed: () {}, icon: FaIcon(FontAwesomeIcons.check)),
        ],
      ),
      body: SafeArea(
        child: Column(
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        widget.product["name"].toString(),
                        style: TextStyle(
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
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.4)),
              ], color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
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
                      margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: inputFillColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextFormField(
                        controller: amountController,
                        textAlign: TextAlign.center,
                        onEditingComplete: _parseAmount,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp("(^[0-9]{1,3}[.,]?[0-9]{0,2}\$)")),
                        ],
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: false, decimal: true),
                        validator: (value) {
                          if (value == null ||
                              value.length == 0 ||
                              num.parse(value) == 0) {
                            return 'Molimo unesite količinu.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
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
                                  (widget.product["default_amount"] * _amount)
                                      .toStringAsFixed(2)) +
                              widget.product["measure_abbreviation"].toString(),
                          style: TextStyle(
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
                          style: TextStyle(
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
                    offset: Offset(0, 2),
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
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              macroList[index]["title"].toString(),
                              style: TextStyle(
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
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            micro["title"],
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            (widget.product[micro["key"]] * _amount)
                                    .toStringAsFixed(1) +
                                " " +
                                micro["measure"].toString(),
                            style: TextStyle(
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
      ),
    );
  }
}
