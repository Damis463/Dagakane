import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class CulturePage extends StatefulWidget {
  const CulturePage({super.key});

  @override
  State<CulturePage> createState() => _CulturePageState();
}

class _CulturePageState extends State<CulturePage> {
  List<dynamic> cultures = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchCultureData();
  }

  Future<void> _fetchCultureData() async {
    const url = 'http://localhost:8000/api/cultures/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            cultures = data;
            isLoading = false;
            hasError = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
            hasError = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  bool isVideo(String url) {
    return url.endsWith('.mp4');
  }

  void _showFullScreenVideo(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(videoUrl: url),
      ),
    );
  }

  void _showImageDialog(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(child: Image.network(url)),
        ),
      ),
    );
  }

  Widget _buildCultureItem(Map item) {
    final titre = item['titre'] ?? '';
    final lieu = item['lieu'] ?? '';
    final video = item['video'] ?? '';
    final date = item['date_publication'] ?? '';

    String fullUrl = video.startsWith('http')
        ? video
        : 'http://localhost:8000$video';

    String dateFormatted = '';
    try {
      dateFormatted = DateFormat(
        'd MMMM y à HH:mm',
        'fr_FR',
      ).format(DateTime.parse(date));
    } catch (_) {
      dateFormatted = date;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titre,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('Lieu : $lieu'),
            const SizedBox(height: 6),
            Text(dateFormatted, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                isVideo(fullUrl)
                    ? _showFullScreenVideo(fullUrl)
                    : _showImageDialog(fullUrl);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isVideo(fullUrl)
                    ? Container(
                        height: 200,
                        color: Colors.black26,
                        child: const Center(
                          child: Icon(
                            Icons.play_circle,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Image.network(
                        fullUrl,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey,
                            child: const Center(
                              child: Icon(Icons.broken_image),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Culture')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? const Center(child: Text('Erreur lors du chargement.'))
          : ListView.builder(
              itemCount: cultures.length,
              itemBuilder: (context, index) {
                if (index < 0 || index >= cultures.length) {
                  return const SizedBox.shrink(); // évite RangeError
                }
                return _buildCultureItem(cultures[index]);
              },
            ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPlayer({super.key, required this.videoUrl});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => isReady = true);
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: isReady
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
