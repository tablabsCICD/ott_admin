class Cast {
  int? id;
  String? name;
  String? profileUrl;

  Cast({
    this.id,
    this.name,
    this.profileUrl,
  });

  factory Cast.fromJson(Map<String, dynamic> json) => Cast(
        id: json["id"],
        name: json["name"],
        profileUrl: json["profileUrl"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "profileUrl": profileUrl,
      };
}
