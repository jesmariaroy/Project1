import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:proj1/firebase_options.dart';
import 'pages/splash_page.dart';
import 'pages/home_page.dart' as home;
import 'pages/login_page.dart' as login;
import 'pages/registration_page.dart';
import 'pages/user.dart';
import 'pages/hotel_admin.dart';
import 'pages/admin_page.dart';
import 'pages/TableBookingPage.dart';

// User dashboard for displaying restaurants and menus

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(RestaurantBookingApp());
}

class RestaurantBookingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', // Set SplashScreen as the initial route
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => home.HomePage(),
        '/login': (context) => login.LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/admin_dashboard': (context) => AdminDashboard(),
        '/user_dashboard': (context) => UserDashboard(), // User dashboard
        '/hotel_admin': (context) => HotelAdminDashboard(),
        '/tableBooking': (context) => TableBookingPage(
              restaurantId: '',
            ) // Hotel admin dashboard
      },
    );
  }
}

