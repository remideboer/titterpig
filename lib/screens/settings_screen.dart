import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'package:ttrpg_character_manager/utils/sound_manager.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDarkMode;
  static const String _themeKey = 'isDarkMode';
  bool _isSoundEnabled = false; // Initialize with a default value
  final SoundManager _soundManager = SoundManager();

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _loadSoundSetting();
  }

  @override
  void didUpdateWidget(SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDarkMode != oldWidget.isDarkMode) {
      setState(() {
        _isDarkMode = widget.isDarkMode;
      });
    }
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
    setState(() {
      _isDarkMode = value;
    });
    widget.onThemeChanged(value);
  }

  Future<void> _loadSoundSetting() async {
    await _soundManager.init();
    if (mounted) {
      setState(() {
        _isSoundEnabled = !_soundManager.isMuted;
      });
    }
  }

  Future<void> _toggleSound() async {
    await _soundManager.toggleMute();
    if (mounted) {
      setState(() {
        _isSoundEnabled = !_soundManager.isMuted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark theme'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: _toggleTheme,
            ),
          ),
          ListTile(
            title: const Text('Sound Effects'),
            trailing: Switch(
              value: _isSoundEnabled,
              onChanged: (value) => _toggleSound(),
            ),
          ),
        ],
      ),
    );
  }
} 