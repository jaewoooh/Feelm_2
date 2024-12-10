import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feelm/View/recommendation_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:feelm/json/movie_json.dart';
import 'package:feelm/main.dart';

class PosterPageView extends StatefulWidget {
  final PageController pageController;
  final Function(MovieJson) onMovieSelected;

  const PosterPageView({
    super.key,
    required this.pageController,
    required this.onMovieSelected,
  });

  @override
  State<PosterPageView> createState() => _PosterPageViewState();
}

class _PosterPageViewState extends State<PosterPageView> {
  List<MovieJson> movieList = [];
  List<MovieJson> filteredMovies = [];
  final String? loginId = prefs.getString('username'); // 로그인된 사용자 ID

  @override
  void initState() {
    super.initState();
    _loadAndFilterMovies().then((_) {
      if (filteredMovies.isNotEmpty) {
        // 첫 번째 영화를 선택된 영화로 전달
        widget.onMovieSelected(filteredMovies[0]);
      }
    });
  }

  /// JSON 데이터를 로드하고 필터링
  Future<void> _loadAndFilterMovies() async {
    try {
      // JSON 데이터 로드
      final String response =
          await rootBundle.loadString('assets/json/movie_top500.json');
      final Map<String, dynamic> data = jsonDecode(response);
      final List<dynamic> moviesData = data['movieJson'];

      movieList = moviesData.map((json) => MovieJson.fromJson(json)).toList();

      //log("Loaded Movie List in PosterPageView: ${movieList.map((m) => m.title).toList()}");

      // 사용자 데이터 기반 필터링
      await _filterMovies();
    } catch (e) {
      log("Error loading movies in PosterPageView: $e");
    }
  }

  Future<void> _filterMovies() async {
    if (loginId == null) {
      log("Login ID not found.");
      setState(() {
        filteredMovies = movieList; // 모든 영화를 표시
      });
      return;
    }

    // Firebase에서 favorite에 있는 영화 타이틀 가져오기
    final Set<String> favoriteMovieTitles = await _fetchFavoriteMovies();

    final genreAndRuntime = await _calculateTopGenreAndAverageRuntime();

    if (genreAndRuntime.isEmpty) {
      log("No genre or runtime data found.");
      setState(() {
        filteredMovies = movieList.where((movie) {
          // favorite에 없는 영화만 필터링
          return !favoriteMovieTitles.contains(movie.title);
        }).toList();
      });
      return;
    }

    final String topGenre = genreAndRuntime["topGenre"];
    final double averageRuntime = genreAndRuntime["averageRuntime"];

    final movies = _filterMoviesByGenreAndRuntime(
      movieList,
      topGenre,
      averageRuntime,
    ).where((movie) {
      // favorite에 없는 영화만 필터링
      return !favoriteMovieTitles.contains(movie.title);
    }).toList();

    setState(() {
      filteredMovies = movies;
    });

    log("Top Genre: $topGenre");
    log("Average Runtime: $averageRuntime");
    //log("Filtered Movies: ${filteredMovies.map((m) => m.title).toList()}");
  }

  /// Firebase에서 favorite 영화 타이틀 가져오기
  Future<Set<String>> _fetchFavoriteMovies() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(loginId)
          .collection('favorite')
          .get();

      final Set<String> favoriteMovies = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['title'] as String)
          .toSet();

      log("Favorite Movies: $favoriteMovies");
      return favoriteMovies;
    } catch (e) {
      log("Error fetching favorite movies: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> _calculateTopGenreAndAverageRuntime() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(loginId)
          .collection('favorite')
          .where('diaryText', isNotEqualTo: "")
          .get();

      final List<QueryDocumentSnapshot> docs = snapshot.docs;

      if (docs.isEmpty) {
        log("No movies found with diaryText.");
        return {};
      }

      final Map<String, double> genreScores = {};
      double totalRuntime = 0;
      int movieCount = 0;

      for (final doc in docs) {
        final data = doc.data() as Map<String, dynamic>;

        final String genres = data['genre'] ?? "";
        final double rating = (data['rating'] ?? 0).toDouble();
        final int runtime = (data['runtime'] ?? 0);

        totalRuntime += runtime;
        movieCount++;

        for (final genre in genres.split(',')) {
          final trimmedGenre = genre.trim();
          final genreScore = GenreScores.scores[trimmedGenre] ?? 0;
          genreScores[trimmedGenre] =
              (genreScores[trimmedGenre] ?? 0) + (genreScore * rating);
        }
      }

      final topGenre =
          genreScores.entries.reduce((a, b) => a.value > b.value ? a : b);
      final double averageRuntime = totalRuntime / movieCount;

      return {
        "topGenre": topGenre.key,
        "averageRuntime": averageRuntime,
      };
    } catch (e) {
      log("Error calculating top genre and average runtime: $e");
      return {};
    }
  }

  List<MovieJson> _filterMoviesByGenreAndRuntime(
      List<MovieJson> movieList, String topGenre, double averageRuntime) {
    return movieList.where((movie) {
      final genres = movie.genre?.split(',') ?? [];
      final runtime = movie.runtime ?? 0;

      return genres.contains(topGenre) &&
          (runtime - averageRuntime).abs() <= 5; // 15분 이내 근사값
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return filteredMovies.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            height: 220,
            child: PageView.builder(
              controller: widget.pageController,
              itemCount: filteredMovies.length > 10
                  ? 10
                  : filteredMovies.length, // 최대 10개의 추천 영화
              onPageChanged: (index) {
                // 선택된 영화 변경
                widget.onMovieSelected(filteredMovies[index]);
              },
              itemBuilder: (context, index) {
                final movie = filteredMovies[index];
                return _buildPosterCard(movie);
              },
            ),
          );
  }

  Widget _buildPosterCard(MovieJson movie) {
    final posterUrl = movie.poster ?? '';

    return Center(
      child: Container(
        height: 220,
        width: 140,
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
  }
}
