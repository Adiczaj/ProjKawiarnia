import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kawiarnia/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:kawiarnia/screens/auth/blocks/sign_in_bloc/sign_in_bloc.dart';
import 'package:kawiarnia/screens/auth/views/welcome_screen.dart';
import 'package:kawiarnia/screens/app_bar.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Kawiarnia',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.light(
                surface: Colors.grey.shade200,
                onSurface: Colors.black,
                primary: const Color.fromARGB(255, 192, 131, 111),
                onPrimary: Colors.white)),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: ((context, state) {
            if (state.status == AuthenticationStatus.authenticated) {
              return BlocProvider(
                create: (context) => SignInBloc(
                  context.read<AuthenticationBloc>().userRepository,
                ),
                child: const MainScreen(),
              );
            } else {
              return const WelcomeScreen();
            }
          }),
        ));
  }
}
