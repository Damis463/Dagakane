import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class InterviewPage extends StatefulWidget {
  const InterviewPage({super.key});

  @override
  State<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends State<InterviewPage> {
  List<dynamic> interviews = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  VideoPlayerController? _videoController;
  int? _currentPlayingIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchInterviews();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInterviews() async {
    const apiUrl = 'http://localhost:8000/api/interviews/';

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            interviews = data;
            isLoading = false;
            hasError = false;
          });
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage =
              'Impossible de charger les interviews. Veuillez réessayer.';
        });
      }
    }
  }

  void _playVideo(String videoUrl, int index) {
    if (_currentPlayingIndex == index) {
      _videoController?.pause();
      setState(() {
        _currentPlayingIndex = null;
      });
      return;
    }

    _videoController?.dispose();
    _videoController = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _currentPlayingIndex = index;
            _videoController?.play();
          });
        }
      });
  }

  void _navigateToFullScreenVideo(BuildContext context) {
    if (_videoController == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Interview en plein écran'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(String videoUrl, int index, BuildContext context) {
    final isPlaying = _currentPlayingIndex == index;

    return GestureDetector(
      onTap: () {
        if (isPlaying) {
          _navigateToFullScreenVideo(context);
        } else {
          _playVideo(videoUrl, index);
        }
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_videoController != null &&
                _videoController!.value.isInitialized &&
                isPlaying)
              VideoPlayer(_videoController!),
            if (!isPlaying)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Icon(
                  Icons.play_circle_filled,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            if (isPlaying)
              Positioned(
                bottom: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: () => _navigateToFullScreenVideo(context),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewItem(Map<String, dynamic> interview, int index) {
    final titre = interview['titre']?.toString() ?? 'Interview';
    final personne = interview['personne']?.toString() ?? 'Inconnu';
    final resume = interview['resume']?.toString() ?? '';
    final date = interview['date_publication']?.toString() ?? '';
    final videoUrl = interview['video']?.toString();

    final formattedDate = date.isNotEmpty
        ? DateFormat('EEEE d MMMM y', 'fr_FR').format(DateTime.parse(date))
        : 'Date inconnue';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (videoUrl != null && videoUrl.isNotEmpty)
            _buildVideoPlayer(videoUrl, index, context),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      personne,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                if (resume.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    resume,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interviews'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchInterviews,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(errorMessage),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchInterviews,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          : interviews.isEmpty
          ? const Center(
              child: Text(
                'Aucune interview disponible',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchInterviews,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: interviews.length,
                itemBuilder: (context, index) {
                  return _buildInterviewItem(interviews[index], index);
                },
              ),
            ),
    );
  }
}
