import 'package:feelm/View/movie_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:feelm/json/movie_json.dart';

class SearchMovie extends StatefulWidget {
  final List<MovieJson> movieList; // MovieScreen에서 전달받은 전체 영화 리스트

  const SearchMovie({super.key, required this.movieList});

  @override
  State<SearchMovie> createState() => _SearchMovieState();
}

class _SearchMovieState extends State<SearchMovie> {
  final TextEditingController _controller = TextEditingController();
  List<MovieJson> filteredMovies = []; // 검색된 영화 리스트

  void _handleSearch() {
    final query = _controller.text.trim().toLowerCase(); // 검색어 소문자 변환
    setState(() {
      if (query.isEmpty) {
        filteredMovies = []; // 검색어가 없으면 빈 리스트
      } else {
        filteredMovies = widget.movieList.where((movie) {
          final title = movie.title?.toLowerCase() ?? '';
          final director = movie.director?.toLowerCase() ?? '';
          return title.contains(query) || director.contains(query);
        }).toList();
      }
    });
    _controller.clear(); // 검색어 입력란 초기화
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Movie'),
        backgroundColor: const Color.fromARGB(255, 91, 177, 234), // AppBar 색상
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20), // AppBar와 SearchBar 사이 간격
            // 검색바
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: _handleSearch, // 돋보기 클릭 시 검색
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search Your Movie or Director',
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _handleSearch(), // Enter 키로 검색
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            ),
            const SizedBox(height: 20), // SearchBar와 GridView 사이 간격
            // 검색 결과
            Expanded(
              child: filteredMovies.isEmpty
                  ? const Center(
                      child: Text(
                        'No movies to display',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 한 행에 3개의 포스터
                        crossAxisSpacing: 10, // 가로 간격
                        mainAxisSpacing: 10, // 세로 간격
                        childAspectRatio: 0.5, // 포스터 비율
                      ),
                      itemCount: filteredMovies.length,
                      itemBuilder: (context, index) {
                        final movie = filteredMovies[index];
                        return GestureDetector(
                          onTap: () {
                            // MovieDetailScreen으로 이동
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetailScreen(
                                  movieName: movie.title!,
                                  movieList: widget.movieList,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    movie.poster ?? '',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey,
                                        child: const Center(
                                          child: Icon(Icons.error,
                                              color: Colors.red),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                movie.title ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                movie.genre ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFE5ECF5), // 배경색 설정
    );
  }
}
