import 'package:flutter/material.dart';
import 'package:admin_ott/app/widgets/ott_media_player.dart';

class TrailerPage extends StatefulWidget {
  final String trailerUrl;

  const TrailerPage({super.key, required this.trailerUrl});

  @override
  State<TrailerPage> createState() => _TrailerPageState();
}

class _TrailerPageState extends State<TrailerPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Advanced Player"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _buildPlayer(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer(ThemeData theme) {
    // Shared media_kit wrapper owns the playback engine, lifecycle handling,
    // fullscreen orientation, and disposal.
    return OttMediaPlayer(
      url: widget.trailerUrl,
      autoPlay: false,
      errorBuilder: (_, message) => Text(
        message,
        style: TextStyle(color: theme.colorScheme.error),
      ),
    );
  }
}
