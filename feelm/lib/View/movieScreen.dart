import 'dart:convert';
import 'dart:developer';

import 'package:feelm/View/movie_Detail_Screen.dart';
import 'package:feelm/View/search_movie.dart';
import 'package:feelm/json/movie_json.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Moviescreen extends StatefulWidget {
  const Moviescreen({super.key});

  @override
  State<Moviescreen> createState() => _MoviescreenState();
}

class _MoviescreenState extends State<Moviescreen> {
  final PageController _pageController = PageController(viewportFraction: 0.5);
  List<MovieJson> movieList = [];
  int _currentPageIndex = 0; // 현재 선택된 페이지의 인덱스

  @override
  void initState() {
    super.initState();
    _loadMovies();

    // PageController의 리스너 추가
    _pageController.addListener(() {
      final int newPageIndex = _pageController.page?.round() ?? 0;
      if (newPageIndex != _currentPageIndex) {
        setState(() {
          _currentPageIndex = newPageIndex;
        });
      }
    });
  }

  /// JSON 파일을 로드하고 파싱하는 함수
  Future<void> _loadMovies() async {
    try {
      // assets 폴더에 저장된 JSON 파일을 읽어옴
      final String response =
          await rootBundle.loadString('assets/json/movie_top500.json');
      final Map<String, dynamic> data = jsonDecode(response);

      // movieJson 키를 사용하여 검색
      final List<dynamic> moviesData = data['movieJson'];

      setState(() {
        movieList = moviesData.map((json) => MovieJson.fromJson(json)).toList();
      });
    } catch (e) {
      log("Error loading JSON: $e");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMovie =
        movieList.isNotEmpty ? movieList[_currentPageIndex] : null;
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SearchMovie(movieList: movieList),
                          ),
                        );
                      },
                      onSubmitted: (value) {
                        //enter 누르면
                        if (value.isNotEmpty) {
                          log("검색어: $value");
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
                    itemCount: movieList.length > 10 ? 10 : movieList.length,
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
          if (selectedMovie != null) ...[
            Text(
              selectedMovie.title ?? '영화제목',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              'time : ${selectedMovie.runtime}분',
              style: const TextStyle(color: Color.fromARGB(255, 139, 139, 139)),
            ),
            const SizedBox(height: 5),
          ],

          ElevatedButton(
            onPressed: () {
              if (selectedMovie != null) {
                final selectedMovie = movieList[_currentPageIndex];
                log('영화정보보기');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MovieDetailScreen(
                            movieName: selectedMovie.title ?? '',
                            movieList: movieList,
                          )),
                );
              }
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
                '영화 정보 보기',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildTopTrendingSection()
        ],
      ),
    );
  }

  // Top Trending
  Widget _buildTopTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 16.0), // 포스터와 동일한 위치에 맞추기 위해 왼쪽 여백 설정
          child: Image.asset(
            'assets/topTrend.png',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // 예시로 10개의 아이템만 표시
            itemBuilder: (context, index) {
              return _buildTrendingMovieCard(index);
            },
          ),
        ),
      ],
    );
  }

// 영화 카드 위젯
  Widget _buildTrendingMovieCard(int index) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(left: 16, right: 8),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.asset(
                'assets/posterEx.png',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          //const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Movie Title $index',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          // const Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 8.0),
          //   child: Row(
          //     children: [
          //       Icon(Icons.star, color: Colors.yellow, size: 14),
          //       SizedBox(width: 4),
          //       Text('4.5',
          //           style: TextStyle(
          //             fontSize: 12,
          //             color: Colors.white,
          //           )),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  // 포스터 카드 위젯 함수
  Widget _buildPosterCard(int index) {
    if (index >= movieList.length) return const SizedBox.shrink();

    final movie = movieList[index];
    final posterUrl = movie.poster ?? '';

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
              child: posterUrl.isNotEmpty
                  ? Image.network(
                      posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        log("Failed to load image: $posterUrl");
                        return const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      },
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
