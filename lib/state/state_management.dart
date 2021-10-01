import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_barber_booking/models/barber_model.dart';
import 'package:flutter_barber_booking/models/booking_model.dart';
import 'package:flutter_barber_booking/models/city_model.dart';
import 'package:flutter_barber_booking/models/salon_model.dart';
import 'package:flutter_barber_booking/models/service_model.dart';
import 'package:flutter_barber_booking/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userLogged = StateProvider((ref) => FirebaseAuth.instance.currentUser);
final userToken = StateProvider((ref) => '');
final forceReload = StateProvider((ref) => false);

final userInformation = StateProvider((ref) => UserModel());

//Booking state
final currentStep = StateProvider((ref) => 1);
final selectedCity = StateProvider((ref) => CityModel());
final selectedSalon = StateProvider((ref) => SalonModel());
final selectedBarber = StateProvider((ref) => BarberModel());
final selectedDate = StateProvider((ref) => DateTime.now());
//TODO: rename as selectedTimeSlotIndex
final selectedTimeSlot = StateProvider((ref) => -1);
final selectedTime = StateProvider((ref) => '');

//Delete Booking
final deleteFlagRefresh = StateProvider((ref) => false);

//Staff
final staffStep = StateProvider((ref) => 1);
final selectedBooking = StateProvider((ref) => BookingModel());
final selectedServices = StateProvider((ref) => <ServiceModel>[]);
//TODO: separate state providers for staff (city, salon, date selection)??