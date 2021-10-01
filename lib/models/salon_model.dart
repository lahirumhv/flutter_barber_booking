import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class SalonModel {
  String? name;
  String? address;
  String? docId;
  DocumentReference? reference;

  SalonModel({
    this.name,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
    };
  }

  factory SalonModel.fromMap(Map<String, dynamic> map) {
    return SalonModel(
      name: map['name'],
      address: map['address'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SalonModel.fromJson(String source) =>
      SalonModel.fromMap(json.decode(source));
}
