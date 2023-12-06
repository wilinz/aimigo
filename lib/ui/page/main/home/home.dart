
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:aimigo/ui/page/main/home/home_controller.dart';
import 'package:aimigo/ui/route.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _HomePage();
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage({Key? key}) : super(key: key);

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage>
    with AutomaticKeepAliveClientMixin {
  final c = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('首页'),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: Text('settings'.tr),
                value: 'settings',
              ),
            ],
            onSelected: (value) {
              if (value == 'settings') {
                // 导航到设置页面
                Get.toNamed(AppRoute.settingsPage);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 150,
            child: CarouselSlider(
              options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: false,
                  aspectRatio: 16 / 6,
                  autoPlayCurve: Curves.linear,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  viewportFraction: 1.0,
                  clipBehavior: Clip.antiAlias),
              items: c.images.map((image) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          image,
                          fit: BoxFit.fill,
                          width: double.infinity,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 6),
          Expanded(child: MyStaggeredGridView())
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 当FAB被点击时执行的操作
          Get.toNamed(AppRoute.postPage);
        },
        child: Icon(Icons.add), // FAB上的图标
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<HomeController>();
  }

  @override
  bool get wantKeepAlive => true;
}

class MyStaggeredGridView extends StatelessWidget {
  final List<Map<String, dynamic>> items = [
    {
      'image': 'assets/images/girl1.png',
      'title': 'prompt 分享',
    },
    {
      'image': 'assets/images/girl2.png',
      'title': '泰裤辣，快看看我的 prompt',
    },
    {
      'image': 'assets/images/girl3.png',
      'title': '神奇的Ai',
    },
    {
      'image': 'assets/images/girl4.png',
      'title': '泰裤辣',
    },
    {
      'image': 'assets/images/girl5.png',
      'title': '没有标题',
    },
    {
      'image': 'assets/images/girl6.png',
      'title': '没有标题',
    },
    {
      'image': 'assets/images/girl7.png',
      'title': '6',
    },
    {
      'image': 'assets/images/girl8.png',
      'title': 'Aimigo',
    },
    {
      'image': 'assets/images/girl9.png',
      'title': 'jk女孩',
    },
    {
      'image': 'assets/images/girl10.png',
      'title': 'Cool',
    },
    {
      'image': 'assets/images/girl11.png',
      'title': 'Stable Diffusion',
    },
    // ... more items
  ];

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      padding: EdgeInsets.all(8),
      crossAxisCount: 2,
      // 每行显示的列数
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = items[index];
        return Container(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Get.toNamed(AppRoute.imageDetailsPage, arguments: item);
            },
            child: Column(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(item['image'])),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(item['title']),
                ),
              ],
            ),
          ),
        );
      },
      mainAxisSpacing: 8.0,
      // 主轴间距
      crossAxisSpacing: 8.0, // 横轴间距
    );
  }
}
