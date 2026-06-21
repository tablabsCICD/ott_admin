class LanguageList {
  String? language;
  String? fileUrl;

  LanguageList({
    this.language,
    this.fileUrl,
  });

  factory LanguageList.fromJson(Map<String, dynamic> json) => LanguageList(
        language: json["language"],
        fileUrl: json["fileUrl"],
      );

  Map<String, dynamic> toJson() => {
        "language": language,
        "fileUrl": fileUrl,
      };
}
