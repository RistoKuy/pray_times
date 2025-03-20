import 'package:flutter/material.dart';
import 'package:pray_times/models/prayer_time.dart';
import 'package:pray_times/services/prayer_times_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  DailyPrayerTimes? _prayerTimes;
  bool _isLoading = true;
  String _error = '';
  String _selectedCityId = '1301'; // Default to Jakarta
  
  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
  }
  
  Future<void> _fetchPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    try {
      final prayerTimes = await _prayerTimesService.getPrayerTimes(
        cityId: _selectedCityId,
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
            onPressed: _fetchPrayerTimes,
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
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPrayerTimes,
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
          child: Text(
            _prayerTimes!.date,
            style: Theme.of(context).textTheme.headlineSmall,
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
