import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match!')),
      );
      return;
    }

    String newPassword = _newPasswordController.text;
    bool hasUppercase = newPassword.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = newPassword.contains(RegExp(r'[a-z]'));
    bool hasDigits = newPassword.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = newPassword.contains(RegExp(r'[^a-zA-Z0-9\s]')); 
    bool hasMinLength = newPassword.length >= 8;

    if (!hasMinLength || !hasUppercase || !hasLowercase || !hasDigits || !hasSpecialCharacters) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password must contain at least 8 characters, 1 uppercase letter, 1 lowercase letter, 1 digit and 1 special character.'),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user != null && user.email != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);

        await user.updatePassword(_newPasswordController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred while changing the password.';
      
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'The current password is incorrect.';
      } else {
        errorMessage = e.message ?? errorMessage;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainBrownColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: mainBrownColor),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Clockwork Coffee',
          style: TextStyle(
            color: mainBrownColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            const Text(
              'Update your security',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose a strong password to keep your account safe.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            _buildPasswordField(
              label: 'CURRENT PASSWORD',
              controller: _currentPasswordController,
              obscureText: _obscureCurrentPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureCurrentPassword = !_obscureCurrentPassword;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildPasswordField(
              label: 'NEW PASSWORD',
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildPasswordField(
              label: 'CONFIRM NEW PASSWORD',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updatePassword, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainBrownColor,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  // ignore: deprecated_member_use
                  shadowColor: mainBrownColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F0ED),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(fontSize: 18, letterSpacing: 2.0),
            decoration: InputDecoration(
              hintText: '●●●●●●●●●', 
              hintStyle: const TextStyle(
                  color: Color(0xFFBDBDBD), fontSize: 18, letterSpacing: 2.0),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              border: InputBorder.none,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: const Color(0xFF757575),
                  ),
                  onPressed: onToggleVisibility,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}