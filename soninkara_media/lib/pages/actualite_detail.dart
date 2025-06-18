import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soninkara_media/pages/home.dart';
import 'package:video_player/video_player.dart';

class DetailPage extends StatefulWidget {
  final Map actu;

  const DetailPage({super.key, required this.actu});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late bool alreadyLiked = false;
  late int likes = widget.actu['likes'] ?? 0;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getBool('liked_${widget.actu['id']}') ?? false;
    setState(() {
      alreadyLiked = liked;
    });
  }

  Future<void> _likeActualite() async {
    final prefs = await SharedPreferences.getInstance();
    final id = widget.actu['id'];
    final likedKey = 'liked_$id';

    if (prefs.getBool(likedKey) == true) return;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/actualites/$id/like/'),
      );

      if (response.statusCode == 200) {
        await prefs.setBool(likedKey, true);
        setState(() {
          alreadyLiked = true;
          likes++;
        });
      }
    } catch (e) {
      debugPrint('Erreur like: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final titre = widget.actu['titre'] ?? '';
    final contenu = widget.actu['contenu'] ?? '';
    final image = widget.actu['image'];
    final video = widget.actu['video'];
    final date = widget.actu['date_publication'] ?? '';
    final vues = widget.actu['vue'] ?? 0;
    final lectures = widget.actu['lecture'] ?? 0;

    final formattedDate = date.isNotEmpty
        ? DateFormat.yMMMMd('fr_FR').format(DateTime.parse(date))
        : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail Actualité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (video != null && video.isNotEmpty)
              VideoDetailPlayer(videoUrl: video)
            else if (image != null && image.isNotEmpty)
              Image.network(image, width: double.infinity, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(
              titre,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(contenu, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildStat(Icons.remove_red_eye, vues.toString()),
                const SizedBox(width: 16),
                _buildStat(Icons.menu_book, lectures.toString()),
                const SizedBox(width: 16),
                InkWell(
                  onTap: alreadyLiked ? null : _likeActualite,
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_up,
                        color: alreadyLiked ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text('$likes'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Retour"),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text("Partager"),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonction de partage à venir'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

class VideoDetailPlayer extends StatefulWidget {
  final String videoUrl;
  const VideoDetailPlayer({super.key, required this.videoUrl});

  @override
  State<VideoDetailPlayer> createState() => _VideoDetailPlayerState();
}

class _VideoDetailPlayerState extends State<VideoDetailPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    final fullUrl = widget.videoUrl.startsWith("http")
        ? widget.videoUrl
        : 'http://localhost:8000${widget.videoUrl}';

    _controller = VideoPlayerController.network(fullUrl)
      ..setLooping(false)
      ..setVolume(1.0);

    _initFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _controller.value.isInitialized) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(_controller),
                _PlayPauseOverlay(controller: _controller),
                VideoProgressIndicator(_controller, allowScrubbing: true),
              ],
            ),
          );
        } else {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _PlayPauseOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          controller.value.isPlaying ? controller.pause() : controller.play(),
      child: Center(
        child: Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          size: 60,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}
