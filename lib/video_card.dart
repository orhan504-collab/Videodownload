import 'package:flutter/material.dart';
import 'video_model.dart';
import 'download_service.dart';

class VideoCard extends StatelessWidget {
  final VideoModel video;
  const VideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: Row(
        children: [
          // Sol: Video Resmi (Thumbnail)
          Image.network(video.thumbnail, width: 130, height: 90, fit: BoxFit.cover),
          
          // Sağ: Başlık ve Butonlar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buton(context, "Müzik", Colors.green, "mp3"),
                      _buton(context, "Video", Colors.red, "mp4"),
                      _buton(context, "AVI", Colors.blue, "avi"),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buton(BuildContext context, String yazı, Color renk, String format) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: renk, padding: const EdgeInsets.symmetric(horizontal: 5)),
      onPressed: () {
        DownloadService.indirVeCevir(video.url, video.title, format);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$format indirmesi başlatıldı...")));
      },
      child: Text(yazı, style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }
}
