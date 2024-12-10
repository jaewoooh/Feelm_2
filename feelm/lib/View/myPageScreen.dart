// MyPage

// ignore_for_file: file_names

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mypagescreen extends StatefulWidget {
  const Mypagescreen({super.key});

  @override
  MypagescreenState createState() => MypagescreenState();
}

class MypagescreenState extends State<Mypagescreen> {
  String? userName; // 로그인한 사용자의 이름
  String? userEmail; // 로그인한 사용자의 이메일
  List<Map<String, dynamic>> favorites = []; // 즐겨찾기 데이터를 저장 리스트

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Firestore에서 사용자 데이터 가져오기
    _fetchFavoriteMovies(); // Firestore에서 즐겨찾기 데이터 가져오기
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
        log('Firestore 데이터 가져오기 실패: $e');
      }
    }
  }

  Future<void> _fetchFavoriteMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? loginId = prefs.getString('username'); // 로그인 ID 가져오기

      if (loginId == null) {
        log("로그인 ID를 찾을 수 없습니다.");
        return;
      }

      // Firestore에서 'favorite' 컬렉션의 다이어리 작성된 즐겨찾기 항목 가져오기
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(loginId)
          .collection('favorite')
          .orderBy('savedDate', descending: true) // 날짜 기준 정렬
          .get();

      setState(() {
        favorites = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            ...data,
            'savedDate': data['savedDate'] ?? "알 수 없음", // savedDate를 그대로 사용
          };
        }).toList();
      });
    } catch (e) {
      log("즐겨찾기 데이터를 가져오는 중 오류 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9ACBFF),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 영역
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
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        AssetImage('assets/userprofile2.png'), //상원님 이미지로 교체
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName ?? '사용자 이름',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(userEmail ?? '사용자 이메일'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 즐겨찾기 섹션
            const Text(
              '즐겨 찾기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // 즐겨찾기 리스트
            Expanded(
              child: favorites.isEmpty
                  ? const Center(
                      child: Text('즐겨찾기한 영화가 없습니다.'),
                    )
                  : ListView.builder(
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final movie = favorites[index];
                        return _buildFavoriteMovieCard(
                          title: movie['title'] ?? '제목 없음',
                          imagePath: movie['poster'] ?? 'assets/posterEx.png',
                          rating: movie['rating'] ?? 0.0,
                          genre: movie['genre'] ?? '장르 없음',
                          runtime: movie['runtime'] ?? 0,
                          createdAt: movie['savedDate'],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteMovieCard({
    required String title,
    required String imagePath,
    required double rating,
    required String genre,
    required int runtime,
    required String createdAt,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.network(
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
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("저장된 날짜: $createdAt"),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(rating.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("장르: $genre"),
                  const SizedBox(height: 4),
                  Text("런타임: $runtime 분"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
