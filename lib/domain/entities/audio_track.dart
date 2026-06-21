class AudioTrack {
  String? language;
  String? code;

  AudioTrack({
    this.language,
    this.code,
  });

  factory AudioTrack.fromJson(Map<String, dynamic> json) => AudioTrack(
        language: json["language"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "language": language,
        "code": code,
      };
}
