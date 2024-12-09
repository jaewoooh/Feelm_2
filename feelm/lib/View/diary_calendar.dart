//사용자가 선택한 날짜와 포스터 이미지를 기반으로 다이어리 작성 화면을 표시하며,
// 특정 조건에 따라 뒤로가기 동작 및 알림 창(다이얼로그)을 제공
import 'package:feelm/View/calendar_screen.dart';
import 'package:feelm/View/note_screen.dart';
import 'package:flutter/material.dart';

class DiaryCalendar extends StatelessWidget {
  final String selectedDate;
  final String posterImageUrl; // 전달받은 포스터 이미지 URL

  const DiaryCalendar({
    super.key,
    required this.selectedDate,
    required this.posterImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBAD3EE),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  title: const Text(
                    "확인을 누르시면 저장하지 않은 입력들은 초기화됩니다.\n뒤로 가시겠습니까?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // 다이얼로그 닫기
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            CalendarscreenState
                                .selectedPosterTitleNotifier.value = null;
                            Navigator.of(context).pop(true); // 다이얼로그 닫기
                            Navigator.of(context).pop(); // 이전 화면으로 이동
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 180, 168, 113),
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            '네',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Diary"),
        backgroundColor: const Color(0xFFBAD3EE),
        elevation: 0,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Colors.black,
              height: 1.0,
            )),
      ),
      body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/diaryCloud.png',
                    width: 300,
                    height: 150,
                  ),
                  NoteScreen(
                    selectedDate: selectedDate,
                    posterImageUrl: posterImageUrl, // 전달받은 포스터 이미지 전달
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
