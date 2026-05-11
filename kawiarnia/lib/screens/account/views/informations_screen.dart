import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kawiarnia/screens/account/views/change_password_screen.dart';
import 'package:user_repository/user_repository.dart';
import 'package:kawiarnia/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  String? _fullName;
  String? _emailAddress;
  String? _phoneNumber;
  bool _isSaving = false;

  void _showEditDialog(
      String title, String currentValue, Function(String) onSave) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter new $title"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color brandDarkBrown = Theme.of(context).colorScheme.primary;
    final Color textMuted = Theme.of(context).colorScheme.onSurface;
    final Color scaffoldBgColor = Theme.of(context).colorScheme.surface;
    const Color fieldBgColor = Color.fromARGB(255, 255, 255, 255);
    final Color iconColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: brandDarkBrown),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Clockwork Coffee',
          style: TextStyle(
              color: brandDarkBrown, fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, authState) {
          final user = authState.user;
          final bool isAuthenticated =
              authState.status == AuthenticationStatus.authenticated &&
                  user != null;
          final String fullName =
              _fullName ?? (isAuthenticated ? user.name : 'None');
          final String emailAddress = _emailAddress ??
              (isAuthenticated ? user.email : 'None');
          final String phoneNumber = _phoneNumber ??
              (isAuthenticated ? user.phone : 'None');

          return SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Details',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: brandDarkBrown,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Text('Personalize your sensory brewing experience.',
                    style: TextStyle(fontSize: 15, color: textMuted)),
                const SizedBox(height: 40),
                Text(
                  'ESSENTIAL INFORMATION',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textMuted,
                      letterSpacing: 1.2),
                ),
                const SizedBox(height: 16),
                _buildProfileField(
                    'Full Name', fullName, fieldBgColor, iconColor, () {
                  _showEditDialog('Full Name', fullName, (newValue) {
                    setState(() => _fullName = newValue);
                  });
                }),
                const SizedBox(height: 16),
                _buildProfileField(
                    'Email Address', emailAddress, fieldBgColor, iconColor, () {
                  _showEditDialog('Email Address', emailAddress, (newValue) {
                    setState(() => _emailAddress = newValue);
                  });
                }),
                const SizedBox(height: 16),
                _buildProfileField(
                    'Phone Number', phoneNumber, fieldBgColor, iconColor, () {
                  _showEditDialog('Phone Number', phoneNumber, (newValue) {
                    setState(() => _phoneNumber = newValue);
                  });
                }),
                const SizedBox(height: 40),
                Text(
                  'SECURITY',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: textMuted,
                      letterSpacing: 1.2),
                ),
                const SizedBox(height: 16),
                _buildSecurityButton(
                  'Change Password', 
                fieldBgColor, 
                  brandDarkBrown, 
                  iconColor,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                    );
                  },
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isAuthenticated && !_isSaving
                        ? () async {
                            try {
                              setState(() => _isSaving = true);

                              bool emailChanged = emailAddress != user.email;

                              if (emailChanged) {
                                await FirebaseAuth.instance.currentUser
                                    ?.verifyBeforeUpdateEmail(emailAddress);
                              }

                              final updatedUser = MyUser(
                                userId: user.userId,
                                email: emailAddress,
                                name: fullName,
                                hasActiveCart: user.hasActiveCart,
                                phone: phoneNumber,
                              );
                            
                              // ignore: use_build_context_synchronously
                              await context
                                  .read<AuthenticationBloc>()
                                  .userRepository
                                  .setUserData(updatedUser);
                                
                              // ignore: use_build_context_synchronously
                              context.read<AuthenticationBloc>().add(AuthenticationUserChanged(updatedUser));

                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(emailChanged 
                                      ? 'Saved! Na nowy adres wysłano link weryfikacyjny. Kliknij go, by zatwierdzić zmianę.' 
                                      : 'Saved user information successfully.'),
                                ),
                              );

                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'requires-recent-login') {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Ze względów bezpieczeństwa wyloguj się i zaloguj ponownie, aby zmienić e-mail.')),
                                );
                              } else {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Auth error: ${e.message}')),
                                );
                              }
                            } catch (_) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('An error occurred while saving changes. Please try again.')),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => _isSaving = false);
                              }
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandDarkBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      _isSaving ? 'Saving...' : 'Save Changes',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileField(String label, String value, Color bgColor,
      Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9E9A96))),
                  const SizedBox(height: 4),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.edit, size: 18, color: iconColor),
          ],
        ),
      ),
    );
  }

    Widget _buildSecurityButton(
      String title, Color bgColor, Color brandColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.lock_outline, color: brandColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600))),
            Icon(Icons.chevron_right, color: iconColor, size: 24),
          ],
        ),
      ),
    );
  }
}
