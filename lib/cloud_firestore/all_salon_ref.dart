import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_barber_booking/models/barber_model.dart';
import 'package:flutter_barber_booking/models/booking_model.dart';
import 'package:flutter_barber_booking/models/city_model.dart';
import 'package:flutter_barber_booking/models/salon_model.dart';
import 'package:flutter_barber_booking/state/state_management.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

Future<List<CityModel>> getCities() async {
  var cities = <CityModel>[];
  var cityRef = FirebaseFirestore.instance.collection('AllSalon');
  QuerySnapshot snapshot = await cityRef.get();

  snapshot.docs.forEach((element) {
    cities.add(CityModel.fromJson(jsonEncode(element.data())));
    cities.last.docId = element.id;
  });

  return cities;
}

Future<List<SalonModel>> getSalonByCity(String cityId) async {
  var salons = <SalonModel>[];
  var salonRef = FirebaseFirestore.instance
      .collection('AllSalon')
      .doc(cityId)
      .collection('Branch');
  QuerySnapshot snapshot = await salonRef.get();

  snapshot.docs.forEach((element) {
    var salon = SalonModel.fromJson(jsonEncode(element.data()));
    salon.docId = element.id;
    salon.reference = element.reference;
    salons.add(salon);
  });

  return salons;
}

Future<List<BarberModel>> getBarberBySalon(SalonModel salon) async {
  var barbers = <BarberModel>[];
  var barberRef = salon.reference!.collection('Barber');
  QuerySnapshot snapshot = await barberRef.get();

  snapshot.docs.forEach((element) {
    var barber = BarberModel.fromJson(jsonEncode(element.data()));
    barber.docId = element.id;
    barber.reference = element.reference;
    barbers.add(barber);
  });

  return barbers;
}

Future<List<int>> getTimeSlotOfBarber(
    BarberModel barberModel, String date) async {
  var result = <int>[];
  var bookingRef = barberModel.reference!.collection(date);
  QuerySnapshot snapshot = await bookingRef.get();
  snapshot.docs.forEach((element) {
    result.add(int.parse(element.id));
  });

  return result;
}

Future<bool> checkStaffOfThisSalon(BuildContext context) async {
  DocumentSnapshot barberSnapshot = await context
      .read(selectedSalon)
      .state
      .reference!
      .collection('Barber')
      .doc(context.read(userLogged).state!.uid)
      .get();

  return barberSnapshot.exists;
}

Future<List<int>> getBookingSlotOfBarber(
    BuildContext context, String date) async {
  var barberDocument = context
      .read(selectedSalon)
      .state
      .reference!
      .collection('Barber')
      .doc(context.read(userLogged).state!.uid);
  List<int> result = <int>[];
  var bookingRef = barberDocument.collection(date);
  QuerySnapshot snapshot = await bookingRef.get();

  snapshot.docs.forEach((element) {
    result.add(int.parse(element.id));
  });
  return result;
}

Future<BookingModel> getDetailBooking(
    BuildContext context, int timeSlot) async {
  DocumentReference bookingRef = context
      .read(selectedSalon)
      .state
      .reference!
      .collection('Barber')
      .doc(context.read(userLogged).state!.uid)
      .collection(
          '${DateFormat('dd_MM_yyyy').format(context.read(selectedDate).state)}')
      .doc(timeSlot.toString());

  DocumentSnapshot snapshot = await bookingRef.get();
  if (snapshot.exists) {
    BookingModel bookingModel =
        BookingModel.fromJson(jsonEncode(snapshot.data()));
    bookingModel.docId = snapshot.id;
    bookingModel.reference = snapshot.reference;
    context.read(selectedBooking).state = bookingModel;

    return bookingModel;
  } else {
    return BookingModel();
  }
}
