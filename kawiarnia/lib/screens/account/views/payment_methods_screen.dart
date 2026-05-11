// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = Theme.of(context).colorScheme.surface;
    final Color primaryBrown = Theme.of(context).colorScheme.primary;
    const Color textMuted = Color(0xFF9E9A96);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBrown),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Clockwork Coffee',
          style: TextStyle(
            color: primaryBrown,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NAGŁÓWEK
            const Text(
              'SETTINGS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Payment Methods',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: primaryBrown,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Securely manage your brewing subscriptions and order payments.',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 30),

            // GŁÓWNA KARTA (VISA)
            _buildPrimaryCard(context, primaryBrown),
            const SizedBox(height: 16),

            // DRUGA KARTA (MASTERCARD)
            _buildSecondaryCard(),
            const SizedBox(height: 40),

            // SEKCJA DIGITAL WALLETS
            const Text(
              'Digital Wallets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildWalletButton(Icons.apple, 'APPLE PAY')),
                const SizedBox(width: 16),
                Expanded(child: _buildWalletButton(Icons.g_mobiledata, 'GOOGLE PAY', isGoogle: true)),
              ],
            ),
            const SizedBox(height: 40),

            // PRZYCISK DODAWANIA KARTY
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  // todo: W przyszłości tutaj otworzymy formularz Stripe
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBrown,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: primaryBrown.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Add New Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            const Center(
              child: Text(
                'SECURED BY SSL ENCRYPTION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDŻETY POMOCNICZE ---

  Widget _buildPrimaryCard(BuildContext context, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: bgColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.credit_card, color: Colors.white, size: 20),
              ),
              const Text(
                'VISA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text('CARD NUMBER', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            '••••  ••••  ••••  4829',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 2.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EXPIRY', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('12 / 26', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF6EFEA),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.credit_score, color: Colors.black87, size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mastercard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text('•••• 9901 — 05 / 25', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildWalletButton(IconData icon, String title, {bool isGoogle = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon, 
            size: isGoogle ? 40 : 32,
            color: Colors.black87
          ),
          SizedBox(height: isGoogle ? 0 : 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.black54,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}