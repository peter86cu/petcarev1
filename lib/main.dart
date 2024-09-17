import 'package:PetCare/pages/Config.dart';
import 'package:PetCare/pages/home_estilista.dart';
import 'package:PetCare/pages/home_propietario.dart';
import 'package:PetCare/pages/inicio_page.dart';
import 'package:PetCare/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';

import 'class/SessionProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Config.loadConfig();

  // Run the app after determining the initial route
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfOnboardingSeen(), // Check if onboarding has been seen
      builder: (context, snapshot) {
        // Show a loading screen while checking the shared preferences
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Determine the initial route based on whether onboarding has been seen
        String initialRoute = snapshot.data == false ? '/onboarding' : '/login';

        return ChangeNotifierProvider(
          create: (_) => SessionProvider(), // Create an instance of SessionProvider
          child: MaterialApp(
            title: 'PetCare+',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            initialRoute: initialRoute,
            routes: {
              '/onboarding': (context) => OnboardingScreen(), // Register the onboarding route
              '/login': (context) => LoginPage(),
              '/home_propietario': (context) => HomePage(),
              '/mis_mascota_page': (context) => MisMascotasPage(),
              '/home_estilista': (context) => HomeEstilista(role: 0),
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
