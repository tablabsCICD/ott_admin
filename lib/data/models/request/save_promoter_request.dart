class SavePromoterRequest {
  String? access;
  String? area;
  String? city;
  String? country;
  String? createdDate;
  String? district;
  int? id;
  String? level;
  String? pincode;
  String? promoterName;
  String? role;
  String? state;
  int? promoterId;
  String? taluka;
  int? userId;

  SavePromoterRequest(
      {this.access,
        this.area,
        this.city,
        this.country,
        this.createdDate,
        this.district,
        this.id,
        this.level,
        this.pincode,
        this.promoterName,
        this.promoterId,
        this.role,
        this.state,
        this.taluka,
        this.userId});

  SavePromoterRequest.fromJson(Map<String, dynamic> json) {
    access = json['access'];
    area = json['area'];
    city = json['city'];
    country = json['country'];
    createdDate = json['createdDate'];
    district = json['district'];
    id = json['id'];
    level = json['level'];
    pincode = json['pincode'];
    promoterName = json['promoterName'];
    promoterId = json['promoterId'];
    role = json['role'];
    state = json['state'];
    taluka = json['taluka'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access'] = this.access;
    data['area'] = this.area;
    data['city'] = this.city;
    data['country'] = this.country;
    data['createdDate'] = this.createdDate;
    data['district'] = this.district;
    data['id'] = this.id;
    data['level'] = this.level;
    data['pincode'] = this.pincode;
    data['promoterName'] = this.promoterName;
    data['promoterId'] = this.promoterId;
    data['role'] = this.role;
    data['state'] = this.state;
    data['taluka'] = this.taluka;
    data['userId'] = this.userId;
    return data;
  }
}
