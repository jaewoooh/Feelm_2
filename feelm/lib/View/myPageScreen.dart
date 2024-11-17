// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'movieScreen.dart'; 
import 'calendarScreen.dart';


class Mypagescreen extends StatefulWidget {
  const Mypagescreen({super.key});

  @override
  _MypagescreenState createState() => _MypagescreenState();
}

class _MypagescreenState extends State<Mypagescreen> {
  String movieImage = 'assets/movie.png';
  String calendarImage = 'assets/calendar.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9ACBFF),

     // 하단
      body: Container(
        color: const Color(0xFFE5ECF5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0), // 흰색 박스 시작 위치에 맞춤
                  child: Image.asset(
                    'assets/myprofile.png',
                    width: 138, // 일단 이 넓이
                    height: 41, 
                  ),
                ),
              ),
              const SizedBox(height: 20), 

              // 프로필
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/userprofile.png'), // 일단 피그마 이미지, 나중에는 사용자 설정 이미지를 가져올 수 있도록 하기...
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [ // 여기도 나중에는 사용자 정보를 가져와야함
                        Text(
                          '냠냠냠',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text('yummy@gmail.com'),
                      ],
                    ),
                  ],
                ),
              ),
              // 하단 : 즐겨찾기
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '즐겨 찾기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF615F7B), 
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 2,
                    width: 80, 
                    color: Color(0xFF615F7B), 
                  ),
                ],
              ),// 이미지를 넣으니 너무 깨져서 글씨로 적었습니다
              /*
              Image.asset(
                'assets/Favorites.png',
                width: 200, 
                height: 41, 
              ),
              */
              const SizedBox(height: 10),
              // 즐겨찾기 영화 목록, 나중에 DB에서 정보를 가져와야함
              Expanded(
                child: ListView(
                  children: [
                    _buildFavoriteMovieCard(
                      'Spiderman',
                      'assets/spiderman.png',
                      9.5,
                      'Action',
                      2019,
                      139,
                    ),
                    _buildFavoriteMovieCard(
                      'Spider-Man: No Way Home',
                      'assets/spiderman_no_way_home.png',
                      8.5,
                      'Action',
                      2021,
                      139,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// 나중에 영화카드 생성할 때 사용해야함, 여기에 영화 정보 합칠 예정, 이미지가 없을 경우 기본 이미지 출력하도록 함
 Widget _buildFavoriteMovieCard(String title, String imagePath, double rating, String genre, int year, int minutes) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 80,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/posterEx.png', // 일단 기본이미지
                  width: 80,
                  height: 100,
                  fit: BoxFit.cover,
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(rating.toString()),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(genre),
                  const SizedBox(height: 4),
                  Text('$year'),
                  const SizedBox(height: 4),
                  Text('$minutes minutes'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}