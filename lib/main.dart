import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() => runApp(const MaterialApp(home: TemizIndirici()));

class TemizIndirici extends StatefulWidget {
  const TemizIndirici({super.key});
  @override
  _TemizIndiriciState createState() => _TemizIndiriciState();
}

class _TemizIndiriciState extends State<TemizIndirici> {
  final TextEditingController _controller = TextEditingController();
  bool _yukleniyor = false;
  String _durum = "YouTube Linkini Yapıştırın";

  Future<void> indirMP4() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      setState(() => _durum = "Depolama izni gerekli!");
      return;
    }

    setState(() { _yukleniyor = true; _durum = "Video aranıyor..."; });

    final yt = YoutubeExplode();
    try {
      var video = await yt.videos.get(_controller.text);
      var manifest = await yt.videos.streamsClient.getManifest(video.id);
      var streamInfo = manifest.muxed.withHighestBitrate();

      Directory? dir = await getExternalStorageDirectory();
      String dosyaYolu = "${dir!.path}/${video.id}.mp4";

      setState(() => _durum = "İndiriliyor: ${video.title}");
      await Dio().download(streamInfo.url.toString(), dosyaYolu);

      setState(() => _durum = "BAŞARILI! \nDosya konumu: $dosyaYolu");
    } catch (e) {
      setState(() => _durum = "Hata oluştu. Linki kontrol edin.");
    } finally {
      yt.close();
      setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hızlı MP4 İndirici"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _controller, decoration: const InputDecoration(labelText: "YouTube URL")),
            const SizedBox(height: 20),
            Text(_durum, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            if (_yukleniyor) const CircularProgressIndicator()
            else ElevatedButton(onPressed: indirMP4, child: const Text("MP4 OLARAK İNDİR")),
          ],
        ),
      ),
    );
  }
}
