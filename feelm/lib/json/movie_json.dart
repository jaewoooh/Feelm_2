class MovieJson {
  String? id; // 필요없음
  String? title;
  String? genre;
  int? runtime;
  String? rating; //별점이아니라 몇세이용가
  String? plot; // description이라 생각하면됨
  int? gender; // 0 1 2인데 뭐임?
  String? director; //감독
  String? poster;
  String? nation;
  int? year;

  MovieJson({
    this.id,
    this.title,
    this.genre,
    this.runtime,
    this.rating,
    this.plot,
    this.gender,
    this.director,
    this.poster,
    this.nation,
    this.year,
  });

  factory MovieJson.fromJson(Map<String, dynamic> json) => MovieJson(
        id: json['id']?.toString(), // id를 문자열로 변환
        title:
            json['title'] is String ? json['title'] : json['title']?.toString(),
        genre:
            json['genre'] is String ? json['genre'] : json['genre']?.toString(),
        runtime: json['runtime'] is String
            ? int.tryParse(json['runtime'])
            : json['runtime'],
        rating: json['rating'] is String
            ? json['rating']
            : json['rating']?.toString(),
        plot: json['plot'] is String ? json['plot'] : json['plot']?.toString(),
        gender: json['gender'] is String
            ? int.tryParse(json['gender'])
            : json['gender'],
        director: json['director'] is String
            ? json['director']
            : json['director']?.toString(),
        poster: json['poster'] is String
            ? json['poster']
            : json['poster']?.toString(),
        nation: json['nation'] is String
            ? json['nation']
            : json['nation']?.toString(),
        year:
            json['year'] is String ? int.tryParse(json['year']) : json['year'],
      );
}
