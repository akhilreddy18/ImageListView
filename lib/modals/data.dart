class Data {
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  Data(
      {required this.id,
      required this.title,
      required this.url,
      required this.thumbnailUrl});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
        id: json['id'],
        title: json['title'],
        url: json['url'],
        thumbnailUrl: json['thumbnailUrl']);
  }
}
