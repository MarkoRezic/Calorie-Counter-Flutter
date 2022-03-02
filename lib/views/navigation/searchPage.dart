import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/utils/debouncer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'createPage.dart';
import 'entryPage.dart';

class SearchPage extends StatefulWidget {
  final dynamic mealType;

  const SearchPage({Key? key, required this.mealType}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();

  static bool validBarcodeTest(String barcode) {
    if (!RegExp(r'^[0-9]{13}$').hasMatch(barcode)) return false;
    int oddSum = 0;
    int evenSum = 0;
    for (int i = 0; i < 12; i++) {
      if ((i + 1) % 2 == 1) {
        oddSum += int.parse(barcode[i]);
      } else {
        evenSum += int.parse(barcode[i]);
      }
    }
    evenSum *= 3;
    int checkDigit = (oddSum + evenSum) % 10;
    checkDigit = checkDigit == 0 ? 0 : (10 - checkDigit);
    return checkDigit.toString() == barcode[12];
  }
}

class _SearchPageState extends State<SearchPage> {
  bool _loading = false;
  bool _loadingBarcode = false;
  TextEditingController searchController = TextEditingController();
  dynamic productList = [];
  final _debouncer = Debouncer(milliseconds: 500);
  List<dynamic> _productHistory = [];

  @override
  void initState() {
    super.initState();
    _getHistory();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _getHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("searchHistory") == null) return;
    String searchHistory = prefs.getString("searchHistory")!;
    print(searchHistory);
    Dio dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL'),
      ),
    );
    dio.get("products/history/" + searchHistory).then((response) {
      //print(response);
      if (mounted) {
        setState(() {
          _productHistory = response.data;
        });
      }
    });
  }

  void _searchProducts() {
    if (!mounted || searchController.text.length < 3) return;
    setState(() {
      _loading = true;
    });
    Dio dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL'),
      ),
    );
    dio.get("products?search=" + searchController.text).then((response) {
      //print(response);
      if (mounted) {
        setState(() {
          productList = response.data;
          _loading = false;
        });
      }
    });
  }

  bool _isProductInHistory(product) {
    for (int i = 0; i < _productHistory.length; i++) {
      if (_productHistory[i]["product_id"] == product["product_id"]) {
        return true;
      }
    }
    return false;
  }

  void _popAddCallback(value, product) {
    if (value != null) {
      if (value["error"] == 0) {
        SharedPreferences.getInstance().then((prefs) {
          if (_isProductInHistory(product)) {
            _productHistory.remove(_productHistory.firstWhere((p) => p["product_id"] == product["product_id"]));
            _productHistory.insert(0, product);
          } else {
            if (_productHistory.length >= 30) _productHistory.removeLast();
            _productHistory.insert(0, product);
          }
          prefs.setString("searchHistory", _productHistory.map((p) => p["product_id"].toString()).toList().join(","));
        });
      }
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
    }
  }

  void _popCreateCallback(value) {
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
    }
  }

  bool _validBarcode(String barcode) {
    if (!RegExp(r'^[0-9]{13}$').hasMatch(barcode)) return false;
    int oddSum = 0;
    int evenSum = 0;
    for (int i = 0; i < 12; i++) {
      if ((i + 1) % 2 == 1) {
        oddSum += int.parse(barcode[i]);
      } else {
        evenSum += int.parse(barcode[i]);
      }
    }
    evenSum *= 3;
    int checkDigit = (oddSum + evenSum) % 10;
    checkDigit = checkDigit == 0 ? 0 : (10 - checkDigit);
    return checkDigit.toString() == barcode[12];
  }

  void _scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff0000", "Nazad", true, ScanMode.BARCODE);
    print("RESULT:" + barcodeScanRes);
    if (_validBarcode(barcodeScanRes)) {
      if (!mounted) return;
      setState(() {
        _loadingBarcode = true;
      });
      Dio dio = Dio(
        BaseOptions(
          baseUrl: dotenv.get('API_BASE_URL'),
        ),
      );
      dio.get("products?barcode=" + barcodeScanRes).then((response) {
        //print(response);
        if (!mounted) return;
        setState(() {
          if (response.data.length > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => EntryPage(
                  mealType: widget.mealType,
                  product: response.data[0],
                ),
              ),
            ).then((value) => _popAddCallback(value, response.data[0]));
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => CreatePage(
                  scannedBarcode: barcodeScanRes,
                ),
              ),
            ).then((value) => _popCreateCallback(value));
          }
          _loadingBarcode = false;
        });
      });
    } else if (barcodeScanRes == "-1") {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text(
            "Skeniranje otkazano.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: errorColor.withOpacity(0.8),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text(
            "Neispravan barkod.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: errorColor.withOpacity(0.8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(widget.mealType["name"].toString()),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => CreatePage(),
                  ),
                ).then((value) => _popCreateCallback(value));
              },
              icon: const FaIcon(FontAwesomeIcons.plus)),
          IconButton(onPressed: _scanBarcode, icon: const FaIcon(FontAwesomeIcons.barcode)),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: inputFillColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextFormField(
                            controller: searchController,
                            onChanged: (String val) {
                              if (val.length < 3) {
                                setState(() {
                                  productList = [];
                                });
                                return;
                              }
                              _debouncer.run(() {
                                _searchProducts();
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              prefixIcon: Icon(
                                Icons.search,
                                size: 28,
                              ),
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
                searchController.text.length < 3
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: ListView(
                            shrinkWrap: true,
                            children: List.generate(_productHistory.length, (indexProduct) {
                              dynamic product = _productHistory[indexProduct];
                              return Material(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) => EntryPage(
                                          mealType: widget.mealType,
                                          product: product,
                                        ),
                                      ),
                                    ).then((value) => _popAddCallback(value, product));
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
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(Icons.history),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product["name"],
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  product["default_amount"].toString() + product["measure_abbreviation"].toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(
                                          product["serving_calories"].toString(),
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
                          ),
                        ),
                      )
                    : _loading
                        ? const Expanded(
                            child: Center(child: RepaintBoundary(child: CircularProgressIndicator())),
                          )
                        : Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: ListView(
                                shrinkWrap: true,
                                children: List.generate((productList ?? []).length, (indexProduct) {
                                  dynamic product = productList[indexProduct];
                                  return Material(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) => EntryPage(
                                              mealType: widget.mealType,
                                              product: product,
                                            ),
                                          ),
                                        ).then((value) => _popAddCallback(value, product));
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
                                                  product["name"],
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  product["default_amount"].toString() + product["measure_abbreviation"].toString(),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              product["serving_calories"].toString(),
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
                              ),
                            ),
                          ),
              ],
            ),
            _loadingBarcode
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
