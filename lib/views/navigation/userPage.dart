import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserPage extends StatefulWidget {
  dynamic user;
  UserPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _loading = false;
  final dynamic _user = CacheManager.getData("user");

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _promoteUser() {
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
        "users/promote",
        data: {
          "user_id": widget.user["user_id"],
          "role_id": widget.user["role_id"] == 1 ? 2 : 1,
        },
      ).then((response) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              "Ažuriran korisnik " + widget.user["username"],
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: mainColor.withOpacity(0.8),
          ),
        );
        setState(() {
          widget.user["role_id"] = widget.user["role_id"] == 1 ? 2 : 1;
          widget.user["role"] = widget.user["role_id"] == 1 ? "User" : "Moderator";
          _loading = false;
        });
      });
    } on Exception catch (_) {
      debugPrint(_.toString());
      return Navigator.pop(context, {
        "error": 1,
        "message": "Došlo je do greške. Molimo pokušajte ponovo.",
      });
    }
  }

  void _blockUser() {
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
        "users/block",
        data: {
          "user_id": widget.user["user_id"],
          "blocked": widget.user["blocked"] == 0 ? 1 : 0,
        },
      ).then((response) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              widget.user["blocked"] == 0 ? "Korisnik blokiran." : "Korisnik odblokiran.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: widget.user["blocked"] == 0 ? errorColor.withOpacity(0.8) : mainColor.withOpacity(0.8),
          ),
        );
        setState(() {
          widget.user["blocked"] = widget.user["blocked"] == 0 ? 1 : 0;
          _loading = false;
        });
      });
    } on Exception catch (_) {
      debugPrint(_.toString());
      return Navigator.pop(context, {
        "error": 1,
        "message": "Došlo je do greške. Molimo pokušajte ponovo.",
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Ažuriraj Korisnika"),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        centerTitle: false,
        actions: _user["user_id"] != widget.user["user_id"]
            ? (widget.user["role_id"] != 3
                ? [
                    IconButton(
                        onPressed: () {
                          _blockUser();
                        },
                        icon: FaIcon(widget.user["blocked"] == 0 ? FontAwesomeIcons.ban : FontAwesomeIcons.checkCircle)),
                    IconButton(
                      onPressed: () {
                        _promoteUser();
                      },
                      icon: FaIcon(widget.user["role_id"] == 2 ? FontAwesomeIcons.userMinus : FontAwesomeIcons.userPlus),
                    ),
                  ]
                : [
                    const IconButton(
                      onPressed: null,
                      icon: FaIcon(FontAwesomeIcons.userShield),
                    ),
                  ])
            : [],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(
                    10,
                  ),
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(offset: const Offset(0, 2), blurRadius: 4, color: Colors.black.withOpacity(0.4)),
                  ], color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Icon(
                                widget.user["role_id"] == 1
                                    ? Icons.person
                                    : widget.user["role_id"] == 2
                                        ? Icons.manage_accounts
                                        : Icons.admin_panel_settings,
                                size: 36,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.user["username"].toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  widget.user["role"].toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Icon(
                                Icons.tag,
                                size: 32,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  widget.user["user_id"].toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  "ID",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
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
                Container(
                  padding: EdgeInsets.all(
                    10,
                  ),
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(offset: const Offset(0, 2), blurRadius: 4, color: Colors.black.withOpacity(0.4)),
                  ], color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 15,
                              ),
                              child: Icon(
                                Icons.access_time,
                                size: 32,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Godine",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          widget.user["age"].toString(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(
                    10,
                  ),
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(offset: const Offset(0, 2), blurRadius: 4, color: Colors.black.withOpacity(0.4)),
                  ], color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 15,
                              ),
                              child: Icon(
                                widget.user["gender_id"] == 1
                                    ? Icons.male
                                    : widget.user["gender_id"] == 2
                                        ? Icons.female
                                        : Icons.transgender,
                                size: 32,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Spol",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          widget.user["gender"].toString(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
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
