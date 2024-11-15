import 'package:flutter/material.dart';

import 'package:table_calendar/table_calendar.dart';

// 수정해야할거 calendar내에서 상하 스크롤이 안됨

class MyTableCalendar extends StatefulWidget {
  final DateTime focusedDay;
  final Function(DateTime, DateTime) onDaySelected;

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
        rowHeight: 60,
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
          ),
          cellMargin: EdgeInsets.all(8),
          // selectedDecoration: BoxDecoration(
          //   color: Colors.transparent,
          //   shape: BoxShape.rectangle,
          //   borderRadius: BorderRadius.circular(12),
          // ),
          // todayTextStyle: TextStyle(
          //   color: Colors.white,
          //   fontWeight: FontWeight.bold,
          // ),
          markersAlignment: Alignment.bottomCenter,
          markersOffset: PositionedOffset(),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          headerPadding: EdgeInsets.symmetric(vertical: 0.0),
        ),
        sixWeekMonthsEnforced: true,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            //_selectedDay = selectedDay;
          });
          widget.onDaySelected(selectedDay, focusedDay);
        },
      ),
    );
  }
}
