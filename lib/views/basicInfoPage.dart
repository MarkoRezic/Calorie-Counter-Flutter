import 'package:calorie_counter/component_widgets/light_green_button.dart';
import 'package:calorie_counter/component_widgets/page_indicator_row.dart';
import 'package:calorie_counter/component_widgets/transparent_outlined_button.dart';
import 'package:calorie_counter/custom_colors.dart';
import 'package:calorie_counter/utils/bmr_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BasicInfoPage extends StatefulWidget {
  const BasicInfoPage({Key? key}) : super(key: key);

  @override
  _BasicInfoPageState createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  static const pageCount = 4;
  int selectedPage = 0;
  final PageController pageController = PageController();

  void _handleSelect(index) {
    if (selectedPage == index) return;
    setState(() {
      pageController.animateToPage(index,
          duration: const Duration(milliseconds: 400), curve: Curves.ease);
    });
  }

  void _handlePrevious() {
    if(selectedPage == 0) return Navigator.pop(context);
    setState(() {
      pageController.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.ease);
    });
  }

  void _handleNext() {
    if(selectedPage == pageCount - 1) return Navigator.pop(context);
    setState(() {
      pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {

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
                  itemCount: 4,
                  itemBuilder: (context, index) => Center(
                        child: Text(index.toString()),
                      )),
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
