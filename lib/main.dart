import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_auth_ui/flutter_auth_ui.dart';
import 'package:flutter_barber_booking/screens/booking_screen.dart';
import 'package:flutter_barber_booking/screens/done_services_screen.dart';
import 'package:flutter_barber_booking/screens/home_screen.dart';
import 'package:flutter_barber_booking/screens/staff_home_screen.dart';
import 'package:flutter_barber_booking/screens/user_history_screen.dart';
import 'package:flutter_barber_booking/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:flutter_barber_booking/state/state_management.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Firebase
  Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return PageTransition(
              settings: settings,
              child: HomePage(),
              type: PageTransitionType.fade,
            );
          case '/booking':
            return PageTransition(
              settings: settings,
              child: BookingScreen(),
              type: PageTransitionType.fade,
            );
          case '/history':
            return PageTransition(
              settings: settings,
              child: UserHistoryScreen(),
              type: PageTransitionType.fade,
            );
          case '/staffHome':
            return PageTransition(
              settings: settings,
              child: StaffHome(),
              type: PageTransitionType.fade,
            );
          case '/doneService':
            return PageTransition(
              settings: settings,
              child: DoneService(),
              type: PageTransitionType.fade,
            );
          //break;
          default:
            return null;
        }
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldState,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/my_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width,
                child: FutureBuilder(
                  future: checkLoginState(context, false, scaffoldState),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      var userState = snapshot.data as LOGIN_STATE;
                      if (userState == LOGIN_STATE.LOGGED) {
                        return Container();
                      } else {
                        // If user already not loggedin, return login button
                        return ElevatedButton.icon(
                          onPressed: () => processLogin(context),
                          icon: Icon(
                            Icons.phone,
                            color: Colors.white,
                          ),
                          label: Text(
                            'LOGIN WITH PHONE',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  processLogin(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    //user not loggedin, show login
    if (user == null) {
      FlutterAuthUi.startUi(
          items: [AuthUiProvider.phone],
          tosAndPrivacyPolicy: TosAndPrivacyPolicy(
            tosUrl: "https://www.google.com",
            privacyPolicyUrl: "https://www.google.com",
          ),
          androidOption: AndroidOption(
            enableSmartLock: false,
            showLogo: true,
            overrideTheme: true,
          )).then((value) async {
        //TODO: cant we assign a watch instead of refreshing state here
        //Refresh State
        context.read(userLogged).state = FirebaseAuth.instance.currentUser;
        ScaffoldMessenger.of(scaffoldState.currentContext!).showSnackBar(
          SnackBar(
            content: Text(
                'Login success ${FirebaseAuth.instance.currentUser!.phoneNumber}'),
          ),
        );
        await checkLoginState(context, true, scaffoldState);
      }).catchError((e) {
        ScaffoldMessenger.of(scaffoldState.currentContext!)
            .showSnackBar(SnackBar(content: Text('${e.toString()}')));
      });
    }
    //user already loggedin, navigate to home page
    else {}
  }

  Future<LOGIN_STATE> checkLoginState(BuildContext context, bool fromLogin,
      GlobalKey<ScaffoldState> scaffoldState) async {
    if (!context.read(forceReload).state) {
      await Future.delayed(Duration(seconds: fromLogin ? 0 : 3)).then((value) =>
          FirebaseAuth.instance.currentUser!.getIdToken().then((token) async {
            //If token recieved, print it
            print('$token');
            context.read(userToken).state = token;
            //check user in FireStore
            CollectionReference userRef =
                FirebaseFirestore.instance.collection('User');
            DocumentSnapshot snapshotUser = await userRef
                .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
                .get();

            //Force reload state
            context.read(forceReload).state = true;
            if (snapshotUser.exists) {
              //And since user already loggedin, navigate to to home page
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            } else {
              //If user info not available, show dialog
              var nameController = TextEditingController();
              var addressController = TextEditingController();
              Alert(
                context: context,
                title: 'UPDATE PROFILES',
                content: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.account_circle),
                        labelText: 'Name',
                      ),
                      controller: nameController,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.home),
                        labelText: 'Address',
                      ),
                      controller: addressController,
                    ),
                  ],
                ),
                buttons: [
                  // DialogButton(
                  //   child: Text('CANCEL'),
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //     Navigator.pushNamedAndRemoveUntil(
                  //         context, '/home', (route) => false);
                  //   },
                  // ),
                  DialogButton(
                    child: Text('UPDATE'),
                    onPressed: () {
                      //Update to server
                      userRef
                          .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
                          .set({
                        'name': nameController.text,
                        'address': addressController.text,
                      }).then((value) async {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(scaffoldState.currentContext!)
                            .showSnackBar(SnackBar(
                                content:
                                    Text('PROFILE UPDATED SUCCESSFULLY!')));
                        //And since user already loggedin, navigate to home page after a delay
                        await Future.delayed(Duration(seconds: 1), () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/home', (route) => false);
                        });
                      }).catchError((e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(scaffoldState.currentContext!)
                            .showSnackBar(SnackBar(content: Text('Error: $e')));
                      });
                    },
                  ),
                ],
              ).show();
            }
          }));
    }
    return FirebaseAuth.instance.currentUser != null
        ? LOGIN_STATE.LOGGED
        : LOGIN_STATE.NOT_LOGIN;
  }
}
