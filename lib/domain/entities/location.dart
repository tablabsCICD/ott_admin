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
    id = json['id'];
    country = json['country'];
    state = json['state'];
    district = json['district'];
    taluka = json['taluka'];
    city = json['city'];
    area = json['area'];
    pincode = json['pincode'];
    officeBuilding = json['officeBuilding'];
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