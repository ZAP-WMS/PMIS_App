import 'package:ev_pmis_app/provider/All_Depo_Select_Provider.dart';
import 'package:ev_pmis_app/provider/cities_provider.dart';
import 'package:ev_pmis_app/provider/demandEnergyProvider.dart';
import 'package:ev_pmis_app/provider/energy_provider_admin.dart';
import 'package:ev_pmis_app/provider/energy_provider_user.dart';
import 'package:ev_pmis_app/provider/internet_provider.dart';
import 'package:ev_pmis_app/provider/key_provider.dart';
import 'package:ev_pmis_app/provider/scroll_top_provider.dart';
import 'package:ev_pmis_app/provider/selected_row_index.dart';
import 'package:ev_pmis_app/provider/summary_provider.dart';
import 'package:ev_pmis_app/route/routegenerator.dart';
import 'package:ev_pmis_app/style.dart';
import 'package:ev_pmis_app/viewmodels/push_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message:${message.messageId}");
  RemoteMessage? initializeMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initializeMessage != null) {
    PushNotification notification = PushNotification(
      title: initializeMessage.notification!.title ?? '',
      body: initializeMessage.notification!.body ?? '',
      dataTitle: initializeMessage.data['title'] ?? '',
      datBody: initializeMessage.data['body'] ?? '',
    );
  }
}

void main() async {
  // its used for status bar color
  Future.delayed(Duration.zero, () async {
    //to run async code in initState
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    // enables secure mode for app, disables screenshot, screen recording
  });

// here i have initialize my firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: blue));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft
  ]);

  // NotificationService().initialize();
  // NotificationService().getFCMToken();
// To show file downloaded notification for pdf
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) async {
      await OpenFile.open(details.payload!);
    },
  );
// To request permission for notification and storage
  // await [
  //   Permission.notification,
  //   Permission.storage,
  // ].request();
  runApp(MyApp());
  //for handling the notification in terminated state
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // This widget is the root of your application.

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    _firebaseMessaging.getToken().then((value) {
      print("token::::$value");
      // sendNotificationToUser(value!, 'title', 'body');
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //handle incoming messages
      print('receive message${message.notification?.body}');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CitiesProvider()),
        ChangeNotifierProvider(create: (context) => SummaryProvider()),
        ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (context) => KeyProvider()),
        ChangeNotifierProvider(create: (context) => EnergyProvider()),
        ChangeNotifierProvider(create: (context) => SelectedRowIndexModel()),
        ChangeNotifierProvider(create: (context) => DemandEnergyProvider()),
        ChangeNotifierProvider(create: (context) => AllDepoSelectProvider()),
        ChangeNotifierProvider(create: (context) => ScrollProvider()),
        ChangeNotifierProvider(create: (context) => EnergyProviderAdmin()),
      ],
      child: OverlaySupport(
        child: GetMaterialApp(
          // initialRoute: '/splash',
          initialRoute: '/splash-screen',
          // all the pages of routes are declared here
          onGenerateRoute: RouteGenerator.generateRoute,
          debugShowCheckedModeBanner: false,
          title: 'TP-EV-PMIS',
          theme: ThemeData(
            brightness: Brightness.light,
            fontFamily: 'Montserrat',
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            dividerColor: const Color.fromARGB(255, 2, 42, 75),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: blue),
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: blue)),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              focusColor: black,
              // labelStyle: Colors.b
            ),
          ),

          //home: LoginRegister()
        ),
      ),
    );
  }
}
