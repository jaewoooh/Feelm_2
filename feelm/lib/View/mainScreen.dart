// ignore_for_file: file_names

import 'package:feelm/View/calendarScreen.dart';
import 'package:feelm/View/movieScreen.dart';
import 'package:feelm/View/myPageScreen.dart';
import 'package:flutter/material.dart';

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
  _tabController = TabController(
    length: 3, 
    vsync: this, 
    initialIndex: 1, // 두 번째 탭(캘린더)로 설정
  );
  _tabController.addListener(() {
    setState(() {}); // 탭 변경 시 UI 업데이트
  });
}

  @override
  void dispose() {
    // 사용이 끝난 TabController 해제
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TabController가 초기화되었는지 확인
    if (!mounted) {
      return const SizedBox(); // 초기화 전 빈 위젯 반환
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(50.0), // 앱바 높이 조정
          child: AppBar(
            backgroundColor: const Color(0xFFDCD1B5), // 배경색 설정
            elevation: 0, // 그림자 제거
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 탭바 설정
                TabBar(
                  controller: _tabController,
                  tabs: [
                    // 첫 번째 탭: 영화
                    Tab(
                      icon: Image.asset(
                        _tabController.index == 0
                            ? 'assets/movieTouch.png'
                            : 'assets/movie.png',
                      ),
                    ),
                    // 두 번째 탭: 캘린더
                    Tab(
                      icon: Image.asset(
                        _tabController.index == 1
                            ? 'assets/calendarTouch.png'
                            : 'assets/calendar.png',
                      ),
                    ),
                    // 세 번째 탭: 마이페이지
                    Tab(
                      icon: Image.asset(
                        _tabController.index == 2
                            ? 'assets/myPageTouch.png'
                            : 'assets/myPage.png',
                      ),
                    ),
                  ],
                  indicatorColor: Colors.black, // 선택된 탭의 색상
                ),
                // 탭바 아래 구분선
                const Divider(
                  color: Colors.black,
                  height: 1,
                  thickness: 1,
                ),
              ],
            ),
          ),
        ),
        // 탭바 뷰 설정
        body: TabBarView(
          controller: _tabController,
          children: [
            const Moviescreen(), // 영화 화면
            const Calendarscreen(), // 캘린더 화면
            const Mypagescreen(), // 마이페이지 화면
          ],
        ),
      ),
    );
  }
}
