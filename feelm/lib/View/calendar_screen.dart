// CalendarScreen

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelm/View/calendar_poster.dart';
import 'package:feelm/View/diary_calendar.dart';
import 'package:feelm/View/my_table_calendar.dart';
import 'package:feelm/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Calendarscreen extends StatefulWidget {
  const Calendarscreen({super.key});

  @override
  State<Calendarscreen> createState() => CalendarscreenState();
}

class CalendarscreenState extends State<Calendarscreen> {
  DateTime _focusedDay = DateTime.now();
  final String? loginId = prefs.getString('username'); //로그인된 아이디 가져오기
  static final ValueNotifier<String?> selectedPosterTitleNotifier =
      ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
  }

  void _onDaySelected(
      DateTime selectedDay, DateTime focusedDay, String? posterUrl) {
    setState(() {
      _focusedDay = focusedDay;
    });

    if (posterUrl != null) {
      // 클릭한 날짜에 해당하는 포스터가 존재하면 바로 DiaryCalendar로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiaryCalendar(
            selectedDate: selectedDay.toIso8601String(),
            posterImageUrl: posterUrl,
          ),
        ),
      );
    } else {
      // 기존 동작: 포스터 선택 후 이동
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              "${DateFormat('MM월 dd일').format(selectedDay)}로 이동하시겠습니까?",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 180, 168, 113),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final String? selectedPosterTitle =
                          selectedPosterTitleNotifier.value;
                      if (selectedPosterTitle == null) {
                        // 포스터가 선택되지 않았을 경우 경고 표시
                        Navigator.of(context).pop(); // 기존 다이얼로그 닫기
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                              "포스터를 먼저 선택해주세요.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            actionsAlignment: MainAxisAlignment.center,
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // 경고 다이얼로그 닫기
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: const StadiumBorder(),
                                ),
                                child: const Text(
                                  "확인",
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // 포스터가 선택된 경우 처리
                        _handleSelectedPoster(selectedDay, selectedPosterTitle);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 180, 168, 113),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      '네',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }
  }

  void _navigateToDiaryCalendar(
      DateTime selectedDay, String selectedPosterImage) {
    //if (!mounted) return; // 위젯이 비활성화된 경우 중단
    Navigator.of(context).pop(); // 기존 다이얼로그 닫기
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryCalendar(
          selectedDate: selectedDay.toIso8601String(),
          posterImageUrl: selectedPosterImage, // 포스터 URL 전달
        ),
      ),
    );
  }

  void _handleSelectedPoster(DateTime selectedDay, String selectedPosterTitle) {
    String selectedPosterImage = '';
    FirebaseFirestore.instance
        .collection('users')
        .doc(loginId)
        .collection('favorite')
        .where('title', isEqualTo: selectedPosterTitle)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        selectedPosterImage = snapshot.docs.first['poster'] ?? '';
      }
    }).whenComplete(() {
      _navigateToDiaryCalendar(
          selectedDay, selectedPosterImage); // 안전한 Navigator 호출
      log("${DateFormat('MM월 dd일').format(selectedDay)}로 이동");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBAD3EE), //0xFFBAD3EE ,0xFFDCD1B5
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // 수평 정렬
          children: [
            const SizedBox(height: 10),
            // 구름 이미지
            Image.asset(
              'assets/recordCloud.png',
              width: 300,
              height: 150,
            ),
            const SizedBox(height: 20),
            // 상단 메시지
            const Text(
              'Record Your Feelm!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Click the Date!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            // 캘린더 추가
            MyTableCalendar(
              focusedDay: _focusedDay,
              onDaySelected: _onDaySelected,
            ),
            const SizedBox(height: 20),
            const Divider(
              color: Colors.black,
              thickness: 1,
              indent: 30,
              endIndent: 30,
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text(
                  "click your poster",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 포스터 리스트 추가
            PosterListView(
              currentUser: loginId!,
              onPosterSelected: (title) {
                selectedPosterTitleNotifier.value = title;
              },
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
