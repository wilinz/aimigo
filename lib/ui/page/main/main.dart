import 'package:flutter/material.dart';
import 'package:aimigo/ui/page/ai_painting/sd_model/sd_model_page.dart';
import 'package:aimigo/ui/page/chat/chat.dart';
import 'package:get/get.dart';

import 'home/home.dart';
import 'profile/profile.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _MainPage();
  }
}

class _MainPage extends StatefulWidget {
  const _MainPage({Key? key}) : super(key: key);

  @override
  State<_MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<_MainPage> {
  int selected = 0;
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
          body: PageView(
            physics: NeverScrollableScrollPhysics(),
            children: [HomePage(),/* SDModelPage(),*/ ChatPage(), ProfilePage()],
            onPageChanged: (index) {
              setState(() {
                selected = index;
              });
            },
            controller: pageController,
          ),
          bottomNavigationBar: NavigationBar(
              destinations: [
                NavigationDestination(
                  tooltip: 'home_page'.tr,
                  icon: Icon(Icons.home_outlined),
                  label: 'home_page'.tr,
                  selectedIcon: Icon(Icons.home),
                ),
                // NavigationDestination(
                //   tooltip: 'Ai绘图',
                //   icon: Icon(Icons.brush_outlined),
                //   label: 'Ai绘图',
                //   selectedIcon: Icon(Icons.brush),
                // ),
                NavigationDestination(
                  tooltip: 'Ai聊天',
                  icon: Icon(Icons.chat_outlined),
                  label: 'Ai聊天',
                  selectedIcon: Icon(Icons.chat),
                ),
                NavigationDestination(
                  tooltip: 'my'.tr,
                  icon: Icon(Icons.person_outlined),
                  label: 'my'.tr,
                  selectedIcon: Icon(Icons.person),
                )
              ],
              onDestinationSelected: (index) {
                // pageController.animateToPage(index,
                //     duration: Duration(milliseconds: 200), curve: Curves.linear);
                pageController.jumpToPage(index);
              },
              selectedIndex: selected)),
    );
  }
}
