import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 119, 119, 119),
      body: Center(
        child: Text('Login successful! Welcome to the Home Screen.'),
        
      ), 
    );
  }
}