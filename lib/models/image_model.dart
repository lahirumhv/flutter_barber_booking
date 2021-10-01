import 'dart:convert';

class ImageModel {
  String? image;
  ImageModel({
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'image': image,
    };
  }

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      image: map['image'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ImageModel.fromJson(String source) =>
      ImageModel.fromMap(json.decode(source));
}
