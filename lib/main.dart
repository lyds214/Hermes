// Flutter Packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Onboarding Screens
import 'widgets/loading.dart';
import './screens/onboarding/login.dart';
import './screens/onboarding/register.dart';
import './screens/onboarding/onboarding.dart';

// Student Screens
import './screens/student/student_tabs.dart';
import './screens/student/edit_request.dart';
import './screens/student/new_request.dart';

// Donor Screens
import './screens/donor/donor_tabs.dart';
import './screens/donor/request_details.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        // Change when color scheme is decided
        primarySwatch: Colors.blue,
        // Change when color scheme is decided
        accentColor: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: HomeController(),
      routes: {
        Login.routeName: (ctx) => Login(),
        Register.routeName: (ctx) => Register(),
        OnBoarding.routeName: (ctx) => OnBoarding(),
        StudentTabs.routeName: (ctx) => StudentTabs(),
        NewRequest.routeName: (ctx) => NewRequest(),
        EditRequest.routeName: (ctx) => EditRequest(),
        DonorTabs.routeName: (ctx) => DonorTabs(),
        RequestDetails.routeName: (ctx) => RequestDetails(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (ctx) => Login());
      },
    );
  }
}

class HomeController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data.uid)
                  .snapshots(),
              builder: (ctx, ss) {
                if (ss.hasData && ss.data != null) {
                  final userDoc = ss.data;
                  final user = userDoc.data();
                  if (user == null) {
                    return Login();
                  }
                  if(user['isOnboarding']) {
                    return OnBoarding(userRole: user['role'],);
                  } else if (user['role'] == 'student') {
                    print('user id: ' + FirebaseAuth.instance.currentUser.uid);
                    print('student tabs');
                    return StudentTabs();
                  } else if (user['role'] == 'donor') {
                    return DonorTabs();
                  }
                }
                return Loading();
              },
            );
          }
          return Login();
        });
  }
}
