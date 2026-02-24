import 'package:flutter/material.dart';
import 'video_model.dart';
import 'download_service.dart';

class VideoCard extends StatelessWidget {
  final YoutubeVideo video;
  const VideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol: Video Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(video.thumbnailUrl, width: 150, height: 85, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          // Sağ: Detaylar ve Butonlar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _actionBtn("Müzik", Icons.download, () => DownloadService.download(video.id, video.title, true)),
                    const SizedBox(width: 4),
                    _actionBtn("Video", Icons.download, () => DownloadService.download(video.id, video.title, false)),
                    const SizedBox(width: 4),
                    _actionBtn("Çal", Icons.play_arrow, () {}, isPlay: true),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, VoidCallback onTap, {bool isPlay = false}) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: Colors.indigo),
          shape: RoundedRectangle.circular(4),
          backgroundColor: isPlay ? Colors.white : Colors.transparent,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: Colors.indigo),
            Text(label, style: const TextStyle(color: Colors.indigo, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}
