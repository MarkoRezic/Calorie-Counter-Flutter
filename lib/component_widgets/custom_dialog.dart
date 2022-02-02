import 'package:calorie_counter/component_widgets/transparent_outlined_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../custom_colors.dart';

class CustomDialog extends StatefulWidget {
  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool showPassword = false;
  String error = "";
  bool showError = false;
  bool loading = false;

  void login() async {
    setState(() {
      loading = true;
    });
    Dio dio = Dio();
    dio.post(
      "http://10.0.2.2:3000/users/login",
      data: {
        "username": usernameController.text,
        "password": passwordController.text,
      },
    ).then((response) {
      print(response);
      if (response.data["error"] == 0) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          loading = false;
          showError = true;
          error = response.data["message"];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: mainColorFaded,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "korisničko ime",
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: mainColorDark.withOpacity(0.5),
                ),
                hintText: "username",
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: passwordController,
              obscureText: !showPassword,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                      showPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                ),
                labelText: "šifra",
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: mainColorDark.withOpacity(0.5),
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            loading
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: CircularProgressIndicator(),
                  )
                : TransparentOutlinedButton(
                    hasShadow: false,
                    textColor: mainColorDark,
                    text: "PRIJAVA",
                    onTap: () {
                      login();
                    },
                  ),
            showError
                ? Text(
                    error,
                    style: TextStyle(color: errorColor),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
