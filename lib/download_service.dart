import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  static Future<void> indirVeCevir(String url, String dosyaAdi, String format) async {
    final directory = await getExternalStorageDirectory(); // Telefonda indirilenler klasörü
    final mp4Path = "${directory!.path}/$dosyaAdi.mp4";
    final outputPath = "${directory.path}/$dosyaAdi.$format";

    Dio dio = Dio();

    // 1. Önce videoyu en yüksek kalitede indir (Geçici olarak MP4)
    print("İndirme başladı...");
    await dio.download(url, mp4Path);

    // 2. Eğer kullanıcı AVI veya MP3 istiyorsa FFmpeg ile çevir
    if (format == "avi") {
      print("AVI formatına çevriliyor...");
      await FFmpegKit.execute("-i $mp4Path -vcodec copy -acodec copy $outputPath");
      File(mp4Path).delete(); // Geçici MP4'ü sil
    } else if (format == "mp3") {
      print("Sese dönüştürülüyor...");
      await FFmpegKit.execute("-i $mp4Path -vn -ab 192k $outputPath");
      File(mp4Path).delete(); // Geçici MP4'ü sil
    }
    
    print("İşlem tamamlandı: $outputPath");
  }
}
