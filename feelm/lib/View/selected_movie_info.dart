import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:feelm/json/movie_json.dart';
import 'package:feelm/View/movie_Detail_Screen.dart';

class SelectedMovieInfo extends StatelessWidget {
  final MovieJson? selectedMovie;
  final List<MovieJson> movieList;

  const SelectedMovieInfo({
    super.key,
    required this.selectedMovie,
    required this.movieList,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedMovie == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Text(
          selectedMovie?.title ?? '영화제목',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Text(
          'time : ${selectedMovie?.runtime ?? 0}분',
          style: const TextStyle(color: Color.fromARGB(255, 139, 139, 139)),
        ),
        const SizedBox(height: 5),
        ElevatedButton(
          onPressed: () {
            if (selectedMovie != null) {
              log('영화 정보 보기: ${selectedMovie?.title}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(
                    movieName: selectedMovie!.title ?? '',
                    movieList: movieList,
                  ),
                ),
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
      ],
    );
  }
}
