import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_https/ffmpeg_kit.dart';
import 'dart:io';

void main() => runApp(const MaterialApp(home: YouTubeIndirici()));

class YouTubeIndirici extends StatefulWidget {
  const YouTubeIndirici({super.key});

  @override
  _YouTubeIndiriciState createState() => _YouTubeIndiriciState();
}

class _YouTubeIndiriciState extends State<YouTubeIndirici> {
  final TextEditingController _controller = TextEditingController();
  bool _yukleniyor = false;
  String _durum = "Video linkini yapıştırın veya aratın";

  Future<void> islemiBaslat(String format) async {
    setState(() { _yukleniyor = true; _durum = "Video bilgileri alınıyor..."; });

    final yt = YoutubeExplode();
    try {
      // 1. Video Bilgilerini Al
      var video = await yt.videos.get(_controller.text);
      var manifest = await yt.videos.streamsClient.getManifest(video.id);
      var streamInfo = manifest.muxed.withHighestBitrate();

      // 2. Kayıt Yerini Belirle
      Directory? dir = await getExternalStorageDirectory();
      String hamDosyaYolu = "${dir!.path}/video_temp.mp4";
      String hedefDosyaYolu = "${dir.path}/${video.title.replaceAll(RegExp(r'[^\w\s]+'), '')}.$format";

      // 3. İndir
      setState(() => _durum = "İndiriliyor: ${video.title}");
      await Dio().download(streamInfo.url.toString(), hamDosyaYolu);

      // 4. Dönüştür (FFmpeg Kullanarak)
      setState(() => _durum = "Format $format yapılıyor...");
      
      if (format == "mp3") {
        await FFmpegKit.execute("-i \"$hamDosyaYolu\" -vn -ab 192k \"$hedefDosyaYolu\"");
      } else if (format == "avi") {
        await FFmpegKit.execute("-i \"$hamDosyaYolu\" -c:v copy -c:a copy \"$hedefDosyaYolu\"");
      } else {
        // MP4 ise sadece ismini düzeltiyoruz
        File(hamDosyaYolu).renameSync(hedefDosyaYolu);
      }

      // Geçici dosyayı temizle
      if (format != "mp4" && File(hamDosyaYolu).existsSync()) File(hamDosyaYolu).deleteSync();

      setState(() => _durum = "Başarıyla kaydedildi: $format");
    } catch (e) {
      setState(() => _durum = "Hata oluştu: $e");
    } finally {
      yt.close();
      setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("YouTube Video & MP3 Converter")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _controller, decoration: const InputDecoration(labelText: "YouTube Linki")),
            const SizedBox(height: 20),
            Text(_durum, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (_yukleniyor) const CircularProgressIndicator()
            else Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => islemiBaslat("mp4"), child: const Text("MP4 İndir")),
                ElevatedButton(onPressed: () => islemiBaslat("mp3"), child: const Text("MP3 Yap")),
                ElevatedButton(onPressed: () => islemiBaslat("avi"), child: const Text("AVI Yap")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
