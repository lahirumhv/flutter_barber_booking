import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barber_booking/cloud_firestore/banner_ref.dart';
import 'package:flutter_barber_booking/cloud_firestore/lookbook_ref.dart';
import 'package:flutter_barber_booking/cloud_firestore/user_ref.dart';
import 'package:flutter_barber_booking/models/image_model.dart';
import 'package:flutter_barber_booking/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return SafeArea(
      child: Scaffold(
        //Resize when onscreen keyboard appears
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xFFDFDFDF),
        body: SingleChildScrollView(
          child: Column(
            children: [
              //User Profile
              FutureBuilder(
                future: getUserProfiles(
                    context, FirebaseAuth.instance.currentUser!.phoneNumber),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    var userModel = snapshot.data as UserModel;

                    return Container(
                      decoration: BoxDecoration(color: Color(0xFF383838)),
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30.0,
                            ),
                            maxRadius: 30.0,
                            backgroundColor: Colors.black,
                          ),
                          SizedBox(
                            width: 30.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${userModel.name}',
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 22.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${userModel.address}',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          userModel.isStaff!
                              ? IconButton(
                                  onPressed: () => Navigator.of(context)
                                      .pushNamed('/staffHome'),
                                  icon: Icon(
                                    Icons.admin_panel_settings,
                                    color: Colors.yellow,
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    );
                  }
                },
              ),
              //Menu
              Padding(
                padding: EdgeInsets.all(4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/booking'),
                        child: Container(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.book_online,
                                    size: 50.0,
                                  ),
                                  Text(
                                    'Booking',
                                    style: GoogleFonts.robotoMono(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  size: 50.0,
                                ),
                                Text(
                                  'Cart',
                                  style: GoogleFonts.robotoMono(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/history'),
                        child: Container(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 50.0,
                                  ),
                                  Text(
                                    'History',
                                    style: GoogleFonts.robotoMono(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Banner
              FutureBuilder(
                future: getBanners(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    var banners = snapshot.data as List<ImageModel>;

                    return CarouselSlider(
                      items: banners
                          .map(
                            (e) => Container(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(e.image!),
                              ),
                            ),
                          )
                          .toList(),
                      options: CarouselOptions(
                        enlargeCenterPage: true,
                        aspectRatio: 3.0,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        // height: MediaQuery.of(context).size.height / 4,
                      ),
                    );
                  }
                },
              ),
              //Lookbook
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      'LOOKBOOK',
                      style: GoogleFonts.robotoMono(fontSize: 24.0),
                    )
                  ],
                ),
              ),
              FutureBuilder(
                future: getLookbook(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    var lookbook = snapshot.data as List<ImageModel>;

                    return Column(
                      children: lookbook
                          .map(
                            (e) => Container(
                              padding: EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(e.image!),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
