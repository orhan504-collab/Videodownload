import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: YouTubeIndirici(),
  ));
}

class YouTubeIndirici extends StatefulWidget {
  const YouTubeIndirici({super.key});

  @override
  _YouTubeIndiriciState createState() => _YouTubeIndiriciState();
}

class _YouTubeIndiriciState extends State<YouTubeIndirici> {
  final TextEditingController _controller = TextEditingController();
  bool _isProcessing = false;
  String _status = "YouTube Video Linkini Yapıştırın";
  double _progress = 0;

  Future<void> processVideo(String targetFormat) async {
    // 1. İzin Kontrolü
    var status = await Permission.storage.request();
    if (status.isDenied) {
      setState(() => _status = "Hata: Depolama izni gerekli!");
      return;
    }

    setState(() {
      _isProcessing = true;
      _status = "Video bilgileri alınıyor...";
      _progress = 0;
    });

    final yt = YoutubeExplode();
    try {
      // 2. Video Bilgilerini Çek
      var video = await yt.videos.get(_controller.text);
      var manifest = await yt.videos.streamsClient.getManifest(video.id);
      
      // En yüksek kaliteli birleşik (muxed) stream'i seç
      var streamInfo = manifest.muxed.withHighestBitrate();

      // 3. Dosya Yollarını Hazırla
      final directory = await getExternalStorageDirectory();
      final String tempPath = "${directory!.path}/temp_video.mp4";
      final String cleanTitle = video.title.replaceAll(RegExp(r'[^\w\s]+'), '_');
      final String outputPath = "${directory.path}/$cleanTitle.$targetFormat";

      // 4. İndirme Aşaması
      setState(() => _status = "İndiriliyor: ${video.title}");
      await Dio().download(
        streamInfo.url.toString(),
        tempPath,
        onReceiveProgress: (count, total) {
          setState(() {
            _progress = count / total;
          });
        },
      );

      // 5. Dönüştürme Aşaması (FFmpeg)
      if (targetFormat != "mp4") {
        setState(() => _status = "$targetFormat formatına dönüştürülüyor...");
        
        String ffmpegCommand = "";
        if (targetFormat == "mp3") {
          // Videoyu at, sadece sesi 192kbps olarak al
          ffmpegCommand = "-i \"$tempPath\" -vn -ab 192k \"$outputPath\"";
        } else if (targetFormat == "avi") {
          // Video ve sesi AVI konteynerine paketle
          ffmpegCommand = "-i \"$tempPath\" -c:v mpeg4 -c:a mp3 \"$outputPath\"";
        }

        await FFmpegKit.execute(ffmpegCommand).then((session) async {
          final returnCode = await session.getReturnCode();
          if (ReturnCode.isSuccess(returnCode)) {
            setState(() => _status = "Başarıyla kaydedildi: $cleanTitle.$targetFormat");
            if (File(tempPath).existsSync()) File(tempPath).deleteSync();
          } else {
            setState(() => _status = "Dönüştürme hatası oluştu!");
          }
        });
      } else {
        // Zaten MP4 ise sadece ismini düzelt
        File(tempPath).renameSync(outputPath);
        setState(() => _status = "MP4 Başarıyla kaydedildi!");
      }

    } catch (e) {
      setState(() => _status = "Hata: Link geçersiz veya video bulunamadı.");
    } finally {
      yt.close();
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("YouTube Pro Downloader"),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.video_library, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "YouTube URL",
                hintText: "https://www.youtube.com/watch?v=...",
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            if (_isProcessing) ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 10),
              Text("%${(_progress * 100).toStringAsFixed(0)}"),
            ] else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => processVideo("mp4"),
                    icon: const Icon(Icons.movie),
                    label: const Text("MP4"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => processVideo("mp3"),
                    icon: const Icon(Icons.audiotrack),
                    label: const Text("MP3"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => processVideo("avi"),
                    icon: const Icon(Icons.settings_input_component),
                    label: const Text("AVI"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
