import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'video_model.dart';
import 'video_card.dart';

void main() {
  runApp(const MuzikIndiriciApp());
}

class MuzikIndiriciApp extends StatelessWidget {
  const MuzikIndiriciApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: const AnaSayfa(),
    );
  }
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  final TextEditingController _aramaController = TextEditingController();
  final List<VideoModel> _videolar = [];
  bool _yukleniyor = false;

  // YouTube'da arama yapan fonksiyon
  Future<void> _videoAra(String terim) async {
    if (terim.isEmpty) return;

    setState(() {
      _yukleniyor = true;
      _videolar.clear();
    });

    final yt = YoutubeExplode();
    try {
      // YouTube'da arama yap ve ilk 10 sonucu getir
      var aramaSonuclari = await yt.search.search(terim);
      
      for (var video in aramaSonuclari) {
        _videolar.add(VideoModel(
          id: video.id.value,
          title: video.title,
          thumbnail: video.thumbnails.mediumResUrl,
          duration: video.duration?.toString().split('.').first ?? "00:00",
          url: video.url,
        ));
      }
    } finally {
      yt.close();
      setState(() {
        _yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: _aramaController,
          decoration: const InputDecoration(
            hintText: "Şarkıcı/Şarkı adına göre ara",
            border: InputBorder.none,
            suffixIcon: Icon(Icons.search, color: Colors.grey),
          ),
          onSubmitted: (deger) => _videoAra(deger),
        ),
      ),
      body: _yukleniyor 
        ? const Center(child: CircularProgressIndicator()) // Arama yapılırken dönen simge
        : ListView.builder(
            itemCount: _videolar.length,
            itemBuilder: (context, index) {
              return VideoCard(video: _videolar[index]);
            },
          ),
    );
  }
}
