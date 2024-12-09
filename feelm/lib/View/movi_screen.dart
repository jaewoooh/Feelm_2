import 'dart:convert';
import 'dart:developer';

import 'package:feelm/View/movie_poster_view.dart';
import 'package:feelm/View/search_movie.dart';
import 'package:feelm/View/selected_movie_info.dart';
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
  MovieJson? selectedMovie; // 현재 선택된 영화 정보

  @override
  void initState() {
    super.initState();
    _loadMovies();

    // // PageController의 리스너 추가
    // _pageController.addListener(() {
    //   final int newPageIndex = _pageController.page?.round() ?? 0;
    //   if (newPageIndex != _currentPageIndex) {
    //     setState(() {
    //       _currentPageIndex = newPageIndex;
    //     });
    //   }
    // });
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
        if (movieList.isNotEmpty) {
          selectedMovie = movieList[0]; // 처음에는 첫 번째 영화를 선택
        }
        log("Movie List: ${movieList.map((m) => m.title).toList()}");
      });
    } catch (e) {
      log("Error loading JSON: $e");
    }
  }

  // @override
  // void dispose() {
  //   _pageController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    if (movieList.isEmpty) {
      // 영화 리스트가 비어 있으면 로딩 스피너 표시
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFBAD3EE),
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
                PosterPageView(
                  pageController: _pageController,
                  //movieList: movieList,
                  onMovieSelected: (movie) {
                    setState(() {
                      selectedMovie = movie;
                    });
                  },
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
          SelectedMovieInfo(
            selectedMovie: selectedMovie,
            movieList: movieList,
          ),

          const SizedBox(height: 10),
          _buildTopTrendingSection()
        ],
      ),
    );
  }

  // Top Trending
  Widget _buildTopTrendingSection() {
    // movieList를 year 기준으로 내림차순 정렬
    final sortedMovies = List<MovieJson>.from(movieList)
      ..sort((a, b) => (b.year ?? 0).compareTo(a.year ?? 0));

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
            itemCount: sortedMovies.length > 15 ? 15 : sortedMovies.length,
            itemBuilder: (context, index) {
              final movie = sortedMovies[index];
              return _buildTrendingMovieCard(movie); // movie 객체 전달
            },
          ),
        ),
      ],
    );
  }

// 영화 카드 위젯
  Widget _buildTrendingMovieCard(MovieJson movie) {
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
              child: movie.poster != null && movie.poster!.isNotEmpty
                  ? Image.network(
                      movie.poster!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, color: Colors.red);
                      },
                    )
                  : Image.asset(
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
              movie.title ?? 'Unknown Title',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
            ),
          ),

          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
