import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_video/return_code.dart';
import 'dart:io';

void main() => runApp(const MaterialApp(home: YouTubeIndirici()));

class YouTubeIndirici extends StatefulWidget {
  const YouTubeIndirici({super.key});
  @override
  _YouTubeIndiriciState createState() => _YouTubeIndiriciState();
}

class _YouTubeIndiriciState extends State<YouTubeIndirici> {
  final TextEditingController _controller = TextEditingController();
  bool _isProcessing = false;
  String _status = "YouTube Linkini Girin";

  Future<void> processVideo(String targetFormat) async {
    setState(() { _isProcessing = true; _status = "Video indiriliyor..."; });

    try {
      final yt = YoutubeExplode();
      var video = await yt.videos.get(_controller.text);
      var manifest = await yt.videos.streamsClient.getManifest(video.id);
      var streamInfo = manifest.muxed.withHighestBitrate();

      // Dosya yollarını hazırla
      final dir = await getExternalStorageDirectory();
      final String tempPath = "${dir!.path}/temp_video.mp4";
      final String outputPath = "${dir.path}/${video.title.replaceAll(' ', '_')}.$targetFormat";

      // 1. İndirme Aşaması
      await Dio().download(streamInfo.url.toString(), tempPath);

      // 2. Çevirme Aşaması (Uygulama içi FFmpeg)
      setState(() => _status = "$targetFormat formatına çevriliyor...");
      
      String ffmpegCommand = "";
      if (targetFormat == "mp3") {
        ffmpegCommand = "-i \"$tempPath\" -vn -ab 192k \"$outputPath\"";
      } else if (targetFormat == "avi") {
        ffmpegCommand = "-i \"$tempPath\" -c:v mpeg4 -c:a mp3 \"$outputPath\"";
      }

      if (targetFormat != "mp4") {
        await FFmpegKit.execute(ffmpegCommand).then((session) async {
          final returnCode = await session.getReturnCode();
          if (ReturnCode.isSuccess(returnCode)) {
            setState(() => _status = "Başarıyla çevrildi!");
            File(tempPath).deleteSync(); // Geçici dosyayı sil
          } else {
            setState(() => _status = "Çevirme hatası oluştu.");
          }
        });
      } else {
        File(tempPath).renameSync(outputPath);
        setState(() => _status = "MP4 Başarıyla kaydedildi!");
      }
      yt.close();
    } catch (e) {
      setState(() => _status = "Hata: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("YT Converter Pro"), backgroundColor: Colors.red),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _controller, decoration: const InputDecoration(labelText: "YouTube URL")),
            const SizedBox(height: 20),
            Text(_status, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (_isProcessing) const CircularProgressIndicator()
            else Wrap(
              spacing: 10,
              children: [
                ElevatedButton(onPressed: () => processVideo("mp4"), child: const Text("MP4")),
                ElevatedButton(onPressed: () => processVideo("mp3"), child: const Text("MP3")),
                ElevatedButton(onPressed: () => processVideo("avi"), child: const Text("AVI")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
