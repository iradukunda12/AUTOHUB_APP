import 'dart:convert';

import 'package:autohub/pages/InitialPage.dart';
import 'package:autohub/pages/UserMainPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'builders/TypeStateProvider.dart';
import 'components/CustomOverrides.dart';
import 'components/CustomProject.dart';
import 'data/ChannelData.dart';
import 'firebase/FirebaseConfig.dart';
import 'local_database.dart';
import 'local_navigation_controller.dart';
import 'local_notification.dart';
import 'route_name.dart';
import 'supabase/SupabaseConfig.dart';

@pragma('vm:entry-point')
Future<void> performActionOnBackGroundMessage(RemoteMessage message) async {
  // Firebase
  await FirebaseConfig().initialize(fromBackground: true);

  // Local Notification
  await LocalNotification().setup();

  final notification = message.notification;
  if (notification == null) {
    return;
  }
  LocalNotification().showLocalNotification(
      notification.hashCode,
      notification.title,
      notification.body,
      ChannelData.extractData(notification),
      payload: jsonEncode(message.toMap()));
}

enum ColorMode { dark, light }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setLightUiViewOverlay();

  // Lock to only portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Online Database
  // Firebase
  await FirebaseConfig().initialize(fromBackground: false);

  // Supabase
  await SupabaseConfig.initialize;

  // Local Database
  var localDatabase = LocalDatabase();

  //Initialize all Local Databases
  await localDatabase.startHive();

  //Perform First Time Local Database Write
  localDatabase.firstTimeDefaultWrite();

  // Navigate to Application
  runApp(TypeStateProviderWidget<String, String>(
      provider: TypeStateProvider(initialState: "en"),
      child: TypeStateProviderWidget<ColorMode, Color>(
        provider: TypeStateProvider(initialState: ColorMode.dark),
        child: MaterialApp(
          navigatorKey: LocalNavigationController.useNavigatorKey,
          builder: setMaxTextScaleFactor(maxFactor: 1.5),
          scrollBehavior: CustomScrollBehaviour(),
          theme: ThemeData(
              fontFamily: GoogleFonts.montserrat().fontFamily,
              appBarTheme: AppBarTheme(color: Colors.white),
              primarySwatch: getMainGreenSwatch),
          debugShowCheckedModeBanner: false,
          initialRoute: RouteName.primaryPage,
          routes: {
            RouteName.initialPage: (context) => const UserMainPage(),
            RouteName.primaryPage: (context) => const PrimaryPage(),
          },
        ),
      )));
}

const getMainGreenSwatch = MaterialColor(getMainBlueColor, {
  50: Color(getMainBlueColor),
  100: Color(getMainBlueColor),
  200: Color(getMainBlueColor),
  300: Color(getMainBlueColor),
  400: Color(getMainBlueColor),
  500: Color(getMainBlueColor),
  600: Color(getMainBlueColor),
  700: Color(getMainBlueColor),
  800: Color(getMainBlueColor),
  900: Color(getMainBlueColor),
});

// Resolved
const int getMainBlueColor = 0xff38b6ff;
const int getMainOrangeColor = 0xffEF3A3A;
const int getMainDarkerGreyColor = 0xff23334B;
const int getMainMoreDarkerGreyColor = 0xff3E495B;

// Unresolved
const int getSesaltColor = 0xffFCFAFA;
const int getMountBattenColor = 0xff95818D;
const int getLighterGreyColor = 0xffB9B5B5;
const int getDarkGreyColor = 0xff615F5F;
const int getSpecialGreenColor = 0xff263527;
const int getWidgetGreyColor = 0xff615F5F;
const int getBottomNavColor = 0xff0E0E10;
const int getLearnMoreColor = 0xffF0CC0C;
const int getBalanceCardColor = 0xff161554;
const int getDarkYellowColor = 0xffFFF50C;
const int getGreyTextColor = 0xffA1A1A1;
const int getGreyDotColor = 0xff615F5F;
const int getLightGreyTextColor = 0xffB9B5B5;
const int getTextLightBlueColor = 0xff2A74E3;
const int getButtonGreenColor = 0xff0D3007;
const int getGridGreyColor = 0xff1E1D1D; // grey
const int getGridOrangeColor = 0xffB18000;
const int getIconTextFieldColor = 0xff383535;
const int getIconSpecialColor = 0xff086599;
const int getTextSpecialColor = 0xffA79E9E;
