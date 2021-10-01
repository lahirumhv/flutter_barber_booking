import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  String? docId;
  String? barberId;
  String? barberName;
  String? cityBook;
  String? customerId;
  String? customerName;
  String? customerPhone;
  String? salonAddress;
  String? salonId;
  String? salonName;
  String? services;
  String? time;
  double? totalPrice;
  bool? done;
  int? slot;
  int? timeStamp;
  DocumentReference? reference;

  BookingModel({
    this.docId,
    this.barberId,
    this.barberName,
    this.cityBook,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.salonAddress,
    this.salonId,
    this.salonName,
    this.services,
    this.time,
    this.totalPrice,
    this.done,
    this.slot,
    this.timeStamp,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'docId': docId,
      'barberId': barberId,
      'barberName': barberName,
      'cityBook': cityBook,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'salonAddress': salonAddress,
      'salonId': salonId,
      'salonName': salonName,
      'time': time,
      'done': done,
      'slot': slot,
      'timeStamp': timeStamp,
      // 'services':services,
      // 'totalPrice':totalPrice,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      // docId: map['docId'],
      barberId: map['barberId'],
      barberName: map['barberName'],
      cityBook: map['cityBook'],
      customerId: map['customerId'],
      customerName: map['customerName'],
      customerPhone: map['customerPhone'],
      salonAddress: map['salonAddress'],
      salonId: map['salonId'],
      salonName: map['salonName'],
      services: map['services'],
      time: map['time'],
      totalPrice: double.parse(
          map['totalPrice'] == null ? '0' : map['totalPrice'].toString()),
      done: map['done'] as bool,
      slot: int.parse(map['slot'] == null ? '-1' : map['slot'].toString()),
      timeStamp: int.parse(
          map['timeStamp'] == null ? '0' : map['timeStamp'].toString()),
      // reference: map['reference'],
    );
  }

  String toJson() => json.encode(toMap());

  factory BookingModel.fromJson(String source) =>
      BookingModel.fromMap(json.decode(source));
}
