import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barber_booking/models/image_model.dart';

Future<List<ImageModel>> getLookbook() async {
  List<ImageModel> result = [];
  CollectionReference lookbookRef =
      FirebaseFirestore.instance.collection('Lookbook');
  QuerySnapshot snapshot = await lookbookRef.get();

  snapshot.docs.forEach((element) {
    result.add(ImageModel.fromJson(jsonEncode(element.data())));
  });

  return result;
}
