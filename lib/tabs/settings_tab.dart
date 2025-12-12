import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  bool _notificationsEnabled = true;
  String? _selectedFrequency;
  String? _selectedLanguage;

  static const String _kNameKey = 'settings_name';
  static const String _kEmailKey = 'settings_email';
  static const String _kNotificationsKey = 'settings_notifications';
  static const String _kFrequencyKey = 'settings_frequency';
  static const String _kLanguageKey = 'settings_language';

  final List<String> _frequencies = [
    'Daily',
    'Every 3 days',
    'Weekly',
    'Never',
  ];
  final List<String> _languages = [
    'English',
    'Українська',
    'Español',
    'Français',
    'Deutsch',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = FirebaseAuth.instance.currentUser;

    setState(() {
      _nameController.text =
          prefs.getString(_kNameKey) ?? currentUser?.displayName ?? '';
      _emailController.text =
          prefs.getString(_kEmailKey) ?? currentUser?.email ?? '';

      _notificationsEnabled = prefs.getBool(_kNotificationsKey) ?? true;
      _selectedFrequency = prefs.getString(_kFrequencyKey) ?? 'Weekly';
      _selectedLanguage = prefs.getString(_kLanguageKey) ?? 'English';
    });
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final newName = _nameController.text;
      final newEmail = _emailController.text;

      await _saveString(_kNameKey, newName);
      await _saveString(_kEmailKey, newEmail);

      await _authRepository.updateUserProfile(
        name: newName,
        email: newEmail,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to save settings.';
      if (e.code == 'requires-recent-login') {
        message = 'Please sign out and sign in again to update your email.';
      } else {
        message = e.message ?? message;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unknown error occurred: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Name', style: TextStyle(color: Colors.white)),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Your name',
                fillColor: Colors.grey,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                errorStyle: const TextStyle(color: Colors.redAccent),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Email', style: TextStyle(color: Colors.white)),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'your.email@example.com',
                fillColor: Colors.grey,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                errorStyle: const TextStyle(color: Colors.redAccent),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Invalid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Enable notifications',
                    style: TextStyle(color: Colors.white)),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveBool(_kNotificationsKey, value);
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[700],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Notifications frequency',
                style: TextStyle(color: Colors.white)),
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              hint: const Text('Select frequency'),
              decoration: InputDecoration(
                fillColor: Colors.grey,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                errorStyle: const TextStyle(color: Colors.redAccent),
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              items: _frequencies.map((freq) {
                return DropdownMenuItem(
                  value: freq,
                  child: Text(freq),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFrequency = value;
                  });
                  _saveString(_kFrequencyKey, value);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Select frequency';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Language', style: TextStyle(color: Colors.white)),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              hint: const Text('Select language'),
              decoration: InputDecoration(
                fillColor: Colors.grey,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                errorStyle: const TextStyle(color: Colors.redAccent),
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              items: _languages.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                  _saveString(_kLanguageKey, value);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Select language';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              )
                  : const Text(
                'Save changes',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}