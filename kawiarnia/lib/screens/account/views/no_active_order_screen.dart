import 'package:flutter/material.dart';

class NoActiveOrderScreen extends StatelessWidget {
  const NoActiveOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {

    const Color darkTitleColor = Color(0xFF2B2A29);
    const Color greySubtitleColor = Color(0xFF706D6B);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
          onPressed: () {
              Navigator.pop(context);
          },
        ),
        title: Text(
          'Active Orders',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    'assets/empty.png',
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Główny tytuł
              const Text(
                'No Active Brews',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: darkTitleColor,
                ),
              ),
              const SizedBox(height: 16),

              // Opis (podtytuł)
              const Text(
                "It looks like you haven't ordered\nanything yet.\nStart your daily ritual now!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: greySubtitleColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}