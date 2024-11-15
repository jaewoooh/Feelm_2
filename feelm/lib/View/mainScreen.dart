// ignore_for_file: file_names

import 'package:feelm/View/calendarScreen.dart';
//import 'package:feelm/View/MovieScreen.dart';
//import 'package:feelm/View/MyPageScreen.dart';

import 'package:flutter/material.dart';

// 로그인 후 메인페이지 (캘린더 창이 나오게할거임) and 네비게이션 바 구현
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // 탭 변경 시 UI 업데이트
    });
  }

  @override
  void dispose() {
    //사용이끝난 TabController 해제
    _tabController.dispose();
    super.dispose();
  }

  List<Widget> screens = [
    const Calendarscreen(),
    //const Moviescreen(),
    //const Mypagescreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // TabController가 초기화되었는지 확인
    if (!mounted) {
      return const SizedBox(); // 초기화 전 빈 위젯 반환, 이 코드 사용해야 네비게이션 바 잘 적용됨
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0), // 높이를 조정
          child: AppBar(
            backgroundColor: const Color(0xFFDCD1B5),
            elevation: 0, // 그림자 제거
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      icon: Image.asset(
                        _tabController.index == 0
                            ? 'assets/calendarTouch.png'
                            : 'assets/calendar.png',
                      ),
                    ),
                    Tab(
                        icon: Image.asset(
                      _tabController.index == 1
                          ? 'assets/movieTouch.png'
                          : 'assets/movie.png',
                    )),
                    Tab(
                        icon: Image.asset(
                      _tabController.index == 2
                          ? 'assets/myPage.png'
                          : 'assets/myPage.png',
                    )),
                  ],
                  indicatorColor: Colors.black,
                ),
                const Divider(
                  color: Colors.black,
                  height: 1,
                  thickness: 1,
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController, // TabController 설정
          children: screens,
        ),
      ),
    );
  }
}
