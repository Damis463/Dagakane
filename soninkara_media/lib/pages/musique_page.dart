import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';

class MusiquePage extends StatefulWidget {
  final Musique;

  const MusiquePage({Key? key, this.Musique}) : super(key: key);

  @override
  _MusiquePageState createState() => _MusiquePageState();
}

class _MusiquePageState extends State<MusiquePage> {
  late VideoPlayerController _videoController;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isVideoPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _initializePlayers();
  }

  Future<void> _initializePlayers() async {
    // Initialize audio player
    _audioPlayer = AudioPlayer();

    if (widget.Musique.fichier_audio != null) {
      await _audioPlayer.setSource(UrlSource(widget.Musique.fichier_audio!));
      _duration = (await _audioPlayer.getDuration()) ?? Duration.zero;

      _audioPlayer.onPositionChanged.listen((Duration p) {
        setState(() => _position = p);
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      });
    }

    // Initialize video player
    if (widget.Musique.video != null) {
      _videoController = VideoPlayerController.network(widget.Musique.video!)
        ..initialize().then((_) {
          setState(() {});
          _videoController.setLooping(true);
        });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    if (widget.Musique.video != null) {
      _videoController.dispose();
    }
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
      // Increment play count (would typically call an API here)
      setState(() {
        widget.Musique.lecture++;
      });
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _toggleVideoPlayPause() {
    setState(() {
      if (_isVideoPlaying) {
        _videoController.pause();
      } else {
        _videoController.play();
        // Increment view count (would typically call an API here)
        widget.Musique.vue++;
      }
      _isVideoPlaying = !_isVideoPlaying;
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      widget.Musique.likes += _isLiked ? 1 : -1;
      // Would typically call an API to update like status
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.Musique.titre),
        actions: [
          IconButton(icon: Icon(Icons.share), onPressed: () => _shareMusic()),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Art with Video
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.Musique.couverture != null)
                    CachedNetworkImage(
                      imageUrl: widget.Musique.couverture!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.music_note),
                    ),
                  if (widget.Musique.video != null &&
                      _videoController.value.isInitialized)
                    GestureDetector(
                      onTap: _toggleVideoPlayPause,
                      child: VideoPlayer(_videoController),
                    ),
                  if (widget.Musique.video != null &&
                      _videoController.value.isInitialized)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.black54,
                        onPressed: _toggleVideoPlayPause,
                        child: Icon(
                          _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Music Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.Musique.titre,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.Musique.artiste,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.Musique.vue}',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.play_circle_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.Musique.lecture}',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(widget.Musique.date_publication),
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Audio Player Controls
            if (widget.Musique.fichier_audio != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Slider(
                      min: 0,
                      max: _duration.inSeconds.toDouble(),
                      value: _position.inSeconds.toDouble(),
                      onChanged: (value) async {
                        final position = Duration(seconds: value.toInt());
                        await _audioPlayer.seek(position);
                        await _audioPlayer.resume();
                        setState(() {
                          _position = position;
                          _isPlaying = true;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(_position)),
                          Text(_formatDuration(_duration - _position)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.skip_previous, size: 32),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: Icon(Icons.skip_next, size: 32),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Like Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : null,
                    ),
                    onPressed: _toggleLike,
                  ),
                  Text('${widget.Musique.likes} likes'),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.playlist_add),
                    onPressed: () => _addToPlaylist(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareMusic() {
    // Implement share functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share ${widget.Musique.titre}'),
        content: Text('Share this music with your friends'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addToPlaylist() {
    // Implement add to playlist functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to Playlist'),
        content: Text('Select playlist to add this song'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add to playlist logic
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Added to playlist')));
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}

// Model class for Dart (matching your Django model)
class Musique {
  final String titre;
  final String artiste;
  final String? fichier_audio;
  final String? video;
  final String? couverture;
  int vue;
  int lecture;
  int likes;
  final DateTime date_publication;

  Musique({
    required this.titre,
    required this.artiste,
    this.fichier_audio,
    this.video,
    this.couverture,
    this.vue = 0,
    this.lecture = 0,
    this.likes = 0,
    required this.date_publication,
  });

  @override
  String toString() {
    return '$titre - $artiste';
  }
}
