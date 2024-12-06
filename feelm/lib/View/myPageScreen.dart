
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'movieScreen.dart';
import 'calendarScreen.dart';

class Mypagescreen extends StatefulWidget {
  const Mypagescreen({super.key});

  @override
  _MypagescreenState createState() => _MypagescreenState();
}

class _MypagescreenState extends State<Mypagescreen> {
  String? userName; // 로그인한 사용자의 이름
  String? userEmail; // 로그인한 사용자의 이메일

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Firestore에서 사용자 데이터 가져오기
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? loginId = prefs.getString('username'); // 로그인한 사용자 ID 가져오기

    if (loginId != null) {
      try {
        // Firestore에서 사용자 데이터 가져오기
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(loginId)
            .get();

        if (doc.exists) {
          setState(() {
            userName = doc['username']; // Firestore에서 가져온 username
            userEmail = doc['email']; // Firestore에서 가져온 email
          });
        }
      } catch (e) {
        print('Firestore 데이터 가져오기 실패: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9ACBFF),
      
      // 하단
      body: Container(
        color: const Color(0xFFE5ECF5),
        child: Padding(

                ),
              ),
              const SizedBox(height: 20),
              // 프로필 UI (FireStore 데이터 반영)
              // 프로필 UI
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(

                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName ?? '냠냠냠', // Firestore에서 가져온 데이터 또는 기본값
                          userName ?? '냠냠냠', // Firestore에서 가져온 데이터 / 기본값 설정
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userEmail ?? 'yummy@gmail.com', // Firestore에서 가져온 데이터 또는 기본값
                          userEmail ?? 'yummy@gmail.com', // Firestore에서 가져온 데이터/ 기본값 설정
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
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
                    color: const Color(0xFF615F7B),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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

  Widget _buildFavoriteMovieCard(String title, String imagePath, double rating,
      String genre, int year, int minutes) {
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
                  'assets/posterEx.png',
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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