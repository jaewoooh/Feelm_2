import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelm/main.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MyTableCalendar extends StatefulWidget {
  final DateTime focusedDay;
  final Function(DateTime, DateTime, String?) onDaySelected;

  const MyTableCalendar({
    super.key,
    required this.focusedDay,
    required this.onDaySelected,
  });

  @override
  State<MyTableCalendar> createState() => _MyTableCalendarState();
}

class _MyTableCalendarState extends State<MyTableCalendar> {
  DateTime? _selectedDay;
  Map<DateTime, String> _savedPosters = {}; // 날짜별 포스터 저장
  final String? loginId = prefs.getString('username'); //로그인된 아이디 가져오기

  @override
  void initState() {
    super.initState();
    _listenToFirebaseUpdates(); // Firebase 업데이트를 실시간으로 수신
  }

  // Firebase 실시간 업데이트 리스너
  void _listenToFirebaseUpdates() {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(loginId) // 유저 ID
        .collection('favorite');

    userDoc.snapshots().listen((snapshot) {
      Map<DateTime, String> tempPosters = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('savedDate') &&
            data.containsKey('diaryText') &&
            (data['diaryText'] as String).isNotEmpty &&
            data.containsKey('poster')) {
          // 날짜를 year, month, day만 남기고 변환
          final savedDate = DateTime.parse(data['savedDate']);
          final normalizedDate =
              DateTime(savedDate.year, savedDate.month, savedDate.day);
          tempPosters[normalizedDate] = data['poster']; // 포스터 URL 저장
        }
      }

      setState(() {
        _savedPosters = tempPosters; // 업데이트된 데이터를 반영
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime(2024, 1, 1),
        lastDay: DateTime(2034, 12, 31),
        focusedDay: widget.focusedDay,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, _) {
            final normalizedDay = DateTime(day.year, day.month, day.day);
            if (_savedPosters.containsKey(normalizedDay)) {
              final posterUrl = _savedPosters[normalizedDay]!;
              return Positioned(
                bottom: 5, // 날짜 아래 위치
                //left: 15,
                child: Container(
                  width: 40, // 날짜 아래 표시할 포스터 크기
                  height: 60,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(posterUrl),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.rectangle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
        rowHeight: 100,
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            border: Border.fromBorderSide(
              BorderSide(
                color: Colors.green,
                width: 2,
              ), // 초록색 직사각형 테두리
            ),

            shape: BoxShape.circle, // 직사각형 모양
          ),
          selectedTextStyle: TextStyle(
            color: Colors.black, // 선택된 날짜의 숫자를 검정색으로 설정
          ),
          markersAlignment: Alignment.bottomCenter,
          cellMargin: EdgeInsets.only(bottom: 50, right: 25),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
          });
          // 클릭한 날짜의 포스터 URL 전달
          final normalizedDay =
              DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
          final String? posterForSelectedDay = _savedPosters[normalizedDay];

          // onDaySelected 호출 시 posterForSelectedDay 전달
          widget.onDaySelected(selectedDay, focusedDay, posterForSelectedDay);
        },
      ),
    );
  }
}
