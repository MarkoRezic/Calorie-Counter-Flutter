import 'package:calorie_counter/utils/cache_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ListView(
        shrinkWrap: true,
        children: [
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
          ),
        ],
      ),
    );
  }
}
