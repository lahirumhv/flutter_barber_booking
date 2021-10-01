import 'package:flutter/material.dart';
import 'package:flutter_barber_booking/cloud_firestore/all_salon_ref.dart';
import 'package:flutter_barber_booking/models/city_model.dart';
import 'package:flutter_barber_booking/models/salon_model.dart';
import 'package:flutter_barber_booking/state/state_management.dart';
import 'package:flutter_barber_booking/utils/utils.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StaffHome extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    var currentStaffStep = watch(staffStep).state;
    var cityWatch = watch(selectedCity).state;
    var salonWatch = watch(selectedSalon).state;
    var dateWatch = watch(selectedDate).state;
    return SafeArea(
      child: Scaffold(
        //Resize when onscreen keyboard appears
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xFFDFDFDF),
        appBar: AppBar(
          title: Text(currentStaffStep == 1
              ? 'Select City'
              : currentStaffStep == 2
                  ? 'Select Saloon'
                  : currentStaffStep == 3
                      ? 'Your Appointment'
                      : 'Staff Home'),
          backgroundColor: Color(0xFF383838),
        ),
        body: Center(
          child: Column(
            children: [
              //Area
              Expanded(
                flex: 10,
                child: currentStaffStep == 1
                    ? displayCity()
                    : currentStaffStep == 2
                        ? displaySalon(cityWatch.docId!)
                        : currentStaffStep == 3
                            ? displayAppointment(context)
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
                            onPressed: currentStaffStep == 1
                                ? null
                                : () => context.read(staffStep).state--,
                            child: Text('Previous'),
                          ),
                        ),
                        SizedBox(
                          width: 30.0,
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: (currentStaffStep == 1 &&
                                        context
                                                .read(selectedCity)
                                                .state
                                                .docId ==
                                            null) ||
                                    (currentStaffStep == 2 &&
                                        context
                                                .read(selectedSalon)
                                                .state
                                                .name ==
                                            null) ||
                                    currentStaffStep == 3
                                ? null
                                : () => context.read(staffStep).state++,
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
      ),
    );
  }

  displayCity() {
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
            return GridView.builder(
              itemCount: cities.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => context.read(selectedCity).state = cities[index],
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Card(
                      shape: context.read(selectedCity).state.name ==
                              cities[index].name
                          ? RoundedRectangleBorder(
                              side: BorderSide(color: Colors.green, width: 4.0),
                              borderRadius: BorderRadius.circular(5.0),
                            )
                          : null,
                      child: Center(
                        child: Text('${cities[index].name}'),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }
      },
    );
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
                      shape: context.read(selectedSalon).state.docId ==
                              salons[index].docId
                          ? RoundedRectangleBorder(
                              side: BorderSide(color: Colors.green, width: 4.0),
                              borderRadius: BorderRadius.circular(5.0),
                            )
                          : null,
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

  displayAppointment(BuildContext context) {
    //First, we need to check if user is staff of selected salon
    return FutureBuilder(
        future: checkStaffOfThisSalon(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var result = snapshot.data as bool;
            if (result) {
              return displaySlot(context);
            } else {
              return Center(
                child: Text('Sorry! You\'re not staff of this salon'),
              );
            }
          }
        });
  }

  displaySlot(BuildContext context) {
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
                  future: getBookingSlotOfBarber(context,
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
                          onTap: listOfBookedTimeSlots.contains(index)
                              ? () => processDoneServices(context, index)
                              : null,
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

  processDoneServices(BuildContext context, int index) {
    context.read(selectedTimeSlot).state = index;
    Navigator.of(context).pushNamed('/doneService');
  }
}
