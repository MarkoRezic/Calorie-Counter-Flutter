import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/utils/debouncer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'entryPage.dart';

class SearchPage extends StatefulWidget {
  dynamic mealType;

  SearchPage({required this.mealType});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _loading = false;
  TextEditingController searchController = TextEditingController();
  dynamic productList = [];
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _searchProducts() {
    if (!mounted || searchController.text.length < 3) return;
    setState(() {
      _loading = true;
    });
    Dio dio = Dio();
    dio
        .get("http://10.0.2.2:3000/products?search=" + searchController.text)
        .then((response) {
      //print(response);
      if (mounted) {
        setState(() {
          productList = response.data;
        });
      }
    });
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(widget.mealType["name"].toString()),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: FaIcon(FontAwesomeIcons.plus)),
          IconButton(onPressed: () {}, icon: FaIcon(FontAwesomeIcons.barcode)),
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
                    child: Container(
                      margin: EdgeInsets.all(20),
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
                        decoration: InputDecoration(
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
            _loading
                ? Expanded(
                    child: Center(
                        child: RepaintBoundary(
                            child: CircularProgressIndicator())),
                  )
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: ListView(
                        shrinkWrap: true,
                        children: List.generate((productList ?? []).length,
                            (indexProduct) {
                          dynamic product = productList[indexProduct];
                          return Material(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        EntryPage(
                                      mealType: widget.mealType,
                                      product: product,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product["name"],
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          product["default_amount"].toString() +
                                              product["measure_abbreviation"]
                                                  .toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      product["serving_calories"].toString(),
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
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
