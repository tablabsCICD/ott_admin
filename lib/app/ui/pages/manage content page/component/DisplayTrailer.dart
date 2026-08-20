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
    final url = widget.trailerUrl.trim();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Trailer Player"),
      ),
      body: SizedBox.expand(
        child: Center(
          child: url.isEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.ondemand_video_outlined,
                        size: 48, color: theme.hintColor),
                    const SizedBox(height: 12),
                    Text(
                      "Trailer is unavailable for this content",
                      style: TextStyle(color: theme.canvasColor, fontSize: 16),
                    ),
                  ],
                )
              : OttMediaPlayer(
                  url: url,
                  autoPlay: true,
                  fit: BoxFit.contain,
                  errorBuilder: (_, message) => Center(
                    child: Text(
                      message,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
