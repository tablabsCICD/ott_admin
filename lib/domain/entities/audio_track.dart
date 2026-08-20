class AudioTrack {
  String? language;
  String? fileUrl;

  AudioTrack({
    this.language,
    this.fileUrl,
  });

  factory AudioTrack.fromJson(Map<String, dynamic> json) => AudioTrack(
        language: json["language"] ?? json["name"],
        fileUrl: json["fileUrl"] ?? json["url"],
      );

  Map<String, dynamic> toJson() => {
        "language": language,
        if (fileUrl != null && fileUrl!.isNotEmpty) "fileUrl": fileUrl,
      };
}
