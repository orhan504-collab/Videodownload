import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_video/ffmpeg_kit.dart'; // Yeni paket yolu
import 'package:path_provider/path_provider.dart';

class DownloadService {
  static Future<void> indirVeCevir(String url, String dosyaAdi, String format) async {
    final directory = await getExternalStorageDirectory(); 
    final mp4Path = "${directory!.path}/$dosyaAdi.mp4";
    final outputPath = "${directory.path}/$dosyaAdi.$format";

    Dio dio = Dio();

    try {
      print("İndirme başladı...");
      await dio.download(url, mp4Path);

      if (format == "avi") {
        print("AVI formatına çevriliyor...");
        await FFmpegKit.execute("-i \"$mp4Path\" -vcodec copy -acodec copy \"$outputPath\"");
        File(mp4Path).deleteSync(); 
      } else if (format == "mp3") {
        print("Sese dönüştürülüyor...");
        await FFmpegKit.execute("-i \"$mp4Path\" -vn -ab 192k \"$outputPath\"");
        File(mp4Path).deleteSync(); 
      }
      print("İşlem tamamlandı: $outputPath");
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }
}
