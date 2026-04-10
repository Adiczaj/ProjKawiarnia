import 'package:cart_item_repository/cart_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kawiarnia/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:kawiarnia/screens/auth/blocks/sign_in_bloc/sign_in_bloc.dart';
import 'package:kawiarnia/screens/auth/views/welcome_screen.dart';
import 'package:kawiarnia/screens/app_bar.dart';
import 'package:kawiarnia/screens/cart/blocks/cart_bloc/cart_bloc.dart';
import 'package:kawiarnia/screens/home/blocks/get_product_bloc/get_product_bloc.dart';
import 'package:product_repository/product_repository.dart';


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
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => SignInBloc(
                      context.read<AuthenticationBloc>().userRepository,
                    ),
                  ),
                  BlocProvider(
                    create: (context) => GetProductBloc(
                      FirebaseKawiarniaRepo()
                      )..add(GetProduct()),
                  ),
                  BlocProvider(
                    create: (context) {
                      final String userId = state.user!.userId; 
                      return CartBloc(
                        FirebaseCartRepo(), 
                      )..add(LoadCart(userId));
                    },
                  ),
                ],
                child: const MainScreen(),
              );
            } else {
              return const WelcomeScreen();
            }
          }),
        ));
  }
}