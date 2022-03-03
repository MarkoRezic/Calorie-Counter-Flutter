import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:calorie_counter/views/navigation/changeSettingsPage.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../custom_colors.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  dynamic user = CacheManager.getData("user");
  static const userAttributes = [
    {
      "key": "weekly_description",
      "title": "Moj cilj",
      "icon": Icon(Icons.flag),
    },
    {
      "key": "activity_description",
      "title": "Razina aktivnosti",
      "icon": Icon(Icons.speed),
    },
    {
      "key": "weight",
      "title": "Kilaža (kg)",
      "icon": Icon(Icons.monitor_weight),
    },
    {
      "key": "goal_weight",
      "title": "Ciljana kilaža (kg)",
      "icon": Icon(Icons.monitor_weight_outlined),
    },
    {
      "key": "height",
      "title": "Visina (cm)",
      "icon": Icon(Icons.height),
    },
    {
      "key": "gender",
      "title": "Spol",
      "icon": Icon(Icons.wc),
    },
    {
      "key": "age",
      "title": "Godine",
      "icon": Icon(Icons.history_toggle_off),
    },
  ];

  void _popChangeCallback(value) {
    if (value == null) return;
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
    if (value["error"] == 0) {
      Restart.restartApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text("Korisničko ime"),
            subtitle: Wrap(
              children: [
                Text(
                  user["username"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Icon(Icons.person),
            onTap: null,
            contentPadding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 10,
            ),
          ),
          const Divider(
            thickness: 2,
            height: 2,
          ),
          ...List.generate(
            userAttributes.length * 2,
            (index) => index % 2 == 0
                ? ListTile(
                    title: Text(userAttributes[index ~/ 2]["title"].toString()),
                    subtitle: Wrap(
                      children: [
                        Text(
                          user[userAttributes[index ~/ 2]["key"]].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: userAttributes[index ~/ 2]["icon"] as Icon,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => ChangeSettingsPage(),
                        ),
                      ).then((value) => _popChangeCallback(value));
                    },
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 10,
                    ),
                  )
                : const Divider(
                    thickness: 2,
                    height: 1,
                  ),
          ),
          ListTile(
            title: Text("Odjava"),
            subtitle: Text("Odjavite se iz sustava."),
            trailing: Icon(Icons.logout),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              CacheManager.clear();
              Navigator.pop(context);
            },
            contentPadding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 10,
            ),
          ),
        ],
      ),
    );
  }
}
