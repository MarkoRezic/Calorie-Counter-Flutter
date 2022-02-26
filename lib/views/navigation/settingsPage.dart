import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      "title": "Kilaža",
      "icon": Icon(Icons.monitor_weight),
    },
    {
      "key": "goal_weight",
      "title": "Ciljana kilaža",
      "icon": Icon(Icons.monitor_weight_outlined),
    },
    {
      "key": "height",
      "title": "Visina",
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
            onTap: () {},
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
                    onTap: () {},
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
