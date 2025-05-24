class UserProfile {
  final String name;
  final String mobileNo;
  final String email;
  final String region;
  final String province;
  final String city;
  final String brgy;
  final String street;

  UserProfile({
    required this.name,
    required this.mobileNo,
    required this.email,
    required this.region,
    required this.province,
    required this.city,
    required this.brgy,
    required this.street
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      email: json['email'] ?? '',
      region: json['region'] ?? '',
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      brgy: json['brgy'] ?? '',
      street: json['street'] ?? '',
    );
  }
}
