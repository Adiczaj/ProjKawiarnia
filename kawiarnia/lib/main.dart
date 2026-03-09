import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kawiarnia/app.dart';
import 'package:kawiarnia/simple_bloc_observer.dart';
import 'package:user_repository/user_repository.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ZMIENIONY FRAGMENT:
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp(FirebaseUserRepo()));
}

//flutter run -d web-server
//lub
//flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8080
//zeby uruchomic