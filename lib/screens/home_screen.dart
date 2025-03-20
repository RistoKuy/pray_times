import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:pray_times/services/location_service.dart';
import 'package:pray_times/services/prayer_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final PrayerTimesService _prayerService = PrayerTimesService();
  PrayerTimes? _prayerTimes;
  bool _isLoading = true;
  String _locationInfo = "Unknown location";
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        setState(() {
          _errorMessage = "Location permission denied";
          _isLoading = false;
        });
        return;
      }

      final prayerTimes = await _prayerService.getPrayerTimes(position);
      
      setState(() {
        _prayerTimes = prayerTimes;
        _locationInfo = "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading prayer times: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrayerTimes,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadPrayerTimes,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _buildPrayerTimesContent(isDarkMode),
    );
  }

  Widget _buildPrayerTimesContent(bool isDarkMode) {
    if (_prayerTimes == null) {
      return const Center(child: Text('No prayer times available'));
    }

    final nextPrayer = _prayerService.getNextPrayer(_prayerTimes!);
    final timeUntilNext = _prayerService.getTimeUntilNextPrayer(_prayerTimes!);
    
    return RefreshIndicator(
      onRefresh: _loadPrayerTimes,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        DateFormat.yMMMMd().format(DateTime.now()),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _locationInfo,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Divider(),
                      Text(
                        'Next Prayer: $nextPrayer in $timeUntilNext',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.lightBlueAccent : Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildPrayerTimeCard('Fajr', _prayerService.formatPrayerTime(_prayerTimes!.fajr), isDarkMode),
              _buildPrayerTimeCard('Sunrise', _prayerService.formatPrayerTime(_prayerTimes!.sunrise), isDarkMode),
              _buildPrayerTimeCard('Dhuhr', _prayerService.formatPrayerTime(_prayerTimes!.dhuhr), isDarkMode),
              _buildPrayerTimeCard('Asr', _prayerService.formatPrayerTime(_prayerTimes!.asr), isDarkMode),
              _buildPrayerTimeCard('Maghrib', _prayerService.formatPrayerTime(_prayerTimes!.maghrib), isDarkMode),
              _buildPrayerTimeCard('Isha', _prayerService.formatPrayerTime(_prayerTimes!.isha), isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimeCard(String name, String time, bool isDarkMode) {
    final isNextPrayer = _prayerTimes != null && 
        _prayerService.getNextPrayer(_prayerTimes!).toLowerCase() == name.toLowerCase();
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: isNextPrayer 
        ? (isDarkMode ? Colors.blue.shade900 : Colors.blue.shade50)
        : null,
      child: ListTile(
        leading: Icon(
          _getIconForPrayer(name),
          color: isNextPrayer 
            ? (isDarkMode ? Colors.white : Colors.blue.shade700)
            : null,
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isNextPrayer ? FontWeight.bold : FontWeight.normal,
            color: isNextPrayer 
              ? (isDarkMode ? Colors.white : Colors.blue.shade700)
              : null,
          ),
        ),
        trailing: Text(
          time,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isNextPrayer ? FontWeight.bold : FontWeight.normal,
            color: isNextPrayer 
              ? (isDarkMode ? Colors.white : Colors.blue.shade800)
              : null,
          ),
        ),
      ),
    );
  }

  IconData _getIconForPrayer(String prayer) {
    switch (prayer.toLowerCase()) {
      case 'fajr':
        return Icons.brightness_3;
      case 'sunrise':
        return Icons.wb_sunny_outlined;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.wb_twighlight;
      case 'maghrib':
        return Icons.brightness_4;
      case 'isha':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }
}
