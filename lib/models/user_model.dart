import 'dart:convert';

class UserModel {
  String? name;
  String? address;
  bool? isStaff;
  UserModel({
    this.name,
    this.address,
    this.isStaff,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'isStaff': isStaff,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'],
      address: map['address'],
      isStaff: map['isStaff'] == null ? false : map['isStaff'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
