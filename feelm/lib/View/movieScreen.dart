// ignore_for_file: file_names

//import 'dart:math';

import 'package:flutter/material.dart';

class Moviescreen extends StatefulWidget {
  const Moviescreen({super.key});

  @override
  State<Moviescreen> createState() => _MoviescreenState();
}

class _MoviescreenState extends State<Moviescreen> {
  final PageController _pageController = PageController(viewportFraction: 0.5);

  // @override
  // void initState() {
  //   super.initState();
  //   // 강제로 초기 페이지를 설정하여 포스터 크기 애니메이션 적용
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _pageController.jumpToPage(0);
  //   });
  // }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCD1B5),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 15,
                  ),
                  const Icon(Icons.search, color: Colors.white),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: 'Search Your Movie or Director',
                          hintStyle: TextStyle(color: Colors.white),
                          border: InputBorder.none),
                      onSubmitted: (value) {
                        //enter 누르면
                        if (value.isNotEmpty) {
                          print("검색어: $value");
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            color: Colors.grey[850],
            child: Column(
              children: [
                Image.asset(
                  'assets/upPoster.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: 5, //현재는 다섯개의 포스터만 나오도록해놨음

                    itemBuilder: (context, index) {
                      return _buildPosterCard(index);
                    },
                  ),
                ),
                Image.asset(
                  'assets/downPoster.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          // 중앙 포스터의 제목과 런닝 타임을 표시
          const Text(
            '영화제목',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '런닝타임',
            style: TextStyle(color: Color.fromARGB(255, 139, 139, 139)),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              print('Feelm recorded for');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(221, 19, 18, 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 10),
              child: Text(
                'Record My Feelm',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 포스터 카드 위젯 함수
  Widget _buildPosterCard(int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = (_pageController.page! - index).abs();
          value = (1 - (value * 0.3)).clamp(0.7, 1.0);
        }
        return Center(
          child: Container(
            height: Curves.easeOut.transform(value) * 220,
            width: Curves.easeOut.transform(value) * 140,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'assets/posterEx.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
