import 'package:flutter/material.dart';
import 'video_model.dart';
import 'video_card.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController();
  List<YoutubeVideo> _videos = [];
  bool _loading = false;

  void _search() async {
    setState(() => _loading = true);
    final results = await YoutubeService.searchVideos(_controller.text);
    setState(() { _videos = results; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Şarkıcı/Şarkı adına göre ara', suffixIcon: Icon(Icons.search)),
          onSubmitted: (_) => _search(),
        ),
      ),
      body: _loading 
          ? const Center(child: CircularProgressIndicator()) 
          : ListView.builder(
              itemCount: _videos.length,
              itemBuilder: (context, index) => VideoCard(video: _videos[index]),
            ),
    );
  }
}
