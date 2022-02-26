import 'package:calorie_counter/custom_colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditPage extends StatefulWidget {
  final dynamic diaryEntry;

  const EditPage({
    Key? key,
    required this.diaryEntry,
  }) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  bool _loadingProduct = true;
  bool _loading = false;
  final TextEditingController _amountController = TextEditingController();
  double _amount = 1.0;
  dynamic _product;

  @override
  void initState() {
    super.initState();
    _amount = widget.diaryEntry["amount"].toDouble();
    _amountController.text = widget.diaryEntry["amount"].toString();
    _getProduct();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _getProduct() {
    if (!mounted) return;
    Dio dio = Dio();
    dio
        .get("http://10.0.2.2:3000/products/" +
            widget.diaryEntry["product_id"].toString())
        .then((response) {
      print(response.data[0]);
      if (mounted) {
        setState(() {
          _product = response.data[0];
          _loadingProduct = false;
        });
      }
    });
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

  void _updateEntry() {
    if (_amount == 0) {
      return _deleteEntry();
    }
    if (!mounted) return;
    setState(() {
      _loading = true;
      FocusScope.of(context).unfocus();
    });
    Dio dio = Dio();
    try {
      dio.put(
        "http://10.0.2.2:3000/diary_entries",
        data: {
          "diary_entry_id": widget.diaryEntry["diary_entry_id"],
          "amount": _amount,
        },
      ).then((response) {
        //print(response);
        if (mounted) {
          return Navigator.pop(context, {
            "error": 0,
            "message": "Uređen proizvod " + widget.diaryEntry["product_name"],
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

  void _deleteEntry() {
    if (!mounted) return;
    setState(() {
      _loading = true;
      FocusScope.of(context).unfocus();
    });
    Dio dio = Dio();
    try {
      dio
          .delete(
        "http://10.0.2.2:3000/diary_entries/" +
            widget.diaryEntry["diary_entry_id"].toString(),
      )
          .then((response) {
        //print(response);
        if (mounted) {
          return Navigator.pop(context, {
            "error": 0,
            "message": "Izbrisan proizvod " + widget.diaryEntry["product_name"],
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
        title: const Text("Uredi Unos"),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () {
                _deleteEntry();
              },
              icon: const FaIcon(FontAwesomeIcons.times)),
          IconButton(
              onPressed: () {
                _updateEntry();
              },
              icon: const FaIcon(FontAwesomeIcons.check)),
        ],
      ),
      body: SafeArea(
        child: _loadingProduct
            ? const Center(
                child: RepaintBoundary(
                  child: CircularProgressIndicator(),
                ),
              )
            : Stack(
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
                                  _product["name"].toString(),
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
                                    FilteringTextInputFormatter.allow(RegExp(
                                        "(^[0-9]{0,3}[.,]?[0-9]{0,2}\$)")),
                                  ],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
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
                                            (_product["default_amount"] *
                                                    _amount)
                                                .toStringAsFixed(2)) +
                                        _product["measure_abbreviation"]
                                            .toString(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    "(" +
                                        _product["default_amount"].toString() +
                                        _product["measure_abbreviation"]
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    children: [
                                      Text(
                                        (_product[macroList[index]["key"]] *
                                                    _amount)
                                                .toStringAsFixed(1) +
                                            "g",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: macroList[index]["color"]
                                              as Color,
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  children: [
                                    Text(
                                      ((_product["serving_calories"] * _amount)
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      micro["title"],
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      (_product[micro["key"]] * _amount)
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
