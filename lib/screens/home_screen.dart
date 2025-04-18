// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:pray_times/models/prayer_time.dart';
import 'package:pray_times/services/prayer_times_service.dart';
import 'package:pray_times/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

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
  String _locationName = "Unknown location";
  int? _calculationMethod;
  bool _use24HourFormat = false;
  int _timeCalibration = 0; // Time adjustment in minutes
  
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
      _timeCalibration = prefs.getInt('timeCalibration') ?? 0;
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
      
      // Get readable location name
      await _getLocationName();
      
      // Get prayer times based on location
      await _fetchPrayerTimes();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _getLocationName() async {
    if (_currentPosition == null) return;
    
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String locality = place.locality ?? '';
        String administrativeArea = place.administrativeArea ?? '';
        String country = place.country ?? '';
        
        setState(() {
          if (locality.isNotEmpty) {
            _locationName = "$locality, $country";
          } else if (administrativeArea.isNotEmpty) {
            _locationName = "$administrativeArea, $country";
          } else {
            _locationName = country;
          }
        });
      }
    } catch (e) {
      // If geocoding fails, use coordinates as fallback but in a user-friendly format
      setState(() {
        _locationName = "Current location";
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
        calibration: _timeCalibration,
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

  String _formatDate(String dateStr) {
    try {
      // Parse the date (assuming format is DD/MM/YYYY)
      List<String> parts = dateStr.split('/');
      if (parts.length != 3) return dateStr;
      
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      
      DateTime date = DateTime(year, month, day);
      return DateFormat('d MMMM yyyy').format(date);
    } catch (e) {
      return dateStr; // Return original if parsing fails
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
                _formatDate(_prayerTimes!.date),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Location: $_locationName',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (_timeCalibration != 0)
                Text(
                  'Time adjusted: ${_timeCalibration > 0 ? "+$_timeCalibration" : _timeCalibration} minutes',
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
                    // Use current theme's icon color instead of hardcoded color
                    color: Theme.of(context).iconTheme.color,
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