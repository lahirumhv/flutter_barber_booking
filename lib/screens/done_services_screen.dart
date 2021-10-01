import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barber_booking/cloud_firestore/all_salon_ref.dart';
import 'package:flutter_barber_booking/cloud_firestore/services_ref.dart';
import 'package:flutter_barber_booking/models/booking_model.dart';
import 'package:flutter_barber_booking/models/service_model.dart';
import 'package:flutter_barber_booking/state/state_management.dart';
import 'package:flutter_barber_booking/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DoneService extends ConsumerWidget {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    //set initial selectedServices as [] to refresh list at pagebuild
    context.read(selectedServices).state.clear();

    return SafeArea(
      child: Scaffold(
        //Resize when onscreen keyboard appears
        resizeToAvoidBottomInset: true,
        key: scaffoldKey,
        backgroundColor: Color(0xFFDFDFDF),
        appBar: AppBar(
          title: Text('Done Services'),
          backgroundColor: Color(0xFF383838),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: FutureBuilder(
                future: getDetailBooking(
                    context, context.read(selectedTimeSlot).state),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    var bookingModel = snapshot.data as BookingModel;
                    return Card(
                      elevation: 8.0,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  child: Icon(
                                    Icons.account_box_rounded,
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.black,
                                ),
                                SizedBox(
                                  width: 30.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${bookingModel.customerName}',
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${bookingModel.customerPhone}',
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Divider(
                              thickness: 2.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Consumer(builder: (context, watch, _) {
                                  var serviceSelected =
                                      watch(selectedServices).state;
                                  double totalPrice = serviceSelected
                                      .map((item) => item.price)
                                      .fold(
                                          0,
                                          (previousValue, element) =>
                                              previousValue + element!);
                                  return Text(
                                    'Price \$${bookingModel.totalPrice == 0 ? totalPrice : bookingModel.totalPrice}',
                                    style:
                                        GoogleFonts.robotoMono(fontSize: 22.0),
                                  );
                                }),
                                context.read(selectedBooking).state.done!
                                    ? Chip(label: Text('Finished'))
                                    : Container()
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: FutureBuilder(
                  future: getServices(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      var services = snapshot.data as List<ServiceModel>;
                      return Consumer(builder: (context, watch, _) {
                        var servicesWatch = watch(selectedServices).state;

                        return SingleChildScrollView(
                            child: Column(
                          children: [
                            ChipsChoice<ServiceModel>.multiple(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              wrapped: true,
                              value: servicesWatch,
                              onChanged: (val) =>
                                  context.read(selectedServices).state = val,
                              choiceStyle: C2ChoiceStyle(elevation: 8.0),
                              choiceItems:
                                  C2Choice.listFrom<ServiceModel, ServiceModel>(
                                source: services,
                                value: (index, value) => value,
                                label: (index, value) =>
                                    '${value.name} (\$${value.price})',
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed:
                                    context.read(selectedBooking).state.done!
                                        ? null
                                        : servicesWatch.length > 0
                                            ? () => finishService(context)
                                            : null,
                                child: Text(
                                  'FINISH',
                                  style: GoogleFonts.robotoMono(),
                                ),
                              ),
                            )
                          ],
                        ));
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  finishService(BuildContext context) {
    var batch = FirebaseFirestore.instance.batch();
    var barberBook = context.read(selectedBooking).state;

    DocumentReference userBookRef = FirebaseFirestore.instance
        .collection('User')
        .doc(barberBook.customerPhone)
        .collection('Booking_${barberBook.customerId}')
        .doc(
            '${barberBook.barberId}_${DateFormat('dd_MM_yyyy').format(DateTime.fromMillisecondsSinceEpoch(barberBook.timeStamp!))}');

    Map<String, dynamic> updateDone = Map();
    updateDone['done'] = true;
    updateDone['services'] =
        convertServices(context.read(selectedServices).state);
    double totalPrice = context
        .read(selectedServices)
        .state
        .map((e) => e.price)
        .fold(0, (previousValue, element) => previousValue + element!);
    updateDone['totalPrice'] = totalPrice;

    batch.update(userBookRef, updateDone);
    batch.update(barberBook.reference!, updateDone);
    batch.commit().then((value) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(content: Text('Process Success')))
          .closed
          .then((value) => Navigator.of(context).pop());
    });
  }
}
