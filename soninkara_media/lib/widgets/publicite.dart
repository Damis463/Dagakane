import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PubliciteWidget extends StatefulWidget {
  const PubliciteWidget({super.key});

  @override
  State<PubliciteWidget> createState() => _PubliciteWidgetState();
}

class _PubliciteWidgetState extends State<PubliciteWidget> {
  Map? pub;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    fetchPub();
  }

  Future<void> fetchPub() async {
    const url = 'http://localhost:8000/api/publicites/';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List pubs = json.decode(utf8.decode(response.bodyBytes));
      if (pubs.isNotEmpty) {
        setState(() {
          pub = pubs.first;
        });

        if (pub!['video'] != null && pub!['video'] != '') {
          _videoController = VideoPlayerController.network(pub!['video'])
            ..initialize().then((_) => setState(() {}))
            ..setLooping(true)
            ..play();
        }
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (pub == null) {
      return const SizedBox.shrink(); // ou CircularProgressIndicator()
    }

    return Card(
      margin: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (pub!['video'] != null && pub!['video'] != '')
            AspectRatio(
              aspectRatio: _videoController?.value.aspectRatio ?? 16 / 9,
              child: _videoController!.value.isInitialized
                  ? VideoPlayer(_videoController!)
                  : const Center(child: CircularProgressIndicator()),
            )
          else if (pub!['image'] != null && pub!['image'] != '')
            CachedNetworkImage(
              imageUrl: pub!['image'],
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              placeholder: (_, __) =>
                  Container(height: 200, color: Colors.grey[300]),
              errorWidget: (_, __, ___) =>
                  Container(height: 200, color: Colors.grey[300]),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              pub!['message'] ?? '',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
