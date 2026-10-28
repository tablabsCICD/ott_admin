class Location {
  int? id;
  String? country;
  String? state;
  String? district;
  String? taluka;
  String? city;
  String? area;
  String? pincode;
  String? officeBuilding;

  Location(
      {this.id,
        this.country,
        this.state,
        this.district,
        this.taluka,
        this.city,
        this.area,
        this.pincode,
        this.officeBuilding});

  Location.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    id = rawId is int
        ? rawId
        : (rawId is num ? rawId.toInt() : int.tryParse(rawId?.toString() ?? ''));
    country = json['country']?.toString();
    state = json['state']?.toString();
    district = json['district']?.toString();
    taluka = json['taluka']?.toString();
    city = json['city']?.toString();
    area = json['area']?.toString();
    pincode = json['pincode']?.toString();
    officeBuilding = json['officeBuilding']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['country'] = this.country;
    data['state'] = this.state;
    data['district'] = this.district;
    data['taluka'] = this.taluka;
    data['city'] = this.city;
    data['area'] = this.area;
    data['pincode'] = this.pincode;
    data['officeBuilding'] = this.officeBuilding;
    return data;
  }
}