import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelm/View/calendar_screen.dart';
import 'package:feelm/View/mainScreen.dart';
import 'package:feelm/json/movie_json.dart';
import 'package:feelm/main.dart';

import 'package:flutter/material.dart';

class MovieDetailScreen extends StatefulWidget {
  final String movieName;
  final List<MovieJson> movieList;

  const MovieDetailScreen({
    super.key,
    required this.movieName,
    required this.movieList,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  MovieJson? selectedMovie;
  bool isExpanded = false; // 더보기 상태 관리 변수
  bool isFavorite = false; // 즐겨찾기 상태 관리 변수
  final String? loginId = prefs.getString('username'); //로그인된 아이디 가져오기

  @override
  void initState() {
    super.initState();
    _findMovieByTitle();
    _checkIfFavorite();
  }

  void _findMovieByTitle() {
    // movieList를 받아온 후 전달된 title을 기준으로 검색
    final movie = widget.movieList.firstWhere(
      (movie) => movie.title == widget.movieName,
      orElse: () => MovieJson(),
    );
    setState(() {
      selectedMovie = movie;
    });
  }

  Future<void> _checkIfFavorite() async {
    //FireStore에서 즐겨찾기 상태 확인
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(loginId)
        .collection('favorite')
        .doc(widget.movieName)
        .get();

    setState(() {
      isFavorite = doc.exists;
    });
  }

  Future<void> _toggleFavorite() async {
    final favoriteCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(loginId)
        .collection('favorite');

    if (isFavorite) {
      //즐겨찾기 해제
      await favoriteCollection.doc(widget.movieName).delete();
    } else {
      //즐겨찾기 추가
      await favoriteCollection.doc(widget.movieName).set({
        'title': selectedMovie!.title,
        'poster': selectedMovie!.poster,
        'genre': selectedMovie!.genre,
        'runtime': selectedMovie!.runtime
      });
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedMovie == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFF333333),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false, // 기본 뒤로 가기 버튼 비활성화
            backgroundColor: Colors.transparent,
            expandedHeight: 320, // 고정된 높이로 설정
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.network(
                        selectedMovie!.poster ?? '',
                        fit: BoxFit.fill, // 포스터가 비율에 맞게 표시되도록 수정
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error, color: Colors.red),
                          );
                        },
                      ),
                    ),
                  ),
                  // 사용자 정의 뒤로 가기 버튼
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Container(
                color: const Color(0xFF333333),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            selectedMovie!.title ?? '',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.star,
                              color: isFavorite ? Colors.amber : Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              _toggleFavorite();
                            },
                            splashRadius: 24,
                            iconSize: 28,
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      //장르
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: (selectedMovie!.genre ?? '')
                            .split(',')
                            .map((genre) => Chip(
                                  label: Text(genre.trim(),
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.grey[700],
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      // Year, Runtime, Nation을 묶어서 표시
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Year
                          Column(
                            children: [
                              const Text(
                                'Year',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                selectedMovie!.year?.toString() ?? 'N/A',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          // Runtime
                          Column(
                            children: [
                              const Text(
                                'Running Time',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${selectedMovie!.runtime ?? 'N/A'} Min',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          // Nation
                          Column(
                            children: [
                              const Text(
                                'Nation',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                selectedMovie!.nation ?? 'N/A',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description + 더보기 기능
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AnimatedCrossFade(
                        firstChild: Text(
                          selectedMovie!.plot ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        secondChild: Text(
                          selectedMovie!.plot ?? '',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: Text(
                            isExpanded ? '접기' : '더보기',
                            style: const TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            if (isFavorite) {
                              print("record my feelm");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MainScreen()));
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 120, vertical: 10),
                            backgroundColor: isFavorite
                                ? const Color(0xFF757575)
                                : Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5, //그림자 효과
                            shadowColor: Colors.black.withOpacity(0.2), //그림자 색상
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown, // 텍스트가 버튼 안에 맞도록 축소
                            child: Text(
                              isFavorite ? 'record my feelm' : '즐겨찾기를 추가해주세요',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
