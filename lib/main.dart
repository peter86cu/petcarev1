import 'package:PetCare/pages/Config.dart';
import 'package:PetCare/pages/home_estilista.dart';
import 'package:PetCare/pages/home_inicial.dart';
import 'package:PetCare/pages/home_propietario.dart';
import 'package:PetCare/pages/inicio_page.dart';
import 'package:PetCare/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';

import 'class/SessionProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Este método maneja las notificaciones en segundo plano o cuando la app está cerrada
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");

  // Si la notificación tiene título y cuerpo, muestra la notificación localmente
  if (message.notification != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa las notificaciones locales
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@drawable/mascota');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Config.loadConfig();

  // Run the app after determining the initial route
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Agregamos el método para determinar la ruta inicial
  Future<String> _determineInitialRoute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    bool alreadySelected = prefs.getBool('alreadySelected') ?? false;

    if (!seenOnboarding) {
      return '/onboarding';
    } else if (!alreadySelected) {
      return '/home_propietario'; // Ruta de la pantalla de selección de perfil y actividades
    } else {
      return '/login'; // O la ruta que corresponda después de que el usuario haya hecho su selección
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _determineInitialRoute(), // Determinamos la ruta inicial
      builder: (context, snapshot) {
        // Mostrar una pantalla de carga mientras se verifica SharedPreferences
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Si hay un error, podrías manejarlo aquí
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error al cargar la aplicación')),
            ),
          );
        }

        // Obtener la ruta inicial determinada
        String initialRoute = snapshot.data ?? '/onboarding';

        return ChangeNotifierProvider(
          create: (_) => SessionProvider(), // Asegúrate de tener este provider definido
          child: MaterialApp(
            title: 'PetCare+',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            initialRoute: initialRoute,
            routes: {
              '/onboarding': (context) => OnboardingScreen(),
              '/login': (context) => LoginPage(),
              '/home_propietario': (context) => HomePage(),
              '/home_inicio': (context) => HomePageInicio(),
              '/mis_mascota_page': (context) => MisMascotasPage(),
              '/home_estilista': (context) => HomeEstilista(role: 0),
              '/perfil_actividades': (context) => PerfilActividadesScreen(), // Agregar esta ruta
            },
          ),
        );
      },
    );
  }

  // Check if onboarding has been seen using shared_preferences
  Future<bool> _checkIfOnboardingSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seenOnboarding') ?? false;
  }
}
