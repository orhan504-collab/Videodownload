import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  static final yt = YoutubeExplode();

  static Future<void> download(String id, String title, bool isMp3) async {
    try {
      var manifest = await yt.videos.streamsClient.getManifest(id);
      var streamInfo = isMp3 ? manifest.audioOnly.withHighestBitrate() : manifest.muxed.bestQuality;
      
      var stream = yt.videos.streamsClient.get(streamInfo);
      var dir = await getExternalStorageDirectory();
      String cleanTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '');
      var file = File('${dir!.path}/$cleanTitle${isMp3 ? ".mp3" : ".mp4"}');
      
      var fileStream = file.openWrite();
      await stream.pipe(fileStream);
      await fileStream.close();
      print("İndirildi: ${file.path}");
    } catch (e) {
      print("Hata: $e");
    }
  }
}
