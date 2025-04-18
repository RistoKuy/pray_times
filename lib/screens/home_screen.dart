import 'package:flutter/material.dart';
import 'package:pray_times/models/prayer_time.dart';
import 'package:pray_times/services/prayer_times_service.dart';
import 'package:pray_times/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  final LocationService _locationService = LocationService();
  DailyPrayerTimes? _prayerTimes;
  bool _isLoading = true;
  String _error = '';
  Position? _currentPosition;
  int? _calculationMethod;
  bool _use24HourFormat = false;
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _calculationMethod = prefs.getInt('calculationMethod');
      _use24HourFormat = prefs.getBool('use24HourFormat') ?? false;
    });
    _getCurrentLocationAndFetchPrayerTimes();
  }
  
  Future<void> _getCurrentLocationAndFetchPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    try {
      // Get current position
      _currentPosition = await _locationService.getCurrentPosition(context: context);
      if (_currentPosition == null) {
        setState(() {
          _error = 'Unable to get current location. Please check your location settings.';
          _isLoading = false;
        });
        return;
      }
      
      // Get prayer times based on location
      await _fetchPrayerTimes();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _fetchPrayerTimes() async {
    if (_currentPosition == null) {
      setState(() {
        _error = 'Location not available. Please enable location services.';
        _isLoading = false;
      });
      return;
    }
    
    try {
      final prayerTimes = await _prayerTimesService.getPrayerTimes(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        method: _calculationMethod,
      );
      setState(() {
        _prayerTimes = prayerTimes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocationAndFetchPrayerTimes,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              _loadPreferences();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getCurrentLocationAndFetchPrayerTimes,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    if (_prayerTimes == null) {
      return const Center(child: Text('No prayer times available'));
    }
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                _prayerTimes!.date,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (_currentPosition != null)
                Text(
                  'Location: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              Text(
                'Time Format: ${_use24HourFormat ? '24-hour' : '12-hour'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _prayerTimes!.prayerTimes.length,
            itemBuilder: (context, index) {
              final prayer = _prayerTimes!.prayerTimes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.access_time,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    prayer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    prayer.time,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}