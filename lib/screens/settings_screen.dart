// ignore_for_file: unused_field, unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pray_times/services/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _use24HourFormat = false;
  int _calculationMethod = 2; // Default to ISNA method
  int _timeCalibration = 0; // Time adjustment in minutes
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _use24HourFormat = prefs.getBool('use24HourFormat') ?? false;
      _calculationMethod = prefs.getInt('calculationMethod') ?? 2;
      _timeCalibration = prefs.getInt('timeCalibration') ?? 0;
    });
  }
  
  Future<void> _saveTimeFormatPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use24HourFormat', value);
    setState(() {
      _use24HourFormat = value;
    });
  }
  
  Future<void> _saveCalculationMethod(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calculationMethod', value);
    setState(() {
      _calculationMethod = value;
    });
  }
  
  Future<void> _saveTimeCalibration(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('timeCalibration', value);
    setState(() {
      _timeCalibration = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildThemeSelector(context),
          const Divider(),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Time Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Use 24-Hour Format'),
            subtitle: Text(_use24HourFormat ? 'Current: 24-hour (e.g., 14:30)' : 'Current: 12-hour (e.g., 2:30 PM)'),
            value: _use24HourFormat,
            onChanged: _saveTimeFormatPreference,
          ),
          const Divider(),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Prayer Time Calibration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adjust prayer times by ${_timeCalibration > 0 ? "+" : ""}$_timeCalibration minutes',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Use this to correct prayer times if they are earlier or later than your local schedule.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _saveTimeCalibration(_timeCalibration - 1);
                      },
                      child: const Icon(Icons.remove),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        '${_timeCalibration > 0 ? "+" : ""}$_timeCalibration min',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _saveTimeCalibration(_timeCalibration + 1);
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _saveTimeCalibration(0);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: const Text('Reset to Default'),
                ),
              ],
            ),
          ),
          const Divider(),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Prayer Times App v1.0'),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Theme Mode'),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.brightness_5),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.brightness_3),
              ),
            ],
            selected: {themeProvider.themeMode},
            onSelectionChanged: (Set<ThemeMode> modes) {
              themeProvider.setThemeMode(modes.first);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Prayer Times App',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(),
      applicationLegalese: '©2023 Prayer Times App',
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'A simple app to show Islamic prayer times based on your location.',
          ),
        ),
      ],
    );
  }
}
