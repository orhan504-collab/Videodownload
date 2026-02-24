import 'dart:convert';
import 'package:http/http.dart' as http;

class YoutubeVideo {
  final String id;
  final String title;
  final String thumbnailUrl;

  YoutubeVideo({required this.id, required this.title, required this.thumbnailUrl});

  factory YoutubeVideo.fromMap(Map<String, dynamic> map) {
    return YoutubeVideo(
      id: map['id']['videoId'] ?? '',
      title: map['snippet']['title'] ?? '',
      thumbnailUrl: map['snippet']['thumbnails']['high']['url'] ?? '',
    );
  }
}

class YoutubeService {
  static const String _apiKey = "AIzaSyCsB0wsaaRGIdvQxkEwOwVLofnHdWClY_k";

  static Future<List<YoutubeVideo>> searchVideos(String query) async {
    if (query.isEmpty) return [];
    final url = Uri.parse(
        "https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&key=$_apiKey&maxResults=15");

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['items'] as List).map((i) => YoutubeVideo.fromMap(i)).toList();
    }
    return [];
  }
}
