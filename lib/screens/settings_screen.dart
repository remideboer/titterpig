import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/sound_manager.dart';
import 'settings/sync_settings_screen.dart';
import '../services/sync_service.dart';
import 'package:provider/provider.dart';

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
  bool _isSoundEnabled = false;
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

  void _openSyncSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SyncSettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncService = context.watch<SyncService>();
    
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
          const Divider(),
          ListTile(
            title: const Text('Google Drive Sync'),
            subtitle: Text(syncService.isEnabled 
              ? 'Syncing enabled - ${syncService.currentAccount ?? ''}'
              : 'Tap to set up cloud sync'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openSyncSettings,
          ),
        ],
      ),
    );
  }
} 