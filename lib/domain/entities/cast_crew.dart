class Cast {
  int? id;
  String? name;
  String? profileUrl;
  String? role;
  String? characterName;
  String? designation;

  Cast({
    this.id,
    this.name,
    this.profileUrl,
    this.role,
    this.characterName,
    this.designation,
  });

  factory Cast.fromJson(Map<String, dynamic> json) => Cast(
        id: _asInt(json["id"] ?? json["castId"]),
        name: _asString(
            json["name"] ?? json["personName"] ?? json["actorName"] ?? json["castName"] ?? json["title"]),
        profileUrl: _asString(json["profileUrl"] ??
            json["profileImage"] ??
            json["imageUrl"] ??
            json["photoUrl"] ??
            json["image"] ??
            json["photo"] ??
            json["avatar"]),
        role: _asString(json["role"] ?? json["roleName"] ?? json["type"] ?? json["castType"]),
        characterName:
            _asString(json["characterName"] ?? json["character"] ?? json["charName"] ?? json["as"]),
        designation:
            _asString(json["designation"] ?? json["designationName"] ?? json["occupation"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "profileUrl": profileUrl,
        "role": role,
        "characterName": characterName,
        "designation": designation,
      };
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  return str.isEmpty ? null : str;
}

