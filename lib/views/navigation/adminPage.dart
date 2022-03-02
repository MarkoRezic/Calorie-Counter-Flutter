import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:calorie_counter/views/navigation/updatePage.dart';
import 'package:calorie_counter/views/navigation/userPage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  dynamic _user = CacheManager.getData("user");
  bool _loading = false;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _productList = [];
  List<dynamic> _searchedProducts = [];
  List<dynamic> _userList = [];
  List<dynamic> _searchedUsers = [];
  int _selectedPage = 0;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _getData() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
    });
    Dio dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get('API_BASE_URL'),
      ),
    );
    final responses = await Future.wait([dio.get("products"), dio.get("users")]);
    if (!mounted) return;
    setState(() {
      _productList = responses[0].data;
      _productList.sort((p1, p2) => p1["name"].compareTo(p2["name"]));
      _userList = responses[1].data;
      _userList.sort((u1, u2) => u1["username"].compareTo(u2["username"]));
      _loading = false;
    });
  }

  void _searchProducts() {
    if (!mounted || _searchController.text.isEmpty) {
      return setState(() {});
    }
    setState(() {
      _searchedProducts = _productList.where((p) => p["name"].toString().contains(_searchController.text)).toList();
      _searchedProducts.sort((p1, p2) => p1["name"].indexOf(_searchController.text) - p2["name"].indexOf(_searchController.text));
    });
  }

  void _searchUsers() {
    if (!mounted || _searchController.text.isEmpty) {
      return setState(() {});
    }
    setState(() {
      _searchedUsers = _userList.where((u) => u["username"].toString().contains(_searchController.text)).toList();
      _searchedUsers.sort((u1, u2) => u1["username"].indexOf(_searchController.text) - u2["username"].indexOf(_searchController.text));
    });
  }

  void _popProductCallback(value, product) {
    _getData();
    _searchProducts();
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

  void _popUserCallback(value, user) {
    _getData();
    _searchUsers();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Administracija"),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: false,
        actions: _user["role_id"] == 3
            ? [
                IconButton(
                    onPressed: () {
                      if (!mounted || _selectedPage == 0) return;
                      setState(() {
                        _selectedPage = 0;
                        _searchController.clear();
                      });
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.appleAlt,
                      size: 28,
                    )),
                IconButton(
                    onPressed: () {
                      if (!mounted || _selectedPage == 1) return;
                      setState(() {
                        _selectedPage = 1;
                        _searchController.clear();
                      });
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.userAlt,
                      size: 22,
                    )),
              ]
            : [],
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
                            controller: _searchController,
                            onChanged: (String val) {
                              if (_selectedPage == 0) {
                                _searchProducts();
                              } else {
                                _searchUsers();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Search' + (_selectedPage == 0 ? ' proizvodi' : ' korisnici'),
                              prefixIcon: const Icon(
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
                _selectedPage == 0
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: ListView(
                            shrinkWrap: true,
                            children: List.generate(_searchController.text.isEmpty ? _productList.length : _searchedProducts.length, (indexProduct) {
                              dynamic product = _searchController.text.isEmpty ? _productList[indexProduct] : _searchedProducts[indexProduct];
                              return Material(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) => UpdatePage(
                                          product: product,
                                        ),
                                      ),
                                    ).then((value) => _popProductCallback(value, product));
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
                                              padding: EdgeInsets.only(
                                                right: 15,
                                              ),
                                              child: Icon(
                                                Icons.fastfood,
                                                size: 32,
                                              ),
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
                    : Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: ListView(
                            shrinkWrap: true,
                            children: List.generate(_searchController.text.isEmpty ? _userList.length : _searchedUsers.length, (indexUser) {
                              dynamic user = _searchController.text.isEmpty ? _userList[indexUser] : _searchedUsers[indexUser];
                              return Material(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) => UserPage(
                                          user: user,
                                        ),
                                      ),
                                    ).then((value) => _popUserCallback(value, user));
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
                                              padding: EdgeInsets.only(
                                                right: 15,
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                size: 32,
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  user["username"],
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  user["role"].toString() + (user["blocked"] == 0 ? '' : ' (blocked)'),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              user["user_id"].toString(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              "ID",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
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
