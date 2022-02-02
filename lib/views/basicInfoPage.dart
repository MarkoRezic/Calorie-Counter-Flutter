import 'package:calorie_counter/component_widgets/light_green_button.dart';
import 'package:calorie_counter/component_widgets/page_indicator_row.dart';
import 'package:calorie_counter/component_widgets/transparent_outlined_button.dart';
import 'package:calorie_counter/custom_colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BasicInfoPage extends StatefulWidget {
  final int goal_type;
  const BasicInfoPage({Key? key, required this.goal_type}) : super(key: key);

  @override
  _BasicInfoPageState createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  static const pageCount = 4;
  int selectedPage = 0;
  final PageController pageController = PageController();
  List<Widget> pageList = [];
  List<dynamic> weeklyGoalsList = [];
  List<String> weeklyGoalsDescriptions = [];
  int selectedWeeklyGoalIndex = 0;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repasswordController = TextEditingController();
  bool showPassword = false;
  bool showRepassword = false;
  bool loading = false;
  String error = "";
  bool showError = false;

  @override
  void initState() {
    super.initState();
    _getWeeklyGoals();
  }

  void _getWeeklyGoals() async {
    Dio dio = Dio();
    dio
        .get("http://10.0.2.2:3000/attributes/weekly_goals/" +
            widget.goal_type.toString())
        .then((response) {
      setState(() {
        weeklyGoalsList = widget.goal_type == 1
            ? response.data.reversed.toList()
            : response.data;
        weeklyGoalsDescriptions =
            weeklyGoalsList.map<String>((wg) => wg["description"]).toList();
      });
    });
  }

  Future<bool> _isUsernameTaken() async {
    setState(() {
      loading = true;
    });
    Dio dio = Dio();
    await dio.post(
      "http://10.0.2.2:3000/users/check",
      data: {
        "username": usernameController.text,
      },
    ).then((response) {
      print(response);
      setState(() {
        if (response.data["error"] == 0) {
          setState(() {
            showError = false;
            error = "";
          });
        } else {
          setState(() {
            showError = true;
            error = response.data["message"];
          });
        }
        loading = false;
      });
    });
    return !showError;
  }

  void _handleSelect(index) {
    if (selectedPage == index) return;
    setState(() {
      pageController.animateToPage(index,
          duration: const Duration(milliseconds: 400), curve: Curves.ease);
    });
  }

  void _handlePrevious() {
    if (selectedPage == 0) return Navigator.pop(context);
    setState(() {
      pageController.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.ease);
    });
  }

  void _handleNext() async {
    if (selectedPage == pageCount - 1) return Navigator.pop(context);
    if (selectedPage == 0) {
      if (!(await _isUsernameTaken())) {
        return;
      }
    }
    setState(() {
      pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    pageList = [
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: usernameController,
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  labelText: "korisničko ime",
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.6),
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
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  suffixIcon: IconButton(
                    color: Colors.white.withOpacity(0.6),
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
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: repasswordController,
                obscureText: !showRepassword,
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  suffixIcon: IconButton(
                    color: Colors.white.withOpacity(0.6),
                    icon: Icon(showRepassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        showRepassword = !showRepassword;
                      });
                    },
                  ),
                  labelText: "ponovite šifru",
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              widget.goal_type != 2
                  ? (weeklyGoalsDescriptions.length != 0
                      ? DropdownButtonFormField(
                          dropdownColor: mainColorFill,
                          iconEnabledColor: Colors.white,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.15),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            labelText: "odaberite brzinu napretka",
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          items: List.generate(
                            weeklyGoalsDescriptions.length,
                            (index) => DropdownMenuItem<String>(
                              child: Text(
                                weeklyGoalsDescriptions[index],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              value: weeklyGoalsDescriptions[index],
                            ),
                          ),
                          value:
                              weeklyGoalsDescriptions[selectedWeeklyGoalIndex],
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedWeeklyGoalIndex = weeklyGoalsDescriptions
                                  .indexOf(newValue ?? "");
                            });
                          })
                      : CircularProgressIndicator())
                  : Container(),
            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: mainColorDark,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 40,
                    ),
                    child: Text(
                      'Unesite Vaše informacije kako bi izračunali Vaš dnevni kalorijski cilj',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      selectedPage = page;
                    });
                  },
                  itemCount: pageCount,
                  itemBuilder: (context, index) => pageList[index]),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TransparentOutlinedButton.small(
                    text: 'Nazad',
                    onTap: _handlePrevious,
                    width: 85,
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: IndicatorRow(
                      onSelect: _handleSelect,
                      length: 4,
                      activeIndex: selectedPage,
                    ),
                  ),
                  LightGreenButton.small(
                    text: 'Dalje',
                    onTap: _handleNext,
                    width: 85,
                    height: 40,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
