import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:universal_html/html.dart' as html; // For web download

class TrailerPage extends StatefulWidget {
  final String trailerUrl;

  const TrailerPage({super.key, required this.trailerUrl});

  @override
  State<TrailerPage> createState() => _TrailerPageState();
}

class _TrailerPageState extends State<TrailerPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    // Initialize VideoPlayerController
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse("https://www.w3schools.com/html/mov_bbb.mp4"), // Use the passed video URL
    );
    await _videoPlayerController.initialize();

    // Initialize ChewieController
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        showControls: true,
        allowPlaybackSpeedChanging: true,
        showControlsOnInitialize: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightBlueAccent,
        ),
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      );
    });
  }

  void _seekForward() {
    final currentPosition = _videoPlayerController.value.position;
    final duration = _videoPlayerController.value.duration;
    if (currentPosition + const Duration(seconds: 10) < duration) {
      _videoPlayerController.seekTo(currentPosition + const Duration(seconds: 10));
    } else {
      _videoPlayerController.seekTo(duration);
    }
  }

  void _seekBackward() {
    final currentPosition = _videoPlayerController.value.position;
    if (currentPosition > const Duration(seconds: 10)) {
      _videoPlayerController.seekTo(currentPosition - const Duration(seconds: 10));
    } else {
      _videoPlayerController.seekTo(Duration.zero);
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _videoPlayerController.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _downloadVideo() {
    final anchor = html.AnchorElement(href: widget.trailerUrl)
      ..target = 'blank'
      ..download = widget.trailerUrl.split('/').last
      ..click();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Advanced Chewie Player"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
                  ? Chewie(controller: _chewieController!)
                  : CircularProgressIndicator(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.replay_10, color: Colors.blue),
                  onPressed: _seekBackward,
                ),
                IconButton(
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.blue,
                  ),
                  onPressed: _toggleMute,
                ),
                IconButton(
                  icon: Icon(Icons.forward_10, color: Colors.blue),
                  onPressed: _seekForward,
                ),
                ElevatedButton.icon(
                  onPressed: _downloadVideo,
                  icon: Icon(Icons.download),
                  label: Text("Download"),
                ),
                DropdownButton<double>(
                  value: _videoPlayerController.value.playbackSpeed,
                  items: [0.5, 1.0, 1.5, 2.0].map((speed) {
                    return DropdownMenuItem(
                      value: speed,
                      child: Text("$speed"),
                    );
                  }).toList(),
                  onChanged: (speed) {
                    if (speed != null) {
                      _videoPlayerController.setPlaybackSpeed(speed);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
