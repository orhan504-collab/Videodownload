import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_https/ffmpeg_kit.dart'; // Paket yolu güncellendi
import 'package:path_provider/path_provider.dart';

class DownloadService {
  static Future<void> indirVeCevir(String url, String dosyaAdi, String format) async {
    final directory = await getExternalStorageDirectory(); 
    if (directory == null) return;

    final mp4Path = "${directory.path}/$dosyaAdi.mp4";
    final outputPath = "${directory.path}/$dosyaAdi.$format";

    Dio dio = Dio();

    try {
      print("İndirme başladı...");
      await dio.download(url, mp4Path);

      // FFmpeg komutlarını tırnak içine alarak dosya isimlerindeki boşluk hatalarını engelliyoruz
      if (format == "avi") {
        await FFmpegKit.execute("-i \"$mp4Path\" -c copy \"$outputPath\"");
      } else if (format == "mp3") {
        await FFmpegKit.execute("-i \"$mp4Path\" -vn -ab 192k \"$outputPath\"");
      }
      
      if (File(mp4Path).existsSync()) {
        File(mp4Path).deleteSync(); 
      }
    } catch (e) {
      print("İşlem hatası: $e");
    }
  }
}
