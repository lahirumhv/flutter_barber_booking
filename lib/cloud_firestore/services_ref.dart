import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_barber_booking/models/service_model.dart';
import 'package:flutter_barber_booking/state/state_management.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<List<ServiceModel>> getServices(BuildContext context) async {
  var services = <ServiceModel>[];
  CollectionReference servicesRef =
      FirebaseFirestore.instance.collection('Services');

  //Another implementation which is also correct
  // QuerySnapshot snapshot = await servicesRef.get();
  // snapshot.docs.forEach((element) {
  //   if (jsonDecode(jsonEncode(element.data()))[
  //           context.read(selectedSalon).state.docId] !=
  //       null) {
  //     var e = jsonDecode(jsonEncode(element.data()))[
  //         context.read(selectedSalon).state.docId] as bool;
  //     if (e) {
  //       var service = ServiceModel.fromJson(jsonEncode(element.data()));
  //       service.docId = element.id;
  //       services.add(service);
  //     }
  //   }
  // });

  QuerySnapshot snapshot = await servicesRef
      .where(context.read(selectedSalon).state.docId!, isEqualTo: true)
      .get();
  snapshot.docs.forEach((element) {
    var serviceModel = ServiceModel.fromJson(jsonEncode(element.data()));
    serviceModel.docId = element.id;
    services.add(serviceModel);
  });

  return services;
}
