import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_barber_booking/models/booking_model.dart';
import 'package:flutter_barber_booking/models/user_model.dart';
import 'package:flutter_barber_booking/state/state_management.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<UserModel> getUserProfiles(BuildContext context, String? phone) async {
  CollectionReference userRef = FirebaseFirestore.instance.collection('User');
  DocumentSnapshot snapshot = await userRef.doc(phone).get();
  if (snapshot.exists) {
    var userModel = UserModel.fromJson(jsonEncode(snapshot.data()));
    context.read(userInformation).state = userModel;
    return userModel;
  } else {
    //Empty object
    return UserModel();
  }
}

Future<List<BookingModel>> getUserHistory() async {
  var listBooking = <BookingModel>[];
  CollectionReference historyRef = FirebaseFirestore.instance
      .collection('User')
      .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
      .collection('Booking_${FirebaseAuth.instance.currentUser!.uid}');
  var snapshot = await historyRef.orderBy('timeStamp', descending: true).get();

  snapshot.docs.forEach((element) {
    var booking = BookingModel.fromJson(jsonEncode(element.data()));
    booking.docId = element.id;
    booking.reference = element.reference;
    listBooking.add(booking);
  });

  return listBooking;
}
