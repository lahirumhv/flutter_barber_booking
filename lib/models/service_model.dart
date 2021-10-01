import 'dart:convert';

class ServiceModel {
  String? name;
  String? docId;
  double? price;
  ServiceModel({
    this.name,
    this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      name: map['name'],
      price: map['price'] == null ? 0 : double.parse(map['price'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory ServiceModel.fromJson(String source) =>
      ServiceModel.fromMap(json.decode(source));
}
