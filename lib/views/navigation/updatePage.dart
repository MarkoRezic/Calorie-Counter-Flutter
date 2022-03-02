import 'package:calorie_counter/custom_colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UpdatePage extends StatefulWidget {
  final dynamic product;
  const UpdatePage({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  bool _loading = false;
  List<dynamic> _measureTypeList = [];
  double _defaultAmount = 100;
  dynamic _measureType;
  double _proteins = 0.0;
  double _carbs = 0.0;
  double _fats = 0.0;
  double _sugars = 0.0;
  double _fibers = 0.0;
  double _salt = 0.0;
  double _calcium = 0.0;
  double _iron = 0.0;

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _defaultAmountController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _proteinsController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatsController = TextEditingController();
  final TextEditingController _sugarsController = TextEditingController();
  final TextEditingController _fibersController = TextEditingController();
  final TextEditingController _saltController = TextEditingController();
  final TextEditingController _calciumController = TextEditingController();
  final TextEditingController _ironController = TextEditingController();

  late final List<TextEditingController> _controllerList;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _productNameController.text = widget.product["name"].toString();
    _defaultAmountController.text = widget.product["default_amount"].toString();
    _barcodeController.text = widget.product["barcode"] ?? "";
    _controllerList = [_proteinsController, _carbsController, _fatsController, _sugarsController, _fibersController, _saltController, _calciumController, _ironController];
    _proteinsController.text = widget.product["proteins"].toString();
    _carbsController.text = widget.product["carbs"].toString();
    _fatsController.text = widget.product["fats"].toString();
    _sugarsController.text = widget.product["sugars"].toString();
    _fibersController.text = widget.product["fibers"].toString();
    _saltController.text = widget.product["salt"].toString();
    _calciumController.text = widget.product["calcium"].toString();
    _ironController.text = widget.product["iron"].toString();
    for (var macro in macroList) {
      _parseAmountIndexed(macro["controllerIndex"] as int);
    }
    for (var micro in microList) {
      _parseAmountIndexed(micro["controllerIndex"] as int);
    }
    _getMeasureTypes();
  }

  @override
  void dispose() {
    _defaultAmountController.dispose();
    _productNameController.dispose();
    _barcodeController.dispose();
    for (var element in _controllerList) {
      element.dispose();
    }
    super.dispose();
  }

  void _getMeasureTypes() async {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL'),
      ),
    );
    dio.get("attributes/measure_types").then((response) {
      setState(() {
        _measureTypeList = response.data;
        _measureType = _measureTypeList[0];
      });
    });
  }

  void _parseAmount(String? value) {
    try {
      _defaultAmountController.text = _defaultAmountController.text.replaceAll(",", ".");
      _defaultAmountController.selection = TextSelection.fromPosition(TextPosition(offset: _defaultAmountController.text.length));
      if (_defaultAmountController.text != ".") {
        double testAmount = num.parse(_defaultAmountController.text).toDouble();
        setState(() {
          _defaultAmount = testAmount;
        });
      } else {
        setState(() {
          _defaultAmount = 0;
        });
      }
    } on Exception catch (_) {
      setState(() {
        _defaultAmount = 0;
        _defaultAmountController.clear();
      });
    }
  }

  void _parseAmountIndexed(int controllerIndex) {
    try {
      _controllerList[controllerIndex].text = _controllerList[controllerIndex].text.replaceAll(",", ".");
      _controllerList[controllerIndex].selection = TextSelection.fromPosition(TextPosition(offset: _controllerList[controllerIndex].text.length));
      if (_controllerList[controllerIndex].text != ".") {
        double testAmount = num.parse(_controllerList[controllerIndex].text).toDouble();
        _indexedSetter(controllerIndex, testAmount);
      } else {
        _indexedSetter(controllerIndex, 0);
      }
    } on Exception catch (_) {
      _indexedSetter(controllerIndex, 0);
      setState(() {
        _controllerList[controllerIndex].clear();
      });
    }
  }

  void _indexedSetter(int index, double testAmount) {
    setState(() {
      switch (index) {
        case 0:
          _proteins = testAmount;
          break;
        case 1:
          _carbs = testAmount;
          break;
        case 2:
          _fats = testAmount;
          break;
        case 3:
          _sugars = testAmount;
          break;
        case 4:
          _fibers = testAmount;
          break;
        case 5:
          _salt = testAmount;
          break;
        case 6:
          _calcium = testAmount;
          break;
        case 7:
          _iron = testAmount;
          break;
      }
    });
  }

  void _updateProduct() {
    if (formKey.currentState!.validate() == false) return;
    if (_defaultAmount == 0) {
      return Navigator.pop(context);
    }
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
        "products",
        data: {
          "product_id": widget.product["product_id"],
          "name": _productNameController.text,
          "default_amount": _defaultAmount,
          "measure_type_id": _measureType["measure_type_id"],
          "barcode": _barcodeController.text.isEmpty ? null : _barcodeController.text,
          "proteins": _proteins,
          "carbs": _carbs,
          "fats": _fats,
          "sugars": _sugars,
          "fibers": _fibers,
          "salt": _salt,
          "calcium": _calcium,
          "iron": _iron,
        },
      ).then((response) {
        //print(response);
        if (mounted) {
          return Navigator.pop(context, {
            "error": 0,
            "message": "Ažuriran proizvod " + _productNameController.text,
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

  void _deleteProduct() {
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
      dio
          .delete(
        "products/" + widget.product["product_id"].toString(),
      )
          .then((response) {
        //print(response);
        if (mounted) {
          return Navigator.pop(context, {
            "error": 0,
            "message": "Izbrisan proizvod " + widget.product["name"],
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

  bool _validBarcode() {
    if (_barcodeController.text.isEmpty) return true;
    if (!RegExp(r'^[0-9]{13}$').hasMatch(_barcodeController.text)) return false;
    int oddSum = 0;
    int evenSum = 0;
    for (int i = 0; i < 12; i++) {
      if ((i + 1) % 2 == 1) {
        oddSum += int.parse(_barcodeController.text[i]);
      } else {
        evenSum += int.parse(_barcodeController.text[i]);
      }
    }
    evenSum *= 3;
    int checkDigit = (oddSum + evenSum) % 10;
    checkDigit = checkDigit == 0 ? 0 : (10 - checkDigit);
    return checkDigit.toString() == _barcodeController.text[12];
  }

  final macroList = [
    {
      "key": "carbs",
      "controllerIndex": 1,
      "title": "Ugljikohidrati",
      "color": carbColor,
    },
    {
      "key": "fats",
      "controllerIndex": 2,
      "title": "Masti",
      "color": fatColor,
    },
    {
      "key": "proteins",
      "controllerIndex": 0,
      "title": "Proteini",
      "color": proteinColor,
    },
  ];
  static const microList = [
    {
      "key": "sugars",
      "controllerIndex": 3,
      "title": "Šećeri",
      "measure": "g",
    },
    {
      "key": "fibers",
      "controllerIndex": 4,
      "title": "Vlakna",
      "measure": "g",
    },
    {
      "key": "salt",
      "controllerIndex": 5,
      "title": "Sol",
      "measure": "mg",
    },
    {
      "key": "calcium",
      "controllerIndex": 6,
      "title": "Kalcij",
      "measure": "mg",
    },
    {
      "key": "iron",
      "controllerIndex": 7,
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
        title: const Text("Ažuriraj Proizvod"),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () {
                _deleteProduct();
              },
              icon: const FaIcon(FontAwesomeIcons.times)),
          IconButton(
              onPressed: () {
                _updateProduct();
              },
              icon: const FaIcon(FontAwesomeIcons.check)),
        ],
      ),
      body: SafeArea(
        child: _measureTypeList.isEmpty
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
                        Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(offset: const Offset(0, 2), blurRadius: 4, color: Colors.black.withOpacity(0.4)),
                          ], color: Colors.white),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: inputFillColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: TextFormField(
                                    controller: _productNameController,
                                    onEditingComplete: () {
                                      formKey.currentState!.validate();
                                      FocusScope.of(context).unfocus();
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Molimo unesite naziv proizvoda.';
                                      } else if (value.length < 3) {
                                        return 'Naziv mora imati barem 3 slova.';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      formKey.currentState!.validate();
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Naziv proizvoda',
                                      prefixIcon: Icon(
                                        Icons.restaurant,
                                        size: 28,
                                      ),
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
                                      isDense: false,
                                      isCollapsed: false,
                                      contentPadding: EdgeInsets.all(15),
                                      errorStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: errorColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                            top: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Flexible(
                                      child: Text(
                                        "Količina",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: inputFillColor,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: TextFormField(
                                          controller: _defaultAmountController,
                                          textAlign: TextAlign.center,
                                          onEditingComplete: () {
                                            _parseAmount(null);
                                            FocusScope.of(context).unfocus();
                                          },
                                          onChanged: _parseAmount,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp("(^[0-9]{0,3}[.,]?[0-9]{0,2}\$)")),
                                          ],
                                          keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                                          validator: (value) {
                                            if (value == null || value.isEmpty || num.parse(value) == 0) {
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
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Flexible(
                                      child: Text(
                                        "Mjera",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: inputFillColor,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: DropdownButtonFormField(
                                            dropdownColor: Colors.white,
                                            iconEnabledColor: Colors.black,
                                            decoration: const InputDecoration(
                                              hintText: "odaberite mjeru",
                                              hintStyle: TextStyle(
                                                fontSize: 14,
                                              ),
                                              contentPadding: EdgeInsets.symmetric(
                                                horizontal: 20,
                                              ),
                                            ),
                                            items: List.generate(
                                              _measureTypeList.length,
                                              (index) => DropdownMenuItem<dynamic>(
                                                child: Text(
                                                  _measureTypeList[index]["name"].toString() + " (" + _measureTypeList[index]["abbreviation"].toString() + ")",
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                value: _measureTypeList[index],
                                              ),
                                            ),
                                            value: _measureType,
                                            onChanged: (dynamic newValue) {
                                              setState(() {
                                                _measureType = newValue;
                                              });
                                            }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black.withOpacity(0.25),
                                width: 2,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.4),
                              ),
                            ],
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  "Barkod (neobavezno)",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: inputFillColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: TextFormField(
                                    controller: _barcodeController,
                                    onEditingComplete: () {
                                      formKey.currentState!.validate();
                                      FocusScope.of(context).unfocus();
                                    },
                                    validator: (value) {
                                      if ((value != null && value.isNotEmpty && value.length != 13) || !_validBarcode()) {
                                        return 'Naispravan barkod.';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      formKey.currentState!.validate();
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'barkod',
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
                                      isDense: false,
                                      isCollapsed: false,
                                      contentPadding: EdgeInsets.all(15),
                                      errorStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: errorColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(offset: const Offset(0, 2), blurRadius: 4, color: Colors.black.withOpacity(0.4)),
                          ], color: Colors.white),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Text(
                                    "Nutritivne vrijednosti",
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: ListView(
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(
                                bottom: 200,
                              ),
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
                                      const Text(
                                        "Kalorije",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        ((_proteins * 4) + (_carbs * 4) + (_fats * 9)).round().toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...List.generate(
                                  macroList.length,
                                  (index) {
                                    dynamic macro = macroList[index];
                                    return Container(
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
                                              macro["title"] + " (g)",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: macro["color"] as Color,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                left: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                color: inputFillColor,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: TextFormField(
                                                controller: _controllerList[macro["controllerIndex"]],
                                                textAlign: TextAlign.center,
                                                onEditingComplete: () {
                                                  _parseAmountIndexed(macro["controllerIndex"]);
                                                  FocusScope.of(context).unfocus();
                                                },
                                                onChanged: (value) {
                                                  _parseAmountIndexed(macro["controllerIndex"]);
                                                },
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp("(^[0-9]{0,3}[.,]?[0-9]{0,2}\$)")),
                                                ],
                                                keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  isCollapsed: false,
                                                  contentPadding: EdgeInsets.all(5),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                ...List.generate(
                                  microList.length,
                                  (index) {
                                    dynamic micro = microList[index];
                                    return Container(
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
                                              micro["title"] + " (" + micro["measure"] + ")",
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                left: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                color: inputFillColor,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: TextFormField(
                                                controller: _controllerList[micro["controllerIndex"]],
                                                textAlign: TextAlign.center,
                                                onEditingComplete: () {
                                                  _parseAmountIndexed(micro["controllerIndex"]);
                                                  FocusScope.of(context).unfocus();
                                                },
                                                onChanged: (value) {
                                                  _parseAmountIndexed(micro["controllerIndex"]);
                                                },
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp("(^[0-9]{0,3}[.,]?[0-9]{0,2}\$)")),
                                                ],
                                                keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  isCollapsed: false,
                                                  contentPadding: EdgeInsets.all(5),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
