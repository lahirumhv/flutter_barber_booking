import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class BarberModel {
  String? name;
  String? docId;
  double? rating;
  int? ratingTimes;

  DocumentReference? reference;
  BarberModel({
    this.name,
    this.rating,
    this.ratingTimes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rating': rating,
      'ratingTimes': ratingTimes,
    };
  }

  factory BarberModel.fromMap(Map<String, dynamic> map) {
    return BarberModel(
      name: map['name'],
      rating: double.parse(map['rating'].toString()),
      ratingTimes: int.parse(map['ratingTimes'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory BarberModel.fromJson(String source) =>
      BarberModel.fromMap(json.decode(source));
}
