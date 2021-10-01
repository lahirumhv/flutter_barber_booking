import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_barber_booking/cloud_firestore/all_salon_ref.dart';
import 'package:flutter_barber_booking/models/barber_model.dart';
import 'package:flutter_barber_booking/models/booking_model.dart';
import 'package:flutter_barber_booking/models/city_model.dart';
import 'package:flutter_barber_booking/models/salon_model.dart';
import 'package:flutter_barber_booking/state/state_management.dart';
import 'package:flutter_barber_booking/utils/utils.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart';

class BookingScreen extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    var step = watch(currentStep).state;
    var cityWatch = watch(selectedCity).state;
    var salonWatch = watch(selectedSalon).state;
    var barberWatch = watch(selectedBarber).state;
    var dateWatch = watch(selectedDate).state;
    var timeSlotWatch = watch(selectedTimeSlot).state;
    var timeWatch = watch(selectedTime).state;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Booking'),
          backgroundColor: Color(0xFF383838),
        ),
        key: scaffoldKey,
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xFFFDF9EE),
        body: Column(
          children: [
            NumberStepper(
              activeStep: step - 1,
              direction: Axis.horizontal,
              enableNextPreviousButtons: false,
              enableStepTapping: false,
              numbers: [1, 2, 3, 4, 5],
              stepColor: Colors.black,
              activeStepColor: Colors.grey,
              // activeStepBorderColor: Colors.grey,
              numberStyle: TextStyle(color: Colors.white),
            ),
            //Screen
            Expanded(
              flex: 10,
              child: step == 1
                  ? displayCityList()
                  : step == 2
                      ? displaySalon(cityWatch.docId!)
                      : step == 3
                          ? displayBarber(salonWatch)
                          : step == 4
                              ? displayTimeSlot(context, barberWatch)
                              : step == 5
                                  ? displayConfirm(context)
                                  : Container(),
            ),
            //Button
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: step == 1
                              ? null
                              : () => context.read(currentStep).state--,
                          child: Text('Previous'),
                        ),
                      ),
                      SizedBox(
                        width: 30.0,
                      ),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: (step == 1 &&
                                      context.read(selectedCity).state.docId ==
                                          null) ||
                                  (step == 2 &&
                                      context.read(selectedSalon).state.name ==
                                          null) ||
                                  (step == 3 &&
                                      context
                                              .read(selectedBarber)
                                              .state
                                              .docId ==
                                          null) ||
                                  (step == 4 &&
                                      context.read(selectedTimeSlot).state ==
                                          -1)
                              ? null
                              : step == 5
                                  ? null
                                  : () => context.read(currentStep).state++,
                          child: Text('Next'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  displayCityList() {
    return FutureBuilder(
        future: getCities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var cities = snapshot.data as List<CityModel>;

            // ignore: unnecessary_null_comparison
            if (cities == null || cities.length == 0) {
              return Center(
                child: Text('Cannot load city list.'),
              );
            } else {
              return ListView.builder(
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () =>
                        context.read(selectedCity).state = cities[index],
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.home_work),
                        trailing: context.read(selectedCity).state.docId ==
                                cities[index].docId
                            ? Icon(Icons.check)
                            : null,
                        title: Text(
                          '${cities[index].name}',
                          style: GoogleFonts.robotoMono(),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }
        });
  }

  displaySalon(String cityDocId) {
    return FutureBuilder(
        future: getSalonByCity(cityDocId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var salons = snapshot.data as List<SalonModel>;

            // ignore: unnecessary_null_comparison
            if (salons == null || salons.length == 0) {
              return Center(
                child: Text('Cannot load Salon list.'),
              );
            } else {
              return ListView.builder(
                itemCount: salons.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () =>
                        context.read(selectedSalon).state = salons[index],
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.cut_sharp), //Icons.home_outlined
                        trailing: context.read(selectedSalon).state.docId ==
                                salons[index].docId
                            ? Icon(Icons.check)
                            : null,
                        title: Text(
                          '${salons[index].name}',
                          style: GoogleFonts.robotoMono(),
                        ),
                        subtitle: Text(
                          '${salons[index].address}',
                          style: GoogleFonts.robotoMono(
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          }
        });
  }

  displayBarber(SalonModel salonWatch) {
    return FutureBuilder(
        future: getBarberBySalon(salonWatch),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var barbers = snapshot.data as List<BarberModel>;

            // ignore: unnecessary_null_comparison
            if (barbers == null || barbers.length == 0) {
              return Center(
                child: Text('Barber list is empty.'),
              );
            } else {
              return ListView.builder(
                itemCount: barbers.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () =>
                        context.read(selectedBarber).state = barbers[index],
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.person), //Icons.home_outlined
                        trailing: context.read(selectedBarber).state.docId ==
                                barbers[index].docId
                            ? Icon(Icons.check)
                            : null,
                        title: Text(
                          '${barbers[index].name}',
                          style: GoogleFonts.robotoMono(),
                        ),
                        subtitle: RatingBar.builder(
                            ignoreGestures: true,
                            itemSize: 16.0,
                            allowHalfRating: true,
                            initialRating: barbers[index].rating!,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                            itemPadding: EdgeInsets.all(4.0),
                            onRatingUpdate: (value) {}),
                      ),
                    ),
                  );
                },
              );
            }
          }
        });
  }

  displayTimeSlot(BuildContext context, BarberModel barberModel) {
    var now = context.read(selectedDate).state;

    return Column(
      children: [
        Container(
          color: Color(0xFF008577),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        '${DateFormat.MMMM().format(now)}',
                        style: GoogleFonts.robotoMono(color: Colors.white54),
                      ),
                      Text(
                        '${now.day}',
                        style: GoogleFonts.robotoMono(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22.0,
                        ),
                      ),
                      Text(
                        '${DateFormat.EEEE().format(now)}',
                        style: GoogleFonts.robotoMono(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              )),
              GestureDetector(
                onTap: () {
                  DatePicker.showDatePicker(
                    context,
                    showTitleActions: true,
                    //displays only 31 days from selected date(ie. now)
                    minTime: DateTime.now(),
                    maxTime: now.add(Duration(days: 31)),
                    onConfirm: (date) =>
                        context.read(selectedDate).state = date,
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: getNearestAvailableTimeSlot(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                var nearestTimeSlot = snapshot.data as int;
                return FutureBuilder(
                  future: getTimeSlotOfBarber(barberModel,
                      '${DateFormat('dd_MM_yyyy').format(context.read(selectedDate).state)}'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      var listOfBookedTimeSlots = snapshot.data as List<int>;
                      return GridView.builder(
                        itemCount: TIME_SLOT.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: (index < nearestTimeSlot &&
                                      context.read(selectedDate).state.day ==
                                          DateTime.now().day) ||
                                  listOfBookedTimeSlots.contains(index)
                              ? null
                              : () {
                                  context.read(selectedTime).state =
                                      TIME_SLOT.elementAt(index);
                                  context.read(selectedTimeSlot).state = index;
                                },
                          child: Card(
                            color: listOfBookedTimeSlots.contains(index)
                                ? Colors.white10
                                : (index < nearestTimeSlot &&
                                        context.read(selectedDate).state.day ==
                                            DateTime.now().day)
                                    ? Colors.white60
                                    : context.read(selectedTime).state ==
                                            TIME_SLOT.elementAt(index)
                                        ? Colors.white54
                                        : Colors.white,
                            child: GridTile(
                              child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('${TIME_SLOT.elementAt(index)}'),
                                    Text(listOfBookedTimeSlots.contains(index)
                                        ? 'Full'
                                        : (index < nearestTimeSlot &&
                                                context
                                                        .read(selectedDate)
                                                        .state
                                                        .day ==
                                                    DateTime.now().day)
                                            ? 'Not Available'
                                            : 'Available'),
                                  ],
                                ),
                              ),
                              header: context.read(selectedTime).state ==
                                      TIME_SLOT.elementAt(index)
                                  ? Icon(Icons.check)
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  confirmBooking(BuildContext context) {
    var hour = int.parse(context.read(selectedTime).state.split(':')[0]);
    var minutes = int.parse(
        context.read(selectedTime).state.split(':')[1].substring(0, 2));
    var timeStamp = DateTime(
      context.read(selectedDate).state.year,
      context.read(selectedDate).state.month,
      context.read(selectedDate).state.day,
      hour,
      minutes,
    ).millisecondsSinceEpoch;

    BookingModel bookingModel = BookingModel(
      barberId: context.read(selectedBarber).state.docId,
      barberName: context.read(selectedBarber).state.name,
      cityBook: context.read(selectedCity).state.name,
      customerId: context.read(userLogged).state!.uid,
      customerName: context.read(userInformation).state.name,
      customerPhone: FirebaseAuth.instance.currentUser!.phoneNumber,
      done: false,
      salonAddress: context.read(selectedSalon).state.address,
      salonId: context.read(selectedSalon).state.docId,
      salonName: context.read(selectedSalon).state.name,
      slot: context.read(selectedTimeSlot).state,
      timeStamp: timeStamp,
      time:
          '${context.read(selectedTime).state} - ${DateFormat('dd/MM/yyyy').format(context.read(selectedDate).state)}',
    );

    var batch = FirebaseFirestore.instance.batch();

    DocumentReference barberBookingRef = context
        .read(selectedBarber)
        .state
        .reference!
        .collection(
            '${DateFormat('dd_MM_yyyy').format(context.read(selectedDate).state)}')
        .doc(context.read(selectedTimeSlot).state.toString());

    DocumentReference userBookingRef = FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .collection('Booking_${FirebaseAuth.instance.currentUser!.uid}')
        .doc(
            '${context.read(selectedBarber).state.docId}_${DateFormat('dd_MM_yyyy').format(context.read(selectedDate).state)}');

    //Set for FireStore WriteBatch
    batch.set(barberBookingRef, bookingModel.toMap());
    batch.set(userBookingRef, bookingModel.toMap());
    batch.commit().then((value) {
      Navigator.of(context).pop();

      //TODO: not to display booking screen afterwords, set delay after navigator pop
      ScaffoldMessenger.of(scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text('Booking Successful!')));

      //Reset Value
      context.read(selectedDate).state = DateTime.now();
      context.read(selectedBarber).state = BarberModel();
      context.read(selectedCity).state = CityModel();
      context.read(selectedSalon).state = SalonModel();
      context.read(currentStep).state = 1;
      context.read(selectedTime).state = '';
      context.read(selectedTimeSlot).state = -1;

      //Create Event
      final event = Event(
        title:
            'Barber appointment ${context.read(selectedTime).state} - ${DateFormat('dd/MM/yyyy').format(context.read(selectedDate).state)}',
        location: '${context.read(selectedSalon).state.address}',
        startDate: DateTime(
          context.read(selectedDate).state.year,
          context.read(selectedDate).state.month,
          context.read(selectedDate).state.year,
          hour,
          minutes,
        ),
        endDate: DateTime(
          context.read(selectedDate).state.year,
          context.read(selectedDate).state.month,
          context.read(selectedDate).state.year,
          hour,
          minutes + 30,
        ),
        iosParams: IOSParams(reminder: Duration(minutes: 30)),
        androidParams: AndroidParams(emailInvites: []),
      );
      Add2Calendar.addEvent2Cal(event).then((value) {});
    });
  }

  displayConfirm(BuildContext context) {
    //TODO:Bottom overflowed by 22 pixels
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
        Expanded(
            flex: 3,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                  //SingleChildScrollView to rectify if there's a widget overflow
                  //in video 23, different solution instead of this
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          'Thank you for booking our services!'.toUpperCase(),
                          style: GoogleFonts.robotoMono(
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Booking Information'.toUpperCase(),
                          style: GoogleFonts.robotoMono(),
                        ),
                        Row(
                          children: [
                            Icon(Icons.calendar_today),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              '${context.read(selectedTime).state} - ${DateFormat('dd/MM/yyyy').format(context.read(selectedDate).state)}'
                                  .toUpperCase(),
                              style: GoogleFonts.robotoMono(),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          children: [
                            Icon(Icons.person),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              '${context.read(selectedBarber).state.name}'
                                  .toUpperCase(),
                              style: GoogleFonts.robotoMono(),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Divider(
                          thickness: 1.0,
                        ),
                        Row(
                          children: [
                            Icon(Icons.cut_sharp),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              '${context.read(selectedSalon).state.name}'
                                  .toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.robotoMono(),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              '${context.read(selectedSalon).state.address}'
                                  .toUpperCase(),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.robotoMono(),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => confirmBooking(context),
                          child: Text('Confirm'),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black26),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
