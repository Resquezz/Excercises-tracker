import 'package:excercises_tracker/app_strings.dart';
import 'package:excercises_tracker/repositories/auth_repository.dart';
import 'package:excercises_tracker/repositories/storage_repository.dart';
import 'package:excercises_tracker/repositories/trainings_repository.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => TrainingsRepository()),
        RepositoryProvider(create: (context) => StorageRepository()),
      ],
      child: const MaterialApp(
        title: AppStrings.appTitle,
        home: LoginScreen(),
      ),
    );
  }
}