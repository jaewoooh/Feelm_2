import 'dart:developer';

import 'package:feelm/View/calendar_poster.dart';
import 'package:feelm/View/diary_calendar.dart';
import 'package:feelm/View/my_table_calendar.dart';
import 'package:feelm/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Calendarscreen extends StatefulWidget {
  const Calendarscreen({super.key});

  @override
  State<Calendarscreen> createState() => _CalendarscreenState();
}

class _CalendarscreenState extends State<Calendarscreen> {
  DateTime _focusedDay = DateTime.now();
  final String? loginId = prefs.getString('username'); //로그인된 아이디 가져오기

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });

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
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiaryCalendar(
                          selectedDate:
                              DateFormat('yyyy년 MM월 dd일').format(selectedDay),
                        ),
                      ),
                    );
                    log("${DateFormat('MM월 dd일').format(selectedDay)}로 이동");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCD1B5),
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
            PosterListView(currentUser: loginId!),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
