import 'package:flutter/material.dart';
import 'package:admin_ott/app/widgets/ott_media_player.dart';
import 'package:media_kit/media_kit.dart';

void main() {
  MediaKit.ensureInitialized();
  runApp(const VideoApp());
}

class VideoApp extends StatelessWidget {
  const VideoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const VideoScreen(),
    );
  }
}

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => VideoScreenState();
}

class VideoScreenState extends State<VideoScreen> {
  static const _sampleUrl =
      'https://tablabs-images.s3.ap-south-1.amazonaws.com/1750247436989-SampleVideo_360x240_30mb.mp4';

  Player? _player;
  bool _isReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        // Shared media_kit wrapper keeps the sample screen on the modern
        // playback engine with lifecycle and disposal handled in one place.
        child: OttMediaPlayer(
          url: _sampleUrl,
          autoPlay: false,
          onPlayerReady: (player) => _player = player,
          onReadyChanged: (ready) {
            if (!mounted) return;
            setState(() => _isReady = ready);
          },
          errorBuilder: (_, __) => const Text('Failed to load video'),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: _player?.stream.playing,
        initialData: _player?.state.playing ?? false,
        builder: (context, snapshot) {
          final isPlaying = snapshot.data ?? false;
          return FloatingActionButton(
            onPressed: _isReady ? _player?.playOrPause : null,
            child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          );
        },
      ),
    );
  }
}
