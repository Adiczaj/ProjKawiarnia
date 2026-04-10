import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kawiarnia/screens/auth/blocks/sign_in_bloc/sign_in_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Przykładowe dane profilu
  final String _displayName = 'Julianna Thorne';
  final String _memberLevel = 'GOLD MEMBER';
  final int _activeOrdersCount = 2;
  
  bool _notificationsOn = true;
  
  final Color _bgColor = const Color(0xFFFCF7F3); 
  Color get _primaryBrown => Theme.of(context).colorScheme.primary; 
  final Color _cardBgColor = const Color(0xFFF6EFEA); 
  final Color _accentPink = const Color(0xFFF4DFD4); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: _primaryBrown,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          children: [
            // 1. ZDJĘCIE PROFILOWE, IMIĘ, POZIOM
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        // ignore: deprecated_member_use
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundImage: AssetImage('assets/profile_avatar.png'),
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  // Mała ikona (aparat/odznaka) przy zdjęciu
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _cardBgColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Icon(Icons.camera_alt, color: _primaryBrown, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _accentPink,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _memberLevel,
                style: TextStyle(
                  color: _primaryBrown,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 2. ACTIVE ORDERS CARD (W stylu nowej makiety)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  // ignore: deprecated_member_use
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                   
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _cardBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.list_alt, color: _primaryBrown, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Orders',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Check progress',
                                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        Badge(
                          backgroundColor: _primaryBrown,
                          padding: const EdgeInsets.all(6),
                          label: Text(
                            '$_activeOrdersCount Active',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 3. SETTINGS SECTION
            _buildSectionTitle('Settings'),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildSettingItem(index);
              },
            ),
            
            const SizedBox(height: 40), 

            // 4. LOG OUT BUTTON Z LOGIKĄ BLOC
            Center(
              child: SizedBox(
                width: 200,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cardBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                    foregroundColor: _primaryBrown,
                  ),
                  onPressed: () {
                    context.read<SignInBloc>().add(SignOutRequired());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 12),
                      const Text(
                        'Log Out',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),

    );
  }

  // --- Funkcje pomocnicze ---

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Budowanie pojedynczej karty ustawień
  Widget _buildSettingItem(int index) {
    List<Map<String, dynamic>> settingsItems = [
      {'icon': Icons.person_outline, 'title': 'Account Information', 'subtitle': null},
      {'icon': Icons.history, 'title': 'Order History', 'subtitle': null},
      {'icon': Icons.credit_card_outlined, 'title': 'Payment Methods', 'subtitle': null},
      {'icon': Icons.notifications_none, 'title': 'Notifications', 'subtitle': _notificationsOn ? 'On' : 'Off'},
    ];

    var item = settingsItems[index];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _onSettingTapped(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // Ikona w kółku
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _cardBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'], color: _primaryBrown, size: 20),
                ),
                const SizedBox(width: 16),
                // Tytuł
                Expanded(
                  child: Text(
                    item['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                // Opcjonalny napis po prawej
                if (item['subtitle'] != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      item['subtitle'],
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ),
                // Strzałka chevron
                Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSettingTapped(int index) {
    switch (index) {
      case 0: // Account Information
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Account Information')),
              body: const Center(child: Text('Account Information Screen')),
            ),
          ),
        );
        break;
      case 1: // Order History
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Order History')),
              body: const Center(child: Text('Order History Screen')),
            ),
          ),
        );
        break;
      case 2: // Payment Methods
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Payment Methods')),
              body: const Center(child: Text('Payment Methods Screen')),
            ),
          ),
        );
        break;
      case 3: // Notifications
        setState(() {
          _notificationsOn = !_notificationsOn;
        });
        break;
    }
  }
}